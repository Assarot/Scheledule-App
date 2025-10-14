import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../widgets/app_text_field.dart';
import 'root_menu.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = false;

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get isValid =>
      nameController.text.trim().isNotEmpty &&
      lastNameController.text.trim().isNotEmpty &&
      usernameController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty;

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
                    'Crear Cuenta',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Nombre',
                    hint: 'Nombre',
                    leadingIcon: Icons.badge_outlined,
                    controller: nameController,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Apellido',
                    hint: 'Apellido',
                    leadingIcon: Icons.note_outlined,
                    controller: lastNameController,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Usuario',
                    hint: 'Usuario',
                    leadingIcon: Icons.person_outline,
                    controller: usernameController,
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isValid ? _onCreateAccount : null,
                      child: const Text('Crear cuenta'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tiene una cuenta? '),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        child: const Text('Ingresa'),
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

  void _onCreateAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountCreatedPage()),
    );
  }
}

class AccountCreatedPage extends StatefulWidget {
  const AccountCreatedPage({super.key});

  @override
  State<AccountCreatedPage> createState() => _AccountCreatedPageState();
}

class _AccountCreatedPageState extends State<AccountCreatedPage> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    scale = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootMenu()),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Simple confetti: radial burst using many small circles animated by scale
              ScaleTransition(
                scale: scale,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.fieldFill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.thumb_up_alt_rounded, size: 80, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              _ConfettiRow(),
              const SizedBox(height: 24),
              Text('Tu cuenta ha sido creada', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RootMenu()),
                  (route) => false,
                ),
                child: const Text('Redirigiendo..'),
              ),
            ],
          ),
        ),
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

class _ConfettiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFBFC621),
      Color(0xFF8BC34A),
      Color(0xFFFFC107),
      Color(0xFF03A9F4),
      Color(0xFFE91E63),
    ];
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(20, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(Icons.circle, size: 6 + (i % 4).toDouble() * 2, color: colors[i % colors.length]),
          );
        }),
      ),
    );
  }
}


