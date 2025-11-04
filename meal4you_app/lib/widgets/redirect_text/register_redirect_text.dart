import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum RegisterUserType { client, adm }

class RegisterRedirectText extends StatelessWidget {
  final RegisterUserType registerUserType;

  const RegisterRedirectText({super.key, required this.registerUserType});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Ainda não possui uma conta? ',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'Cadastrar',
            style: const TextStyle(
              color: Color.fromARGB(255, 157, 0, 255),
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (registerUserType == RegisterUserType.client) {
                  Navigator.pushNamed(context, '/clientRegister');
                } else if (registerUserType == RegisterUserType.adm) {
                  Navigator.pushNamed(context, '/admRegister');
                }
              },
          ),
        ],
      ),
    );
  }
}
