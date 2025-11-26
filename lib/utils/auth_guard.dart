import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/auth_service.dart';
import '../presentation/pages/login_page.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<String>? requiredRoles;

  const AuthGuard({super.key, required this.child, this.requiredRoles});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Si está cargando, mostrar loading
    if (authService.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si no está autenticado, redirigir al login
    if (!authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si se requieren roles específicos, validar
    if (requiredRoles != null && requiredRoles!.isNotEmpty) {
      final hasRequiredRole = requiredRoles!.any(
        (role) => authService.hasRole(role),
      );

      if (!hasRequiredRole) {
        return Scaffold(
          appBar: AppBar(title: const Text('Acceso Denegado')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'No tienes permisos para acceder a esta sección',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Usuario autenticado y con permisos
    return child;
  }
}

// Widget de ejemplo protegido por roles de administrador
class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(requiredRoles: const ['ADMIN'], child: child);
  }
}
