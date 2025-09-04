import 'package:flutter/material.dart';
import 'package:meal4you_app/screens/login_screen.dart';

void main() {
  runApp(const Meal4You());
}

class Meal4You extends StatelessWidget {
  const Meal4You({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal4You',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
    );
  }
}