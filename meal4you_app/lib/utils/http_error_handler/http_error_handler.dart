import 'package:flutter/material.dart';
import 'package:meal4you_app/controllers/textfield/login_controllers.dart';
import 'package:meal4you_app/controllers/textfield/register_controllers.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:http/http.dart' as http;

class HttpErrorHandler {
  static Future<void> handle401Error(
    BuildContext context,
    http.Response response,
  ) async {
    if (response.statusCode == 401) {
      await UserTokenSaving.clearAll();

      LoginControllers.emailController.clear();
      LoginControllers.senhaController.clear();
      RegisterControllers.nomeController.clear();
      RegisterControllers.emailController.clear();
      RegisterControllers.senhaController.clear();
      RegisterControllers.confirmarSenhaController.clear();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sua sessão expirou ou foi invalidada. Faça login novamente.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/profileChoice', (route) => false);
    }
  }

  static bool is401Error(http.Response response) {
    return response.statusCode == 401;
  }
}
