import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class ClientLoginService {
  static const String baseUrl =
      "https://backend-production-9aaf.up.railway.app/usuarios/login";
  static Future<Map<String, dynamic>> loginClient({
    required String email,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "senha": senha}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao logar: ${response.body}");
    }
  }

  static Future<void> handleLogin(
    BuildContext context,
    String email,
    String senha,
  ) async {
    try {
      await UserTokenSaving.clearAll();

      final response = await loginClient(email: email, senha: senha);
      final token = response["token"] ?? response["accessToken"];
      if (token == null) throw Exception("Token não retornado.");

      await UserTokenSaving.saveCurrentUserEmail(email);
      await UserTokenSaving.saveToken(token);

      final userData = <String, dynamic>{
        ...Map<String, dynamic>.from(response),
        'email': email,
        'userType': 'client',
        'isAdm': false,
      };
      await UserTokenSaving.saveUserData(userData);

      final savedEmail = await UserTokenSaving.getUserEmail();
      if (savedEmail == null) throw Exception("Email não encontrado.");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login realizado: $savedEmail"),
          backgroundColor: const Color.fromARGB(255, 157, 0, 255),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/clientProfile',
        (_) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao logar: $e")));
      }
    }
  }
}
