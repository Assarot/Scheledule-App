import '../entity/course.dart';

abstract class CourseManagementRepository {
  Future<List<CourseType>> getAllCourseTypes();
  Future<List<Plan>> getAllPlans();
  Future<List<Group>> getAllGroups();
  Future<CourseType> getCourseTypeById(int id);
  Future<Plan> getPlanById(int id);
  Future<Group> getGroupById(int id);
}