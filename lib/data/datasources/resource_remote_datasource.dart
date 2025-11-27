import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/resource_model.dart';
import '../../utils/api_config.dart';

class ResourceRemoteDataSource {
  final http.Client client;

  ResourceRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener todos los recursos
  Future<List<ResourceModel>> getAll(String accessToken) async {
    final url = '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resources';

    print('📦 Fetching resources from: $url');

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('📦 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('📦 Response body: ${response.body}');
      final List<dynamic> jsonList = jsonDecode(response.body);
      print('📦 Found ${jsonList.length} resources in response');

      if (jsonList.isNotEmpty) {
        print('📦 First item structure: ${jsonList.first}');
      }

      return jsonList.map((json) => ResourceModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener recursos: ${response.statusCode}');
    }
  }

  /// Obtener un recurso por ID
  Future<ResourceModel> getById(int id, String accessToken) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resources/$id';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return ResourceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener recurso: ${response.statusCode}');
    }
  }

  /// Crear un nuevo recurso
  Future<ResourceModel> create(
    ResourceCreateRequest request,
    String accessToken, {
    String? imagePath,
  }) async {
    final url = '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resources';

    print('📤 Creating resource at: $url');
    print('📤 Request data: ${request.toJson()}');
    if (imagePath != null) print('📷 With image: $imagePath');

    // El backend espera multipart/form-data con @RequestPart
    final multipartRequest = http.MultipartRequest('POST', Uri.parse(url));

    // Headers
    multipartRequest.headers['Authorization'] = 'Bearer $accessToken';
    multipartRequest.headers['Accept'] = 'application/json';

    // Enviar los datos del recurso como multipart file con Content-Type application/json
    final resourceJson = utf8.encode(jsonEncode(request.toJson()));
    multipartRequest.files.add(
      http.MultipartFile.fromBytes(
        'resource',
        resourceJson,
        filename: 'resource.json',
        contentType: MediaType('application', 'json'),
      ),
    );

    // Agregar imagen si existe
    if (imagePath != null) {
      final imageFile = await http.MultipartFile.fromPath(
        'photo',
        imagePath,
        contentType: MediaType('image', 'jpeg'),
      );
      multipartRequest.files.add(imageFile);
      print('📷 Image added to request');
    }

    // Enviar la petición
    final streamedResponse = await client.send(multipartRequest);
    final response = await http.Response.fromStream(streamedResponse);

    print('📦 Create response status: ${response.statusCode}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Resource created successfully');

      // El backend responde con resourceType: null y state: null
      // Hacemos un GET para obtener el objeto completo
      try {
        final responseData = jsonDecode(response.body);
        final resourceId =
            responseData['idResource'] ?? responseData['id_resource'];

        if (resourceId != null) {
          print('🔄 Fetching complete resource data for ID: $resourceId');
          return await getById(resourceId as int, accessToken);
        } else {
          // Si no hay ID, devolver un objeto básico sin objetos anidados
          print('⚠️ No ID in response, returning partial resource');
          return ResourceModel.fromJson(responseData);
        }
      } catch (e) {
        print('⚠️ Error fetching complete resource: $e');
        // Si falla, devolver la respuesta original sin objetos anidados
        return ResourceModel.fromJson(jsonDecode(response.body));
      }
    } else {
      print('❌ Error creating resource: ${response.body}');
      throw Exception('Error al crear recurso: ${response.statusCode}');
    }
  }

  /// Actualizar un recurso
  Future<ResourceModel> update(
    int id,
    ResourceCreateRequest request,
    String accessToken, {
    String? imagePath,
  }) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resources/$id';

    print('📤 Updating resource $id at: $url');
    print('📤 Request data: ${request.toJson()}');
    if (imagePath != null) print('📷 With image: $imagePath');

    // El backend espera multipart/form-data con @RequestPart
    final multipartRequest = http.MultipartRequest('PUT', Uri.parse(url));

    // Headers
    multipartRequest.headers['Authorization'] = 'Bearer $accessToken';
    multipartRequest.headers['Accept'] = 'application/json';

    // Enviar los datos del recurso como multipart file con Content-Type application/json
    final resourceJson = utf8.encode(jsonEncode(request.toJson()));
    multipartRequest.files.add(
      http.MultipartFile.fromBytes(
        'resource',
        resourceJson,
        filename: 'resource.json',
        contentType: MediaType('application', 'json'),
      ),
    );

    // Agregar imagen si existe
    if (imagePath != null) {
      final imageFile = await http.MultipartFile.fromPath(
        'photo',
        imagePath,
        contentType: MediaType('image', 'jpeg'),
      );
      multipartRequest.files.add(imageFile);
      print('📷 Image added to request');
    }

    // Enviar la petición
    final streamedResponse = await client.send(multipartRequest);
    final response = await http.Response.fromStream(streamedResponse);

    print('📦 Update response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('✅ Resource updated successfully');

      // El backend responde con resourceType: null y state: null
      // Hacemos un GET para obtener el objeto completo
      try {
        print('🔄 Fetching complete resource data for ID: $id');
        return await getById(id, accessToken);
      } catch (e) {
        print('⚠️ Error fetching complete resource: $e');
        // Si falla, devolver la respuesta original sin objetos anidados
        return ResourceModel.fromJson(jsonDecode(response.body));
      }
    } else {
      print('❌ Error updating resource: ${response.body}');
      throw Exception('Error al actualizar recurso: ${response.statusCode}');
    }
  }

  /// Eliminar un recurso
  Future<void> delete(int id, String accessToken) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resources/$id';

    print('🗑️ Deleting resource $id');

    final response = await client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('📦 Delete response status: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      print('❌ Error deleting resource: ${response.body}');
      throw Exception('Error al eliminar recurso: ${response.statusCode}');
    }

    print('✅ Resource deleted successfully');
  }

  /// Obtener recursos por tipo
  Future<List<ResourceModel>> getByType(int typeId, String accessToken) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resources/type/$typeId';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ResourceModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener recursos por tipo: ${response.statusCode}',
      );
    }
  }

  /// Obtener recursos por estado
  Future<List<ResourceModel>> getByState(
    int stateId,
    String accessToken,
  ) async {
    final url =
        '${ApiConfig.baseUrl}/microservice-inventory/api/v1/resources/state/$stateId';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ResourceModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener recursos por estado: ${response.statusCode}',
      );
    }
  }
}
