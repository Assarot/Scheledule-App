class LoginRequest {
  final String username;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}
