import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/services/auth/google_auth_service.dart';

class SocialLoginAndRegister extends StatelessWidget {
  const SocialLoginAndRegister({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final googleAuthService = GoogleAuthService();

    try {
      final userCredential = await googleAuthService.signInWithGoogle();

      if (userCredential != null) {
        final user = userCredential.user!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo, ${user.displayName ?? "usuário"}!'),
            backgroundColor: Colors.green,
          ),
        );

        // 🔹 Redirecionamento — você pode personalizar isso:
        Navigator.pushNamed(context, '/clientHome');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao logar com Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 55,
          width: 340,
          child: ElevatedButton.icon(
            onPressed: () => _handleGoogleSignIn(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
              ),
              elevation: 1,
            ),
            icon: const FaIcon(
              FontAwesomeIcons.google,
              color: Colors.red,
              size: 32,
            ),
            label: const Text(
              'Entrar com Google',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
