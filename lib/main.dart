import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/auth_service.dart';
import 'presentation/pages/login_page.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/repository_impl/auth_repository_impl.dart';

void main() async {
  // Inicializar Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar dependencias
  final authLocalDataSource = AuthLocalDataSource();
  final authRemoteDataSource = AuthRemoteDataSource();
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );
  final authService = AuthService(repository: authRepository);

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authService,
      child: MaterialApp(
        title: 'Schedule App',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const LoginPage(),
      ),
    );
  }
}
