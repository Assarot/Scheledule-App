import '../../domain/entity/course.dart';

class CourseModel {
  final int idCourse;
  final String name;
  final String code;
  final String description;
  final String duration; // ISO 8601 format (PT300M)
  final String theoreticalHours; // ISO 8601 format
  final String practicalHours; // ISO 8601 format  
  final String totalHours; // ISO 8601 format
  final CourseTypeModel courseType;
  final PlanModel plan;
  final GroupModel group;

  CourseModel({
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

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      idCourse: json['idCourse'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      duration: json['duration'],
      theoreticalHours: json['theoreticalHours'],
      practicalHours: json['practicalHours'],
      totalHours: json['totalHours'],
      courseType: CourseTypeModel.fromJson(json['courseType']),
      plan: PlanModel.fromJson(json['plan']),
      group: GroupModel.fromJson(json['group']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCourse': idCourse,
      'name': name,
      'code': code,
      'description': description,
      'duration': duration,
      'theoreticalHours': theoreticalHours,
      'practicalHours': practicalHours,
      'totalHours': totalHours,
      'courseType': courseType.toJson(),
      'plan': plan.toJson(),
      'group': group.toJson(),
    };
  }

  Course toDomain() {
    return Course(
      idCourse: idCourse,
      name: name,
      code: code,
      description: description,
      duration: _parseDuration(duration),
      theoreticalHours: _parseDuration(theoreticalHours),
      practicalHours: _parseDuration(practicalHours),
      totalHours: _parseDuration(totalHours),
      courseType: courseType.toDomain(),
      plan: plan.toDomain(),
      group: group.toDomain(),
    );
  }

  static CourseModel fromDomain(Course course) {
    return CourseModel(
      idCourse: course.idCourse,
      name: course.name,
      code: course.code,
      description: course.description,
      duration: _formatDuration(course.duration),
      theoreticalHours: _formatDuration(course.theoreticalHours),
      practicalHours: _formatDuration(course.practicalHours),
      totalHours: _formatDuration(course.totalHours),
      courseType: CourseTypeModel.fromDomain(course.courseType),
      plan: PlanModel.fromDomain(course.plan),
      group: GroupModel.fromDomain(course.group),
    );
  }

  static Duration _parseDuration(String duration) {
    // Parse ISO 8601 duration format (PT300M, PT180H)
    if (duration.startsWith('PT') && duration.endsWith('M')) {
      final minutes = int.parse(duration.substring(2, duration.length - 1));
      return Duration(minutes: minutes);
    } else if (duration.startsWith('PT') && duration.endsWith('H')) {
      final hours = int.parse(duration.substring(2, duration.length - 1));
      return Duration(hours: hours);
    }
    return Duration.zero;
  }

  static String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return 'PT${duration.inHours}H';
    } else {
      return 'PT${duration.inMinutes}M';
    }
  }
}

class CourseTypeModel {
  final int idCourseType;
  final String name;

  CourseTypeModel({
    required this.idCourseType,
    required this.name,
  });

  factory CourseTypeModel.fromJson(Map<String, dynamic> json) {
    return CourseTypeModel(
      idCourseType: json['idCourseType'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCourseType': idCourseType,
      'name': name,
    };
  }

  CourseType toDomain() {
    return CourseType(
      idCourseType: idCourseType,
      name: name,
    );
  }

  static CourseTypeModel fromDomain(CourseType courseType) {
    return CourseTypeModel(
      idCourseType: courseType.idCourseType,
      name: courseType.name,
    );
  }
}

class PlanModel {
  final int idPlan;
  final String name;

  PlanModel({
    required this.idPlan,
    required this.name,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      idPlan: json['idPlan'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPlan': idPlan,
      'name': name,
    };
  }

  Plan toDomain() {
    return Plan(
      idPlan: idPlan,
      name: name,
    );
  }

  static PlanModel fromDomain(Plan plan) {
    return PlanModel(
      idPlan: plan.idPlan,
      name: plan.name,
    );
  }
}

class GroupModel {
  final int idGroup;
  final String groupNumber;
  final int capacity;
  final CycleModel cycle;

  GroupModel({
    required this.idGroup,
    required this.groupNumber,
    required this.capacity,
    required this.cycle,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      idGroup: json['idGroup'],
      groupNumber: json['groupNumber'],
      capacity: json['capacity'],
      cycle: CycleModel.fromJson(json['cycle']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idGroup': idGroup,
      'groupNumber': groupNumber,
      'capacity': capacity,
      'cycle': cycle.toJson(),
    };
  }

  Group toDomain() {
    return Group(
      idGroup: idGroup,
      groupNumber: groupNumber,
      capacity: capacity,
      cycle: cycle.toDomain(),
    );
  }

  static GroupModel fromDomain(Group group) {
    return GroupModel(
      idGroup: group.idGroup,
      groupNumber: group.groupNumber,
      capacity: group.capacity,
      cycle: CycleModel.fromDomain(group.cycle),
    );
  }
}

class CycleModel {
  final int idCycle;
  final String name;
  final ProfessionalSchoolModel professionalSchool;

  CycleModel({
    required this.idCycle,
    required this.name,
    required this.professionalSchool,
  });

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      idCycle: json['idCycle'],
      name: json['name'],
      professionalSchool: ProfessionalSchoolModel.fromJson(json['professionalSchool']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCycle': idCycle,
      'name': name,
      'professionalSchool': professionalSchool.toJson(),
    };
  }

  Cycle toDomain() {
    return Cycle(
      idCycle: idCycle,
      name: name,
      professionalSchool: professionalSchool.toDomain(),
    );
  }

  static CycleModel fromDomain(Cycle cycle) {
    return CycleModel(
      idCycle: cycle.idCycle,
      name: cycle.name,
      professionalSchool: ProfessionalSchoolModel.fromDomain(cycle.professionalSchool),
    );
  }
}

class ProfessionalSchoolModel {
  final int idProfessionalSchool;
  final String name;

  ProfessionalSchoolModel({
    required this.idProfessionalSchool,
    required this.name,
  });

  factory ProfessionalSchoolModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalSchoolModel(
      idProfessionalSchool: json['idProfessionalSchool'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProfessionalSchool': idProfessionalSchool,
      'name': name,
    };
  }

  ProfessionalSchool toDomain() {
    return ProfessionalSchool(
      idProfessionalSchool: idProfessionalSchool,
      name: name,
    );
  }

  static ProfessionalSchoolModel fromDomain(ProfessionalSchool professionalSchool) {
    return ProfessionalSchoolModel(
      idProfessionalSchool: professionalSchool.idProfessionalSchool,
      name: professionalSchool.name,
    );
  }
}