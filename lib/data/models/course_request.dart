class CourseCreateRequest {
  final String name;
  final String code;
  final String description;
  final int duration; // En minutos
  final int theoreticalHours; // En minutos
  final int practicalHours; // En minutos
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
    // Convertir minutos a horas para el total
    return ((theoreticalHours + practicalHours) / 60).ceil();
  }
}

class CourseUpdateRequest {
  final String name;
  final String code;
  final String description;
  final int duration;
  final int theoreticalHours;
  final int practicalHours;
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
    return ((theoreticalHours + practicalHours) / 60).ceil();
  }
}