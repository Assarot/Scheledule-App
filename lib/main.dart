import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/auth_service.dart';
import 'utils/connectivity_service.dart';
import 'utils/cache_service.dart';
import 'presentation/pages/login_page.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/repository_impl/auth_repository_impl.dart';

void main() async {
  // Inicializar Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar cache (Hive)
  await CacheService.init();

  // Inicializar dependencias
  final authLocalDataSource = AuthLocalDataSource();
  final authRemoteDataSource = AuthRemoteDataSource();
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );
  final authService = AuthService(repository: authRepository);
  final connectivityService = ConnectivityService();

  runApp(
    MyApp(authService: authService, connectivityService: connectivityService),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ConnectivityService connectivityService;

  const MyApp({
    super.key,
    required this.authService,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: connectivityService),
      ],
      child: MaterialApp(
        title: 'Schedule App',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const LoginPage(),
      ),
    );
  }
}
