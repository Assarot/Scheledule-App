import '../../domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<Map<String, dynamic>> call(
    String username,
    String password,
    bool rememberMe,
  ) async {
    return await repository.login(username, password, rememberMe);
  }
}
