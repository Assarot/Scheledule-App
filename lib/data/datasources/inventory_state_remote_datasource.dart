import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/state_model.dart';
import '../../utils/api_config.dart';

class InventoryStateRemoteDataSource {
  final http.Client client;

  InventoryStateRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener todos los estados del inventario
  Future<List<StateModel>> getAll(String accessToken) async {
    final url = '${ApiConfig.baseUrl}/microservice-inventory/api/v1/states';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => StateModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener estados: ${response.statusCode}');
    }
  }

  /// Obtener un estado por ID
  Future<StateModel> getById(int id, String accessToken) async {
    final url = '${ApiConfig.baseUrl}/microservice-inventory/api/v1/states/$id';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return StateModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener estado: ${response.statusCode}');
    }
  }
}
