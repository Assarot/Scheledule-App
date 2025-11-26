class AuthUserResponseDto {
  final int idAuthUser;
  final String username;
  final int? idUserProfile;
  final bool isActive;

  AuthUserResponseDto({
    required this.idAuthUser,
    required this.username,
    this.idUserProfile,
    required this.isActive,
  });

  factory AuthUserResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthUserResponseDto(
      idAuthUser: json['id'] as int, // Backend usa 'id' no 'idAuthUser'
      username: json['username'] as String,
      idUserProfile:
          json['userProfileId']
              as int?, // Backend usa 'userProfileId' no 'idUserProfile'
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
