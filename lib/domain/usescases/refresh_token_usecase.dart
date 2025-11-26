import '../../domain/repository/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase({required this.repository});

  Future<String?> call() async {
    return await repository.refreshAccessToken();
  }
}
