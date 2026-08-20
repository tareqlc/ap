import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School App Lite',
      theme: ThemeData(
          fontFamily: 'Roboto', primaryColor: const Color(0xFF15803d)),
      home: const LoginScreen(),
    );
  }
}
