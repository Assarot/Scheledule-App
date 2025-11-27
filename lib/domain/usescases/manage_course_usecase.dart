import '../entity/course.dart';
import '../repository/course_repository.dart';

class CreateCourseUseCase {
  final CourseRepository repository;

  CreateCourseUseCase({required this.repository});

  Future<Course> call(Course course) async {
    return await repository.createCourse(course);
  }
}

class UpdateCourseUseCase {
  final CourseRepository repository;

  UpdateCourseUseCase({required this.repository});

  Future<Course> call(int id, Course course) async {
    return await repository.updateCourse(id, course);
  }
}

class DeleteCourseUseCase {
  final CourseRepository repository;

  DeleteCourseUseCase({required this.repository});

  Future<void> call(int id) async {
    await repository.deleteCourse(id);
  }
}