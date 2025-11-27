class Teacher {
  final int idTeacher;
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String email;
  final String? phone;
  final String? address;
  final String? specialty;

  const Teacher({
    required this.idTeacher,
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.email,
    this.phone,
    this.address,
    this.specialty,
  });

  String get fullName => '$name $paternalSurname $maternalSurname';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Teacher &&
          runtimeType == other.runtimeType &&
          idTeacher == other.idTeacher;

  @override
  int get hashCode => idTeacher.hashCode;

  @override
  String toString() {
    return 'Teacher{idTeacher: $idTeacher, fullName: $fullName, email: $email}';
  }
}