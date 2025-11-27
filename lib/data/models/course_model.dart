import '../../domain/entity/course.dart';

// Helper function para parsear IDs de forma segura
int _parseId(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    if (value.isEmpty || value == 'null') return 0;
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

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
      idCourse: _parseId(json['idCourse']),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      duration: json['duration']?.toString() ?? 'PT0H',
      theoreticalHours: json['theoreticalHours']?.toString() ?? 'PT0H',
      practicalHours: json['practicalHours']?.toString() ?? 'PT0H',
      totalHours: json['totalHours']?.toString() ?? 'PT0H',
      courseType: CourseTypeModel.fromJson(json['courseType'] ?? {}),
      plan: PlanModel.fromJson(json['plan'] ?? {}),
      group: GroupModel.fromJson(json['group'] ?? {}),
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
    try {
      // Parse ISO 8601 duration format (PT300M, PT180H, PT3H3M, PT1M1S)
      if (duration.isEmpty || duration == 'null') {
        return Duration.zero;
      }
      
      if (!duration.startsWith('PT')) {
        // Try to parse as a direct number (minutes)
        final directMinutes = int.tryParse(duration);
        if (directMinutes != null) {
          return Duration(minutes: directMinutes);
        }
        return Duration.zero;
      }
      
      // Remove 'PT' prefix
      String timeStr = duration.substring(2);
      
      int hours = 0;
      int minutes = 0;
      int seconds = 0;
      
      // Parse hours (PT3H or PT3H3M)
      if (timeStr.contains('H')) {
        final parts = timeStr.split('H');
        hours = int.tryParse(parts[0]) ?? 0;
        timeStr = parts.length > 1 ? parts[1] : '';
      }
      
      // Parse minutes (PT3M or PT1M1S)
      if (timeStr.contains('M')) {
        final parts = timeStr.split('M');
        minutes = int.tryParse(parts[0]) ?? 0;
        timeStr = parts.length > 1 ? parts[1] : '';
      }
      
      // Parse seconds (PT1S)
      if (timeStr.contains('S')) {
        final parts = timeStr.split('S');
        seconds = int.tryParse(parts[0]) ?? 0;
      }
      
      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
      
    } catch (e) {
      print('❌ Error parsing duration "$duration": $e');
      return Duration.zero;
    }
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
      idCourseType: _parseId(json['idCourseType']),
      name: json['name']?.toString() ?? 'Tipo no definido',
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
      idPlan: _parseId(json['idPlan']),
      name: json['name']?.toString() ?? 'Plan no definido',
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
  final CycleModel? cycle;

  GroupModel({
    required this.idGroup,
    required this.groupNumber,
    required this.capacity,
    this.cycle,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      idGroup: _parseId(json['idGroup']),
      groupNumber: json['groupNumber']?.toString() ?? '',
      capacity: _parseId(json['capacity']),
      cycle: json['cycle'] != null ? CycleModel.fromJson(json['cycle']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idGroup': idGroup,
      'groupNumber': groupNumber,
      'capacity': capacity,
      'cycle': cycle?.toJson(),
    };
  }

  Group toDomain() {
    return Group(
      idGroup: idGroup,
      groupNumber: groupNumber,
      capacity: capacity,
      cycle: cycle?.toDomain(),
    );
  }

  static GroupModel fromDomain(Group group) {
    return GroupModel(
      idGroup: group.idGroup,
      groupNumber: group.groupNumber,
      capacity: group.capacity,
      cycle: group.cycle != null ? CycleModel.fromDomain(group.cycle!) : null,
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
      idCycle: _parseId(json['idCycle']),
      name: json['name']?.toString() ?? '',
      professionalSchool: json['professionalSchool'] != null 
        ? ProfessionalSchoolModel.fromJson(json['professionalSchool']) 
        : ProfessionalSchoolModel(idProfessionalSchool: 0, name: 'No definida'),
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
      idProfessionalSchool: _parseId(json['idProfessionalSchool']),
      name: json['name']?.toString() ?? 'No definida',
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