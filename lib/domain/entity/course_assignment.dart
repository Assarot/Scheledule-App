class CourseAssignment {
  final int id;
  final int courseId;
  final int teacherId;
  final String courseName;
  final String courseCode;
  final String teacherName;
  final String teacherEmail;
  final DateTime assignedDate;

  const CourseAssignment({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.courseName,
    required this.courseCode,
    required this.teacherName,
    required this.teacherEmail,
    required this.assignedDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseAssignment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}