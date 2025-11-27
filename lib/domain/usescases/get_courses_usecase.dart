import '../entity/course.dart';
import '../repository/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository repository;

  GetCoursesUseCase({required this.repository});

  Future<List<Course>> call() async {
    return await repository.getAllCourses();
  }
}

class GetCourseByIdUseCase {
  final CourseRepository repository;

  GetCourseByIdUseCase({required this.repository});

  Future<Course> call(int id) async {
    return await repository.getCourseById(id);
  }
}