import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ForgotPasswordRedirectText extends StatelessWidget {
  final bool isAdm;

  const ForgotPasswordRedirectText({super.key, required this.isAdm});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Esqueceu sua senha? ',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'Redefinir',
            style: const TextStyle(
              color: Color.fromARGB(255, 157, 0, 255),
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(
                  context,
                  '/sendPasswordCode',
                  arguments: {'isAdm': isAdm},
                );
              },
          ),
        ],
      ),
    );
  }
}
