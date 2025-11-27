class Course {
  final int idCourse;
  final String name;
  final String code;
  final String description;
  final Duration duration;
  final Duration theoreticalHours;
  final Duration practicalHours;
  final Duration totalHours;
  final CourseType courseType;
  final Plan plan;
  final Group group;

  const Course({
    required this.idCourse,
    required this.name,
    required this.code,
    required this.description,
    required this.duration,
    required this.theoreticalHours,
    required this.practicalHours,
    required this.totalHours,
    required this.courseType,
    required this.plan,
    required this.group,
  });

  /// Calcula los créditos basándose en las horas totales
  /// Típicamente 1 crédito = 16-20 horas académicas
  int get credits => (totalHours.inHours / 18).ceil();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          idCourse == other.idCourse;

  @override
  int get hashCode => idCourse.hashCode;

  @override
  String toString() {
    return 'Course{idCourse: $idCourse, name: $name, code: $code}';
  }
}

class CourseType {
  final int idCourseType;
  final String name;

  const CourseType({
    required this.idCourseType,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseType &&
          runtimeType == other.runtimeType &&
          idCourseType == other.idCourseType;

  @override
  int get hashCode => idCourseType.hashCode;
}

class Plan {
  final int idPlan;
  final String name;

  const Plan({
    required this.idPlan,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plan &&
          runtimeType == other.runtimeType &&
          idPlan == other.idPlan;

  @override
  int get hashCode => idPlan.hashCode;
}

class Group {
  final int idGroup;
  final String groupNumber;
  final int capacity;
  final Cycle cycle;

  const Group({
    required this.idGroup,
    required this.groupNumber,
    required this.capacity,
    required this.cycle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          idGroup == other.idGroup;

  @override
  int get hashCode => idGroup.hashCode;
}

class Cycle {
  final int idCycle;
  final String name;
  final ProfessionalSchool professionalSchool;

  const Cycle({
    required this.idCycle,
    required this.name,
    required this.professionalSchool,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cycle &&
          runtimeType == other.runtimeType &&
          idCycle == other.idCycle;

  @override
  int get hashCode => idCycle.hashCode;
}

class ProfessionalSchool {
  final int idProfessionalSchool;
  final String name;

  const ProfessionalSchool({
    required this.idProfessionalSchool,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessionalSchool &&
          runtimeType == other.runtimeType &&
          idProfessionalSchool == other.idProfessionalSchool;

  @override
  int get hashCode => idProfessionalSchool.hashCode;
}