import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/state_model.dart';
import '../models/type_academic_space_model.dart';
import '../../utils/api_config.dart';

class EnvironmentMetadataDataSource {
  final http.Client client;

  EnvironmentMetadataDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener todos los estados
  Future<List<StateModel>> getAllStates(String accessToken) async {
    final url = '${ApiConfig.baseUrl}/environments/v1/api/state';

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

  /// Obtener todos los tipos de espacios académicos
  Future<List<TypeAcademicSpaceModel>> getAllTypes(String accessToken) async {
    final url = '${ApiConfig.baseUrl}/environments/v1/api/type-academic-space';

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
          .map((json) => TypeAcademicSpaceModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Error al obtener tipos de espacios: ${response.statusCode}',
      );
    }
  }
}
