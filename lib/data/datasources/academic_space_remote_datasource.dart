import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/academic_space_model.dart';
import '../../utils/api_config.dart';

class AcademicSpaceRemoteDataSource {
  final http.Client client;

  AcademicSpaceRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener todos los espacios académicos
  Future<List<AcademicSpaceModel>> getAll(String accessToken) async {
    final url = '${ApiConfig.baseUrl}/environments/v1/api/academic-space';

    print('🏢 Fetching academic spaces from: $url');

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('🏢 Response status: ${response.statusCode}');
    print('🏢 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      print('🏢 Found ${jsonList.length} academic spaces in response');
      if (jsonList.isNotEmpty) {
        print('🏢 First item structure: ${jsonList.first}');
      }
      return jsonList.map((json) => AcademicSpaceModel.fromJson(json)).toList();
    } else {
      print('🏢 Error response body: ${response.body}');
      throw Exception(
        'Error al obtener espacios académicos: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Obtener un espacio académico por ID
  Future<AcademicSpaceModel> getById(int id, String accessToken) async {
    final url = '${ApiConfig.baseUrl}/environments/v1/api/academic-space/$id';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return AcademicSpaceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al obtener espacio académico: ${response.statusCode}',
      );
    }
  }

  /// Crear un nuevo espacio académico
  Future<AcademicSpaceModel> create(
    AcademicSpaceCreateRequest request,
    String accessToken,
  ) async {
    final url = '${ApiConfig.baseUrl}/environments/v1/api/academic-space';

    print('➕ Creating academic space at: $url');
    print('➕ Request body: ${jsonEncode(request.toJson())}');

    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    print('➕ Response status: ${response.statusCode}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AcademicSpaceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al crear espacio académico: ${response.statusCode}',
      );
    }
  }

  /// Actualizar un espacio académico
  Future<AcademicSpaceModel> update(
    int id,
    AcademicSpaceCreateRequest request,
    String accessToken,
  ) async {
    final url = '${ApiConfig.baseUrl}/environments/v1/api/academic-space/$id';

    print('✏️ Updating academic space at: $url');

    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return AcademicSpaceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al actualizar espacio académico: ${response.statusCode}',
      );
    }
  }

  /// Eliminar un espacio académico
  Future<void> delete(int id, String accessToken) async {
    final url = '${ApiConfig.baseUrl}/environments/v1/api/academic-space/$id';

    print('🗑️ Deleting academic space at: $url');

    final response = await client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Error al eliminar espacio académico: ${response.statusCode}',
      );
    }
  }
}
