class UserProfileModel {
  final int id;
  final String names;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final DateTime? dob;
  final String? profilePicture;
  final bool isActive;

  UserProfileModel({
    required this.id,
    required this.names,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.dob,
    this.profilePicture,
    required this.isActive,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['idUserProfile'] as int,
      names: json['names'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      dob: json['dob'] != null ? DateTime.parse(json['dob'] as String) : null,
      profilePicture: json['profilePicture'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUserProfile': id,
      'names': names,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'dob': dob?.toIso8601String().split('T')[0],
      'profilePicture': profilePicture,
      'isActive': isActive,
    };
  }

  String get fullName => '$names $lastName';
  String get initials => '${names[0]}${lastName[0]}'.toUpperCase();
}
