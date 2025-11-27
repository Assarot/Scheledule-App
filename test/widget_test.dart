import 'package:flutter_test/flutter_test.dart';
import 'package:schedulemovile/data/datasources/auth_local_datasource.dart';
import 'package:schedulemovile/data/datasources/auth_remote_datasource.dart';
import 'package:schedulemovile/data/repository_impl/auth_repository_impl.dart';
import 'package:schedulemovile/utils/auth_service.dart';
import 'package:schedulemovile/utils/connectivity_service.dart';
import 'package:schedulemovile/main.dart';

void main() {
  testWidgets('App should render login page', (WidgetTester tester) async {
    // Crear instancias mock para el test
    final authLocalDataSource = AuthLocalDataSource();
    final authRemoteDataSource = AuthRemoteDataSource();
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    final authService = AuthService(repository: authRepository);
    final connectivityService = ConnectivityService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(authService: authService, connectivityService: connectivityService),
    );

    // Verify that login page is shown
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
