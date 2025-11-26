class UserProfileCreateRequest {
  final String names;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? dob; // formato: YYYY-MM-DD

  UserProfileCreateRequest({
    required this.names,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'names': names,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'dob': dob,
      'isActive': true, // Siempre activo al crear
    };
  }
}
