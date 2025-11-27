import '../entity/teacher.dart';
import '../repository/teacher_repository.dart';

class GetTeachersUseCase {
  final TeacherRepository repository;

  GetTeachersUseCase({required this.repository});

  Future<List<Teacher>> call() async {
    return await repository.getAllTeachers();
  }
}