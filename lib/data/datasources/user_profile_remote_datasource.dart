import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user_profile_model.dart';
import '../models/user_profile_create_request.dart';

class UserProfileRemoteDataSource {
  final http.Client client;

  UserProfileRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener perfil de usuario por email
  Future<UserProfileModel> getUserProfileByEmail(
    String email,
    String accessToken,
  ) async {
    // Llamada directa al microservicio ms-user (puerto 8082)
    final url = 'http://192.168.0.45:8082/api/v1/user-profiles/email/$email';
    print('Fetching profile from: $url');

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('Profile response status: ${response.statusCode}');
    print('Profile response body: ${response.body}');

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al obtener perfil por email: ${response.statusCode}',
      );
    }
  }

  /// Obtener perfil de usuario por ID
  Future<UserProfileModel> getUserProfileById(
    int profileId,
    String accessToken,
  ) async {
    // Llamada directa al microservicio ms-user (puerto 8082)
    final response = await client.get(
      Uri.parse('http://192.168.0.45:8082/api/v1/user-profiles/$profileId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al obtener perfil de usuario: ${response.statusCode}',
      );
    }
  }

  /// Actualizar foto de perfil
  Future<UserProfileModel> updateProfilePicture(
    int profileId,
    File imageFile,
    String accessToken,
  ) async {
    // Llamada directa al microservicio ms-user (puerto 8082)
    final uri = Uri.parse(
      'http://192.168.0.45:8082/api/v1/user-profiles/$profileId/profile-picture',
    );

    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al actualizar foto de perfil: ${response.statusCode}',
      );
    }
  }

  /// Crear un nuevo perfil de usuario
  Future<UserProfileModel> createUserProfile(
    UserProfileCreateRequest request,
    String accessToken,
  ) async {
    final url = 'http://192.168.0.45:8082/api/v1/user-profiles';

    print('📝 Creating profile at: $url');
    print('📝 Request body: ${jsonEncode(request.toJson())}');

    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    print('📝 Create profile response status: ${response.statusCode}');
    print('📝 Create profile response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return UserProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al crear perfil: ${response.statusCode} - ${response.body}',
      );
    }
  }
}