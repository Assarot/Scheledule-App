import '../../domain/entity/course.dart';
import '../../domain/entity/teacher.dart';
import '../../domain/usescases/get_courses_usecase.dart';
import '../../domain/usescases/manage_course_usecase.dart';
import '../../domain/usescases/get_course_management_data_usecase.dart';
import '../../domain/usescases/get_teachers_usecase.dart';
import '../repository_impl/course_repository_impl.dart';
import '../repository_impl/course_management_repository_impl.dart';
import '../repository_impl/teacher_repository_impl.dart';
import '../datasources/course_remote_datasource.dart';
import '../datasources/course_management_remote_datasource.dart';

class CourseService {
  late final GetCoursesUseCase _getCoursesUseCase;
  late final CreateCourseUseCase _createCourseUseCase;
  late final UpdateCourseUseCase _updateCourseUseCase;
  late final DeleteCourseUseCase _deleteCourseUseCase;
  late final GetCourseTypesUseCase _getCourseTypesUseCase;
  late final GetPlansUseCase _getPlansUseCase;
  late final GetGroupsUseCase _getGroupsUseCase;
  late final GetTeachersUseCase _getTeachersUseCase;

  CourseService() {
    // Inicializar datasources
    final courseRemoteDataSource = CourseRemoteDataSource();
    final courseManagementRemoteDataSource = CourseManagementRemoteDataSource();

    // Inicializar repositorios
    final courseRepository = CourseRepositoryImpl(
      remoteDataSource: courseRemoteDataSource,
    );
    final courseManagementRepository = CourseManagementRepositoryImpl(
      remoteDataSource: courseManagementRemoteDataSource,
    );
    final teacherRepository = TeacherRepositoryImpl(
      remoteDataSource: courseManagementRemoteDataSource,
    );

    // Inicializar use cases
    _getCoursesUseCase = GetCoursesUseCase(repository: courseRepository);
    _createCourseUseCase = CreateCourseUseCase(repository: courseRepository);
    _updateCourseUseCase = UpdateCourseUseCase(repository: courseRepository);
    _deleteCourseUseCase = DeleteCourseUseCase(repository: courseRepository);
    _getCourseTypesUseCase = GetCourseTypesUseCase(repository: courseManagementRepository);
    _getPlansUseCase = GetPlansUseCase(repository: courseManagementRepository);
    _getGroupsUseCase = GetGroupsUseCase(repository: courseManagementRepository);
    
    // Usar el repositorio real de profesores
    _getTeachersUseCase = GetTeachersUseCase(repository: teacherRepository);
  }

  // CRUD de Cursos
  Future<List<Course>> getAllCourses() async {
    return await _getCoursesUseCase.call();
  }

  Future<Course> createCourse(Course course) async {
    return await _createCourseUseCase.call(course);
  }

  Future<Course> updateCourse(int id, Course course) async {
    return await _updateCourseUseCase.call(id, course);
  }

  Future<void> deleteCourse(int id) async {
    await _deleteCourseUseCase.call(id);
  }

  // Datos de soporte
  Future<List<CourseType>> getCourseTypes() async {
    return await _getCourseTypesUseCase.call();
  }

  Future<List<Plan>> getPlans() async {
    return await _getPlansUseCase.call();
  }

  Future<List<Group>> getGroups() async {
    return await _getGroupsUseCase.call();
  }

  Future<List<Teacher>> getTeachers() async {
    return await _getTeachersUseCase.call();
  }

  // Filtros y búsqueda (implementación local por ahora)
  List<Course> filterCourses(List<Course> courses, {
    String? search,
    int? courseTypeId,
    int? planId,
    String? sortBy,
    bool ascending = true,
  }) {
    var filtered = courses;

    // Filtro por búsqueda
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((course) {
        return course.name.toLowerCase().contains(search.toLowerCase()) ||
               course.code.toLowerCase().contains(search.toLowerCase()) ||
               course.description.toLowerCase().contains(search.toLowerCase());
      }).toList();
    }

    // Filtro por tipo de curso
    if (courseTypeId != null) {
      filtered = filtered.where((course) => 
          course.courseType.idCourseType == courseTypeId).toList();
    }

    // Filtro por plan
    if (planId != null) {
      filtered = filtered.where((course) => 
          course.plan.idPlan == planId).toList();
    }

    // Ordenamiento
    if (sortBy != null) {
      filtered.sort((a, b) {
        int comparison = 0;
        switch (sortBy) {
          case 'name':
            comparison = a.name.compareTo(b.name);
            break;
          case 'code':
            comparison = a.code.compareTo(b.code);
            break;
          case 'courseType':
            comparison = a.courseType.name.compareTo(b.courseType.name);
            break;
          case 'plan':
            comparison = a.plan.name.compareTo(b.plan.name);
            break;
          default:
            comparison = a.name.compareTo(b.name);
        }
        return ascending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  // Estadísticas (mock por ahora)
  Map<String, int> getCourseStatistics(List<Course> courses) {
    final stats = <String, int>{};
    
    // Total de cursos
    stats['total'] = courses.length;
    
    // Cursos por tipo
    final typeGroups = <String, int>{};
    for (final course in courses) {
      final typeName = course.courseType.name;
      typeGroups[typeName] = (typeGroups[typeName] ?? 0) + 1;
    }
    
    // Cursos por plan
    final planGroups = <String, int>{};
    for (final course in courses) {
      final planName = course.plan.name;
      planGroups[planName] = (planGroups[planName] ?? 0) + 1;
    }
    
    stats.addAll(typeGroups);
    stats.addAll(planGroups);
    
    return stats;
  }



}