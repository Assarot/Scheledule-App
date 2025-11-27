import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resource_assignment_model.dart';
import '../../utils/api_config.dart';

class ResourceAssignmentRemoteDataSource {
  final http.Client client;

  ResourceAssignmentRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener todas las asignaciones
  Future<List<ResourceAssignmentModel>> getAll(String accessToken) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resource-assignments';

    print('🔗 Fetching resource assignments from: $url');

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('🔗 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      print('🔗 Found ${jsonList.length} assignments');
      return jsonList
          .map((json) => ResourceAssignmentModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener asignaciones: ${response.statusCode}');
    }
  }

  /// Obtener asignaciones por ambiente académico
  Future<List<ResourceAssignmentModel>> getByAcademicSpace(
    int academicSpaceId,
    String accessToken,
  ) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resource-assignments/academic-space/$academicSpaceId';

    print(
      '🔗 Fetching assignments for academic space $academicSpaceId from: $url',
    );

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('🔗 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      print(
        '🔗 Found ${jsonList.length} assignments for space $academicSpaceId',
      );
      return jsonList
          .map((json) => ResourceAssignmentModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Error al obtener asignaciones del espacio: ${response.statusCode}',
      );
    }
  }

  /// Obtener asignaciones por recurso
  Future<List<ResourceAssignmentModel>> getByResource(
    int resourceId,
    String accessToken,
  ) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resource-assignments/resource/$resourceId';

    print('🔗 Fetching assignments for resource $resourceId from: $url');

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('🔗 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      print('🔗 Found ${jsonList.length} assignments for resource $resourceId');
      return jsonList
          .map((json) => ResourceAssignmentModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Error al obtener asignaciones del recurso: ${response.statusCode}',
      );
    }
  }

  /// Crear una nueva asignación
  Future<ResourceAssignmentModel> create(
    ResourceAssignmentCreateRequest request,
    String accessToken,
  ) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resource-assignments';

    print('➕ Creating resource assignment at: $url');
    print('➕ Request data: ${request.toJson()}');

    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    print('🔗 Create response status: ${response.statusCode}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Assignment created successfully');
      final createdAssignment = ResourceAssignmentModel.fromJson(
        jsonDecode(response.body),
      );

      // Si el backend devolvió resource: null, hacer GET para obtener el objeto completo
      if (createdAssignment.idResource == 0 ||
          createdAssignment.resource == null) {
        print(
          '🔄 Resource is null or idResource is 0, fetching complete assignment...',
        );
        // Obtener el assignment completo haciendo GET por academic space
        final assignments = await getByAcademicSpace(
          request.idAcademicSpace,
          accessToken,
        );
        // Buscar el que acabamos de crear (debe ser el último o el que coincida con el ID)
        final completeAssignment = assignments.firstWhere(
          (a) =>
              a.id == createdAssignment.id ||
              a.idResource == request.idResource,
          orElse: () => createdAssignment,
        );
        return completeAssignment;
      }

      return createdAssignment;
    } else {
      print('❌ Error creating assignment: ${response.body}');
      throw Exception('Error al crear asignación: ${response.statusCode}');
    }
  }

  /// Actualizar una asignación
  Future<ResourceAssignmentModel> update(
    int id,
    ResourceAssignmentCreateRequest request,
    String accessToken,
  ) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resource-assignments/$id';

    print('✏️ Updating resource assignment $id at: $url');
    print('✏️ Request data: ${request.toJson()}');

    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    print('🔗 Update response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('✅ Assignment updated successfully');
      return ResourceAssignmentModel.fromJson(jsonDecode(response.body));
    } else {
      print('❌ Error updating assignment: ${response.body}');
      throw Exception('Error al actualizar asignación: ${response.statusCode}');
    }
  }

  /// Eliminar una asignación
  Future<void> delete(int id, String accessToken) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resource-assignments/$id';

    print('🗑️ Deleting resource assignment at: $url');

    final response = await client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('🗑️ Delete response status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('✅ Assignment deleted successfully');
    } else {
      print('❌ Error deleting assignment: ${response.body}');
      throw Exception('Error al eliminar asignación: ${response.statusCode}');
    }
  }
}
