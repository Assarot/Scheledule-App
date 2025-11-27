import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resource_type_model.dart';
import '../../utils/api_config.dart';

class ResourceTypeRemoteDataSource {
  final http.Client client;

  ResourceTypeRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener todos los tipos de recursos
  Future<List<ResourceTypeModel>> getAll(String accessToken) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resource-types';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ResourceTypeModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener tipos de recursos: ${response.statusCode}',
      );
    }
  }

  /// Obtener tipos activos
  Future<List<ResourceTypeModel>> getActive(String accessToken) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resource-types/active';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ResourceTypeModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener tipos activos: ${response.statusCode}');
    }
  }

  /// Obtener tipos por categoría
  Future<List<ResourceTypeModel>> getByCategory(
    int categoryId,
    String accessToken,
  ) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resource-types/category/$categoryId';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ResourceTypeModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener tipos por categoría: ${response.statusCode}',
      );
    }
  }
}
