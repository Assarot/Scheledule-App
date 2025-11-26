import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/auth_service.dart';
import '../widgets/app_text_field.dart';
import 'register_page.dart';
import 'root_menu.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  bool showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _Logo(),
                    const SizedBox(height: 16),
                    Text(
                      'Iniciar Sesión',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Usuario o Correo',
                      hint: 'Usuario o Correo',
                      leadingIcon: Icons.person_outline,
                      controller: emailController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Contraseña',
                      hint: 'Contraseña',
                      leadingIcon: Icons.lock_outline,
                      controller: passwordController,
                      obscure: !showPassword,
                      trailing: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.hint,
                        ),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (v) =>
                              setState(() => rememberMe = v ?? false),
                          activeColor: AppColors.primary,
                        ),
                        const Text('Recuérdame'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: authService.isLoading ? null : _onLogin,
                        child: authService.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Ingresar'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes una cuenta? '),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Crear una cuenta'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final username = emailController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    final result = await authService.login(username, password, rememberMe);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const RootMenu()));
    } else {
      final error = result['error'] ?? 'Error desconocido';
      _showError(_parseError(error));
    }
  }

  String _parseError(String error) {
    if (error.contains('Credenciales inválidas')) {
      return 'Correo o contraseña incorrectos';
    } else if (error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      return 'No se puede conectar al servidor. Verifica tu conexión.';
    } else if (error.contains('TimeoutException')) {
      return 'La conexión tardó demasiado. Intenta de nuevo.';
    }
    return 'Error al iniciar sesión. Intenta de nuevo.';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 44,
      backgroundColor: AppColors.primary,
      child: Icon(Icons.show_chart, color: Colors.white, size: 44),
    );
  }
}
