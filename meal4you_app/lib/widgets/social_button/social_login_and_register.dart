import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/services/google_register_and_login/google_register_and_login_service.dart';

class SocialLoginAndRegister extends StatelessWidget {
  final bool isAdmin;

  const SocialLoginAndRegister({
    super.key,
    this.isAdmin = false,
  });

  Future<void> _handleGoogleAction(BuildContext context) async {
    final googleRegisterAndLoginService = GoogleRegisterAndLoginService();

    try {
      await googleRegisterAndLoginService.signInWithGoogle(
        context: context,
        isAdmin: isAdmin,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao autenticar com Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: 340,
      child: ElevatedButton.icon(
        onPressed: () => _handleGoogleAction(context),
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
    );
  }
}
