import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meal4you_app/screens/login/login_screen.dart';

class LoginRedirectText extends StatelessWidget {
  const LoginRedirectText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Já possui uma conta? ',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'Logar',
            style: const TextStyle(
              color: Color.fromARGB(255, 4, 128, 73),
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
          ),
        ],
      ),
    );
  }
}
