import '../entity/teacher.dart';
import '../entity/course.dart';

abstract class TeacherRepository {
  Future<List<Teacher>> getAllTeachers();
  Future<Teacher> getTeacherById(int id);
  Future<Teacher> createTeacher(Teacher teacher);
  Future<Teacher> updateTeacher(int id, Teacher teacher);
  Future<void> deleteTeacher(int id);
  Future<List<Course>> getTeacherCourses(int teacherId);
}