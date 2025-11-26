import '../entity/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(
    String username,
    String password,
    bool rememberMe,
  );
  Future<String?> refreshAccessToken();
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
}
