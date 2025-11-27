import '../../domain/entity/course.dart';
import '../../domain/entity/teacher.dart';

class StatisticsService {
  
  /// Generar estadísticas generales de cursos
  CourseStatistics generateCourseStatistics(List<Course> courses) {
    final totalCourses = courses.length;
    
    // Estadísticas por tipo de curso
    final Map<String, int> coursesByType = {};
    for (final course in courses) {
      final typeName = course.courseType.name;
      coursesByType[typeName] = (coursesByType[typeName] ?? 0) + 1;
    }

    // Estadísticas por plan
    final Map<String, int> coursesByPlan = {};
    for (final course in courses) {
      final planName = course.plan.name;
      coursesByPlan[planName] = (coursesByPlan[planName] ?? 0) + 1;
    }

    // Estadísticas por escuela profesional
    final Map<String, int> coursesBySchool = {};
    for (final course in courses) {
      final schoolName = course.group.cycle?.professionalSchool?.name ?? 'Sin escuela';
      coursesBySchool[schoolName] = (coursesBySchool[schoolName] ?? 0) + 1;
    }

    // Distribución de horas y créditos
    int totalTheoreticalHours = 0;
    int totalPracticalHours = 0;
    int totalCredits = 0;
    for (final course in courses) {
      totalTheoreticalHours += course.theoreticalHours.inHours;
      totalPracticalHours += course.practicalHours.inHours;
      totalCredits += course.credits;
    }

    return CourseStatistics(
      totalCourses: totalCourses,
      totalCredits: totalCredits,
      coursesByType: coursesByType,
      coursesByPlan: coursesByPlan,
      coursesBySchool: coursesBySchool,
      totalTheoreticalHours: totalTheoreticalHours,
      totalPracticalHours: totalPracticalHours,
      averageTheoreticalHours: totalCourses > 0 ? totalTheoreticalHours / totalCourses : 0,
      averagePracticalHours: totalCourses > 0 ? totalPracticalHours / totalCourses : 0,
    );
  }

  /// Generar estadísticas de profesores
  TeacherStatistics generateTeacherStatistics(
    List<Teacher> teachers,
    List<Course> courses,
  ) {
    // Mock de asignaciones por ahora (implementar cuando tengas endpoint)
    final Map<int, List<Course>> teacherAssignments = _mockTeacherAssignments(teachers, courses);
    
    final Map<String, int> courseLoadDistribution = {};
    final Map<String, int> workloadDistribution = {
      'none': 0,
      'low': 0,
      'medium': 0,
      'high': 0,
    };
    int totalAssignments = 0;
    
    for (final entry in teacherAssignments.entries) {
      final courseCount = entry.value.length;
      totalAssignments += courseCount;
      
      final range = _getCourseLoadRange(courseCount);
      courseLoadDistribution[range] = (courseLoadDistribution[range] ?? 0) + 1;
      
      // Categorizar carga de trabajo
      if (courseCount == 0) {
        workloadDistribution['none'] = workloadDistribution['none']! + 1;
      } else if (courseCount <= 2) {
        workloadDistribution['low'] = workloadDistribution['low']! + 1;
      } else if (courseCount <= 4) {
        workloadDistribution['medium'] = workloadDistribution['medium']! + 1;
      } else {
        workloadDistribution['high'] = workloadDistribution['high']! + 1;
      }
    }

    return TeacherStatistics(
      totalTeachers: teachers.length,
      totalAssignments: totalAssignments,
      averageCoursesPerTeacher: teachers.isNotEmpty ? totalAssignments / teachers.length : 0,
      courseLoadDistribution: courseLoadDistribution,
      workloadDistribution: workloadDistribution,
      teacherAssignments: teacherAssignments,
    );
  }

  /// Mock temporal para asignaciones (reemplazar con datos reales)
  Map<int, List<Course>> _mockTeacherAssignments(List<Teacher> teachers, List<Course> courses) {
    final Map<int, List<Course>> assignments = {};
    
    for (int i = 0; i < teachers.length; i++) {
      final teacher = teachers[i];
      final assignedCourses = <Course>[];
      
      // Asignar algunos cursos de forma aleatoria
      final startIndex = (i * 2) % courses.length;
      final coursesToAssign = (i % 3) + 1; // 1-3 cursos por profesor
      
      for (int j = 0; j < coursesToAssign && (startIndex + j) < courses.length; j++) {
        assignedCourses.add(courses[startIndex + j]);
      }
      
      assignments[teacher.idTeacher] = assignedCourses;
    }
    
    return assignments;
  }

  String _getCourseLoadRange(int courseCount) {
    if (courseCount == 0) return '0 cursos';
    if (courseCount == 1) return '1 curso';
    if (courseCount <= 3) return '2-3 cursos';
    if (courseCount <= 5) return '4-5 cursos';
    return '6+ cursos';
  }

  /// Generar datos para gráficos
  List<ChartData> getCoursesByTypeChartData(Map<String, int> coursesByType) {
    return coursesByType.entries
        .map((entry) => ChartData(entry.key, entry.value.toDouble()))
        .toList();
  }

  List<ChartData> getCoursesByPlanChartData(Map<String, int> coursesByPlan) {
    return coursesByPlan.entries
        .map((entry) => ChartData(entry.key, entry.value.toDouble()))
        .toList();
  }
}

class CourseStatistics {
  final int totalCourses;
  final int totalCredits;
  final Map<String, int> coursesByType;
  final Map<String, int> coursesByPlan;
  final Map<String, int> coursesBySchool;
  final int totalTheoreticalHours;
  final int totalPracticalHours;
  final double averageTheoreticalHours;
  final double averagePracticalHours;

  CourseStatistics({
    required this.totalCourses,
    required this.totalCredits,
    required this.coursesByType,
    required this.coursesByPlan,
    required this.coursesBySchool,
    required this.totalTheoreticalHours,
    required this.totalPracticalHours,
    required this.averageTheoreticalHours,
    required this.averagePracticalHours,
  });
}

class TeacherStatistics {
  final int totalTeachers;
  final int totalAssignments;
  final double averageCoursesPerTeacher;
  final Map<String, int> courseLoadDistribution;
  final Map<String, int> workloadDistribution;
  final Map<int, List<Course>> teacherAssignments;

  TeacherStatistics({
    required this.totalTeachers,
    required this.totalAssignments,
    required this.averageCoursesPerTeacher,
    required this.courseLoadDistribution,
    required this.workloadDistribution,
    required this.teacherAssignments,
  });
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}