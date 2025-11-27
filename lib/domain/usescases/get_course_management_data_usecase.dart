import '../entity/course.dart';
import '../repository/course_management_repository.dart';

class GetCourseTypesUseCase {
  final CourseManagementRepository repository;

  GetCourseTypesUseCase({required this.repository});

  Future<List<CourseType>> call() async {
    return await repository.getAllCourseTypes();
  }
}

class GetPlansUseCase {
  final CourseManagementRepository repository;

  GetPlansUseCase({required this.repository});

  Future<List<Plan>> call() async {
    return await repository.getAllPlans();
  }
}

class GetGroupsUseCase {
  final CourseManagementRepository repository;

  GetGroupsUseCase({required this.repository});

  Future<List<Group>> call() async {
    return await repository.getAllGroups();
  }
}