/// Modelos para peticiones de profesores
class TeacherCreateRequest {
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String email;
  final String? phone;
  final String? address;
  final String? specialty;

  const TeacherCreateRequest({
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.email,
    this.phone,
    this.address,
    this.specialty,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'paternalSurname': paternalSurname,
      'maternalSurname': maternalSurname,
      'email': email,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (specialty != null && specialty!.isNotEmpty) 'specialty': specialty,
    };
  }
}

class TeacherUpdateRequest {
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String email;
  final String? phone;
  final String? address;
  final String? specialty;

  const TeacherUpdateRequest({
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.email,
    this.phone,
    this.address,
    this.specialty,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'paternalSurname': paternalSurname,
      'maternalSurname': maternalSurname,
      'email': email,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (specialty != null && specialty!.isNotEmpty) 'specialty': specialty,
    };
  }
}