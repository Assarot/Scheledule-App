import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _Logo(),
                  const SizedBox(height: 16),
                  Text(
                    'Iniciar Sesión',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Correo Electrónico',
                    hint: 'Correo Electrónico',
                    leadingIcon: Icons.email_outlined,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Contraseña',
                    hint: 'Contraseña',
                    leadingIcon: Icons.lock_outline,
                    controller: passwordController,
                    obscure: !showPassword,
                    trailing: IconButton(
                      icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.hint),
                      onPressed: () => setState(() => showPassword = !showPassword),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (v) => setState(() => rememberMe = v ?? false),
                        activeColor: AppColors.primary,
                      ),
                      const Text('Recuérdame'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _onLogin,
                      child: const Text('Ingresar'),
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
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          );
                        },
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
    );
  }

  void _onLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RootMenu()),
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


