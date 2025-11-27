import '../entity/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getAllCourses();
  Future<Course> getCourseById(int id);
  Future<Course> createCourse(Course course);
  Future<Course> updateCourse(int id, Course course);
  Future<void> deleteCourse(int id);
  Future<List<Course>> searchCourses(String query);
  Future<List<Course>> getCoursesByType(int courseTypeId);
  Future<List<Course>> getCoursesByPlan(int planId);
}