import '../../domain/entity/course.dart';
import '../../domain/repository/course_repository.dart';
import '../datasources/course_remote_datasource.dart';
import '../models/course_request.dart';
import '../models/course_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Course>> getAllCourses() async {
    try {
      final courseModels = await remoteDataSource.getAllCourses();
      return courseModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Error al obtener cursos: $e');
    }
  }

  @override
  Future<Course> getCourseById(int id) async {
    try {
      final courseModel = await remoteDataSource.getCourseById(id);
      return courseModel.toDomain();
    } catch (e) {
      throw Exception('Error al obtener curso: $e');
    }
  }

  @override
  Future<Course> createCourse(Course course) async {
    try {
      final request = CourseCreateRequest(
        name: course.name,
        code: course.code,
        description: course.description,
        duration: course.duration.inMinutes,
        theoreticalHours: course.theoreticalHours.inMinutes,
        practicalHours: course.practicalHours.inMinutes,
        idCourseType: course.courseType.idCourseType,
        idPlan: course.plan.idPlan,
        idGroup: course.group.idGroup,
      );
      
      final courseModel = await remoteDataSource.createCourse(request);
      return courseModel.toDomain();
    } catch (e) {
      throw Exception('Error al crear curso: $e');
    }
  }

  @override
  Future<Course> updateCourse(int id, Course course) async {
    try {
      final request = CourseUpdateRequest(
        name: course.name,
        code: course.code,
        description: course.description,
        duration: course.duration.inMinutes,
        theoreticalHours: course.theoreticalHours.inMinutes,
        practicalHours: course.practicalHours.inMinutes,
        idCourseType: course.courseType.idCourseType,
        idPlan: course.plan.idPlan,
        idGroup: course.group.idGroup,
      );
      
      final courseModel = await remoteDataSource.updateCourse(id, request);
      return courseModel.toDomain();
    } catch (e) {
      throw Exception('Error al actualizar curso: $e');
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    try {
      await remoteDataSource.deleteCourse(id);
    } catch (e) {
      throw Exception('Error al eliminar curso: $e');
    }
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    // Por ahora filtra localmente, implementar endpoint de búsqueda en backend
    try {
      final allCourses = await getAllCourses();
      return allCourses.where((course) {
        return course.name.toLowerCase().contains(query.toLowerCase()) ||
               course.code.toLowerCase().contains(query.toLowerCase()) ||
               course.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Error al buscar cursos: $e');
    }
  }

  @override
  Future<List<Course>> getCoursesByType(int courseTypeId) async {
    // Por ahora filtra localmente, implementar endpoint específico en backend
    try {
      final allCourses = await getAllCourses();
      return allCourses.where((course) => 
          course.courseType.idCourseType == courseTypeId).toList();
    } catch (e) {
      throw Exception('Error al obtener cursos por tipo: $e');
    }
  }

  @override
  Future<List<Course>> getCoursesByPlan(int planId) async {
    // Por ahora filtra localmente, implementar endpoint específico en backend
    try {
      final allCourses = await getAllCourses();
      return allCourses.where((course) => 
          course.plan.idPlan == planId).toList();
    } catch (e) {
      throw Exception('Error al obtener cursos por plan: $e');
    }
  }
}