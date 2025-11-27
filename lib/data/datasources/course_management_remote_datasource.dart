import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../models/teacher_model.dart';
import '../models/teacher_request.dart';
import '../../utils/api_config.dart';
import '../../utils/authenticated_http_client.dart';
import 'auth_local_datasource.dart';
import 'auth_remote_datasource.dart';

class CourseManagementRemoteDataSource {
  final http.Client client;

  CourseManagementRemoteDataSource({http.Client? client})
      : client = client ?? AuthenticatedHttpClient(
          localDataSource: AuthLocalDataSource(),
          remoteDataSource: AuthRemoteDataSource(),
        );

  /// Obtener todos los tipos de curso
  Future<List<CourseTypeModel>> getAllCourseTypes() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.courseTypesPath}'),
      headers: {'Content-Type': 'application/json'},
    );

    print('📋 GET Course Types - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CourseTypeModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener tipos de curso: ${response.statusCode}');
    }
  }

  /// Obtener todos los profesores
  Future<List<TeacherModel>> getAllTeachers() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.teachersPath}'),
      headers: {'Content-Type': 'application/json'},
    );

    print('👨‍🏫 GET Teachers - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => TeacherModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener profesores: ${response.statusCode}');
    }
  }

  /// Obtener todos los planes
  Future<List<PlanModel>> getAllPlans() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.plansPath}'),
      headers: {'Content-Type': 'application/json'},
    );

    print('📚 GET Plans - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => PlanModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener planes: ${response.statusCode}');
    }
  }

  /// Obtener todos los grupos (necesitarás implementar endpoint en backend)
  Future<List<GroupModel>> getAllGroups() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.groupsPath}'),
      headers: {'Content-Type': 'application/json'},
    );

    print('👥 GET Groups - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener grupos: ${response.statusCode}');
    }
  }

  /// Obtener tipo de curso por ID
  Future<CourseTypeModel> getCourseTypeById(int id) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.courseTypesPath}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return CourseTypeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener tipo de curso: ${response.statusCode}');
    }
  }

  /// Obtener plan por ID
  Future<PlanModel> getPlanById(int id) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.plansPath}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PlanModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener plan: ${response.statusCode}');
    }
  }

  /// Obtener grupo por ID
  Future<GroupModel> getGroupById(int id) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.groupsPath}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return GroupModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener grupo: ${response.statusCode}');
    }
  }

  /// Obtener profesor por ID
  Future<TeacherModel> getTeacherById(int id) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.teachersPath}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return TeacherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener profesor: ${response.statusCode}');
    }
  }

  /// Crear nuevo profesor
  Future<TeacherModel> createTeacher(TeacherCreateRequest request) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.teachersPath}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    print('👨‍🏫 POST Teacher - Status: ${response.statusCode}');
    print('👨‍🏫 Request body: ${jsonEncode(request.toJson())}');
    print('👨‍🏫 Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return TeacherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear profesor: ${response.statusCode} - ${response.body}');
    }
  }

  /// Actualizar profesor existente
  Future<TeacherModel> updateTeacher(int id, TeacherUpdateRequest request) async {
    final response = await client.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.teachersPath}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    print('👨‍🏫 PUT Teacher - Status: ${response.statusCode}');
    print('👨‍🏫 Request body: ${jsonEncode(request.toJson())}');
    print('👨‍🏫 Response body: ${response.body}');

    if (response.statusCode == 200) {
      return TeacherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar profesor: ${response.statusCode} - ${response.body}');
    }
  }

  /// Eliminar profesor
  Future<void> deleteTeacher(int id) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.teachersPath}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar profesor: ${response.statusCode}');
    }
  }
}