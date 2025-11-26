import '../../domain/repository/auth_repository.dart';
import '../../domain/entity/user.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/login_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Map<String, dynamic>> login(
    String username,
    String password,
    bool rememberMe,
  ) async {
    try {
      final request = LoginRequest(
        username: username,
        password: password,
        rememberMe: rememberMe,
      );

      final response = await remoteDataSource.login(request, rememberMe);

      if (response.user == null) {
        throw Exception('No se pudieron obtener los datos del usuario');
      }

      // Guardar tokens y usuario
      await localDataSource.saveAccessToken(response.accessToken);
      await localDataSource.saveRefreshToken(
        response.refreshToken ?? response.accessToken,
      );
      await localDataSource.saveUser(response.user!);
      await localDataSource.saveRememberMe(rememberMe);

      return {'success': true, 'user': response.user};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveAccessToken(response.accessToken);

      return response.accessToken;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAll();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    final accessToken = await localDataSource.getAccessToken();
    final user = await localDataSource.getUser();
    return accessToken != null && user != null;
  }
}
