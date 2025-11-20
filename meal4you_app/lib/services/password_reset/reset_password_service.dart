import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPasswordService {
  final String baseUrl = "https://backend-production-9aaf.up.railway.app";

  Future<bool> sendResetCode(String email, bool isAdm) async {
    final url = Uri.parse(
      "$baseUrl/${isAdm ? "admins" : "usuarios"}/redefinir-senha/solicitar?email=$email",
    );

    final response = await http.post(url);

    return response.statusCode == 200;
  }

  Future<bool> confirmResetPassword({
    required String email,
    required String newPassword,
    required String code,
    required bool isAdm,
  }) async {
    final url = Uri.parse(
      "$baseUrl/${isAdm ? "admins" : "usuarios"}/redefinir-senha/confirmar",
    );

    final body = jsonEncode({
      "email": email,
      "novaSenha": newPassword,
      "codigoVerificacao": code,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    return response.statusCode == 200;
  }
}
