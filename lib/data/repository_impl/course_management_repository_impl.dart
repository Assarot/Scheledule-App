import '../../domain/entity/course.dart';
import '../../domain/repository/course_management_repository.dart';
import '../datasources/course_management_remote_datasource.dart';

class CourseManagementRepositoryImpl implements CourseManagementRepository {
  final CourseManagementRemoteDataSource remoteDataSource;

  CourseManagementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CourseType>> getAllCourseTypes() async {
    try {
      final models = await remoteDataSource.getAllCourseTypes();
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Error al obtener tipos de curso: $e');
    }
  }

  @override
  Future<List<Plan>> getAllPlans() async {
    try {
      final models = await remoteDataSource.getAllPlans();
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Error al obtener planes: $e');
    }
  }

  @override
  Future<List<Group>> getAllGroups() async {
    try {
      final models = await remoteDataSource.getAllGroups();
      return models.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Error al obtener grupos: $e');
    }
  }

  @override
  Future<CourseType> getCourseTypeById(int id) async {
    try {
      final model = await remoteDataSource.getCourseTypeById(id);
      return model.toDomain();
    } catch (e) {
      throw Exception('Error al obtener tipo de curso: $e');
    }
  }

  @override
  Future<Plan> getPlanById(int id) async {
    try {
      final model = await remoteDataSource.getPlanById(id);
      return model.toDomain();
    } catch (e) {
      throw Exception('Error al obtener plan: $e');
    }
  }

  @override
  Future<Group> getGroupById(int id) async {
    try {
      final model = await remoteDataSource.getGroupById(id);
      return model.toDomain();
    } catch (e) {
      throw Exception('Error al obtener grupo: $e');
    }
  }
}