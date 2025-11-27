import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/building_model.dart';
import '../models/floor_model.dart';
import '../../utils/api_config.dart';

class BuildingRemoteDataSource {
  final http.Client client;

  BuildingRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener todos los edificios
  Future<List<BuildingModel>> getAll(String accessToken) async {
    final url = '${ApiConfig.baseUrl}/environments/v1/api/building';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('🏛️ Buildings response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      print('🏛️ Buildings response: $jsonList');
      if (jsonList.isNotEmpty) {
        print('🏛️ First building: ${jsonList.first}');
      }
      return jsonList.map((json) => BuildingModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener edificios: ${response.statusCode}');
    }
  }

  /// Obtener pisos de un edificio
  Future<List<FloorModel>> getFloorsByBuilding(
    int buildingId,
    String accessToken,
  ) async {
    final url =
        '${ApiConfig.baseUrl}/environments/v1/api/building/$buildingId/floors';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('🏢 Floors response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      print('🏢 Floors response: $jsonList');
      if (jsonList.isNotEmpty) {
        print('🏢 First floor: ${jsonList.first}');
      }
      return jsonList.map((json) => FloorModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener pisos: ${response.statusCode}');
    }
  }
}
