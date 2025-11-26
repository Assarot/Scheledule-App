class AuthUserResponseDto {
  final int idAuthUser;
  final String username;
  final int idUserProfile;
  final bool isActive;

  AuthUserResponseDto({
    required this.idAuthUser,
    required this.username,
    required this.idUserProfile,
    required this.isActive,
  });

  factory AuthUserResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthUserResponseDto(
      idAuthUser: json['idAuthUser'] as int,
      username: json['username'] as String,
      idUserProfile: json['idUserProfile'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
