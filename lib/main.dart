import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const LoginPage(),
    );
  }
}

