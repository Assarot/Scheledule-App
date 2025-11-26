import '../../domain/entity/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String username,
    required String email,
    required String name,
    required String lastName,
    required List<String> roles,
    int? userProfileId,
  }) : super(
         id: id,
         username: username,
         email: email,
         name: name,
         lastName: lastName,
         roles: roles,
         userProfileId: userProfileId,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      userProfileId: json['userProfileId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'lastName': lastName,
      'roles': roles,
      'userProfileId': userProfileId,
    };
  }
}
