import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum UserType { client, adm }

class LoginRedirectText extends StatelessWidget {
  final UserType userType;

  const LoginRedirectText({super.key, required this.userType});

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
                if (userType == UserType.client) {
                  Navigator.pushNamed(context, '/clientLogin');
                } else if (userType == UserType.adm) {
                  Navigator.pushNamed(context, '/admLogin');
                }
              },
          ),
        ],
      ),
    );
  }
}
