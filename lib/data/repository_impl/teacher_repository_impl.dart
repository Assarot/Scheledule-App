import '../../domain/entity/teacher.dart';
import '../../domain/entity/course.dart';
import '../../domain/repository/teacher_repository.dart';
import '../datasources/course_management_remote_datasource.dart';
import '../models/teacher_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final CourseManagementRemoteDataSource remoteDataSource;

  TeacherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Teacher>> getAllTeachers() async {
    try {
      final teacherModels = await remoteDataSource.getAllTeachers();
      return teacherModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Error al obtener profesores: $e');
    }
  }

  @override
  Future<Teacher> getTeacherById(int id) async {
    try {
      final teacherModel = await remoteDataSource.getTeacherById(id);
      return teacherModel.toDomain();
    } catch (e) {
      throw Exception('Error al obtener profesor: $e');
    }
  }

  @override
  Future<Teacher> createTeacher(Teacher teacher) async {
    try {
      final teacherModel = await remoteDataSource.createTeacher(
        TeacherModel.fromDomain(teacher),
      );
      return teacherModel.toDomain();
    } catch (e) {
      throw Exception('Error al crear profesor: $e');
    }
  }

  @override
  Future<Teacher> updateTeacher(int id, Teacher teacher) async {
    try {
      final teacherModel = await remoteDataSource.updateTeacher(
        id,
        TeacherModel.fromDomain(teacher),
      );
      return teacherModel.toDomain();
    } catch (e) {
      throw Exception('Error al actualizar profesor: $e');
    }
  }

  @override
  Future<void> deleteTeacher(int id) async {
    try {
      await remoteDataSource.deleteTeacher(id);
    } catch (e) {
      throw Exception('Error al eliminar profesor: $e');
    }
  }

  @override
  Future<List<Course>> getTeacherCourses(int teacherId) async {
    try {
      // Implementar cuando tengas el endpoint de asignaciones
      return [];
    } catch (e) {
      throw Exception('Error al obtener cursos del profesor: $e');
    }
  }
}