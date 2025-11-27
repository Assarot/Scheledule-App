import '../../domain/entity/teacher.dart';

class TeacherModel {
  final int idTeacher;
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String email;
  final String? phone;
  final String? address;
  final String? specialty;

  const TeacherModel({
    required this.idTeacher,
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.email,
    this.phone,
    this.address,
    this.specialty,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      idTeacher: json['idTeacher'] ?? 0,
      name: json['name'] ?? '',
      paternalSurname: json['paternalSurname'] ?? '',
      maternalSurname: json['maternalSurname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      specialty: json['specialty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idTeacher': idTeacher,
      'name': name,
      'paternalSurname': paternalSurname,
      'maternalSurname': maternalSurname,
      'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (specialty != null) 'specialty': specialty,
    };
  }

  Teacher toDomain() {
    return Teacher(
      idTeacher: idTeacher,
      name: name,
      paternalSurname: paternalSurname,
      maternalSurname: maternalSurname,
      email: email,
      phone: phone,
      address: address,
      specialty: specialty,
    );
  }

  factory TeacherModel.fromDomain(Teacher teacher) {
    return TeacherModel(
      idTeacher: teacher.idTeacher,
      name: teacher.name,
      paternalSurname: teacher.paternalSurname,
      maternalSurname: teacher.maternalSurname,
      email: teacher.email,
      phone: teacher.phone,
      address: teacher.address,
      specialty: teacher.specialty,
    );
  }
}