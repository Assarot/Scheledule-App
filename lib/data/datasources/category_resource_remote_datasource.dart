import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_resource_model.dart';
import '../../utils/api_config.dart';

class CategoryResourceRemoteDataSource {
  final http.Client client;

  CategoryResourceRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener todas las categorías
  Future<List<CategoryResourceModel>> getAll(String accessToken) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/category-resources';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => CategoryResourceModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener categorías: ${response.statusCode}');
    }
  }

  /// Obtener categorías activas
  Future<List<CategoryResourceModel>> getActive(String accessToken) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/category-resources/active';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => CategoryResourceModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Error al obtener categorías activas: ${response.statusCode}',
      );
    }
  }
}
