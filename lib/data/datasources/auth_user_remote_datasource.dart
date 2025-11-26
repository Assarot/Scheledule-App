import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_user_response_dto.dart';
import '../../utils/api_config.dart';

class AuthUserRemoteDataSource {
  final http.Client client;

  AuthUserRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener información del auth_user por ID para obtener el idUserProfile
  Future<AuthUserResponseDto> getAuthUserById(
    int userId,
    String accessToken,
  ) async {
    final url = '${ApiConfig.baseUrl}/microservice-auth/api/auth/users/$userId';

    print('📋 Fetching auth_user from: $url');

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('📋 Auth user response status: ${response.statusCode}');
    print('📋 Auth user response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('📋 Parsed JSON: $jsonData');
      return AuthUserResponseDto.fromJson(jsonData);
    } else {
      throw Exception('Error al obtener auth_user: ${response.statusCode}');
    }
  }

  /// Actualizar el userProfileId del auth_user
  Future<void> updateUserProfileId(
    int userId,
    int userProfileId,
    String accessToken,
  ) async {
    final url = '${ApiConfig.baseUrl}/microservice-auth/api/auth/users/$userId';

    print('🔄 Updating auth_user with userProfileId: $userProfileId');

    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'userProfileId': userProfileId}),
    );

    print('🔄 Update response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar auth_user: ${response.statusCode}');
    }
  }
}
