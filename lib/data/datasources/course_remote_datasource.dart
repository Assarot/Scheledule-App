import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../models/course_request.dart';
import '../../utils/api_config.dart';
import '../../utils/authenticated_http_client.dart';
import 'auth_local_datasource.dart';
import 'auth_remote_datasource.dart';

class CourseRemoteDataSource {
  final http.Client client;

  CourseRemoteDataSource({http.Client? client})
      : client = client ?? AuthenticatedHttpClient(
          localDataSource: AuthLocalDataSource(),
          remoteDataSource: AuthRemoteDataSource(),
        );

  /// Obtener todos los cursos
  Future<List<CourseModel>> getAllCourses() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.coursesPath}'),
      headers: {'Content-Type': 'application/json'},
    );

    print('🎓 GET Courses - Status: ${response.statusCode}');
    print('🎓 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CourseModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener cursos: ${response.statusCode}');
    }
  }

  /// Obtener curso por ID
  Future<CourseModel> getCourseById(int id) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.coursesPath}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    print('🎓 GET Course by ID - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener curso: ${response.statusCode}');
    }
  }

  /// Crear nuevo curso
  Future<CourseModel> createCourse(CourseCreateRequest request) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.coursesPath}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    print('🎓 POST Course - Status: ${response.statusCode}');
    print('🎓 Request body: ${jsonEncode(request.toJson())}');
    print('🎓 Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear curso: ${response.statusCode} - ${response.body}');
    }
  }

  /// Actualizar curso existente
  Future<CourseModel> updateCourse(int id, CourseUpdateRequest request) async {
    final response = await client.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.coursesPath}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    print('🎓 PUT Course - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar curso: ${response.statusCode}');
    }
  }

  /// Eliminar curso
  Future<void> deleteCourse(int id) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.coursesPath}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    print('🎓 DELETE Course - Status: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar curso: ${response.statusCode}');
    }
  }
}