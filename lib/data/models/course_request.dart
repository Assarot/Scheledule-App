class CourseCreateRequest {
  final String name;
  final String code;
  final String description;
  final int duration; // En minutos (backend)
  final int theoreticalHours; // En minutos (backend)
  final int practicalHours; // En minutos (backend)
  final int idCourseType;
  final int idPlan;
  final int idGroup;

  CourseCreateRequest({
    required this.name,
    required this.code,
    required this.description,
    required this.duration,
    required this.theoreticalHours,
    required this.practicalHours,
    required this.idCourseType,
    required this.idPlan,
    required this.idGroup,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'duration': duration,
      'theoreticalHours': theoreticalHours,
      'practicalHours': practicalHours,
      'totalHours': _calculateTotalHours(),
      'idCourseType': idCourseType,
      'idPlan': idPlan,
      'idGroup': idGroup,
    };
  }

  int _calculateTotalHours() {
    // Total en minutos (teoricas + prácticas)
    return theoreticalHours + practicalHours;
  }
}

class CourseUpdateRequest {
  final String name;
  final String code;
  final String description;
  final int duration; // En minutos (backend)
  final int theoreticalHours; // En minutos (backend) 
  final int practicalHours; // En minutos (backend)
  final int idCourseType;
  final int idPlan;
  final int idGroup;

  CourseUpdateRequest({
    required this.name,
    required this.code,
    required this.description,
    required this.duration,
    required this.theoreticalHours,
    required this.practicalHours,
    required this.idCourseType,
    required this.idPlan,
    required this.idGroup,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'duration': duration,
      'theoreticalHours': theoreticalHours,
      'practicalHours': practicalHours,
      'totalHours': _calculateTotalHours(),
      'idCourseType': idCourseType,
      'idPlan': idPlan,
      'idGroup': idGroup,
    };
  }

  int _calculateTotalHours() {
    // Total en minutos (teoricas + prácticas)
    return theoreticalHours + practicalHours;
  }
}