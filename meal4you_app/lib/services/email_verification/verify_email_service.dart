import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/register/adm_register_service.dart';
import 'package:meal4you_app/services/register/client_register_service.dart';

class VerifyEmailService {
  final String baseUrl;

  VerifyEmailService({required this.baseUrl});

  Future<void> sendVerificationCode({
    required String email,
    bool isAdmin = false,
  }) async {
    final endpoint = isAdmin
        ? '$baseUrl/admins/verifica-email'
        : '$baseUrl/usuarios/verifica-email';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['erro'] ?? 'Erro ao enviar código de verificação.');
    }
  }

  Future<void> confirmCode({
    required String nome,
    required String email,
    required String senha,
    required String codigo,
    bool isAdmin = false,
  }) async {
    if (isAdmin) {
      await AdmRegisterService.registerAdm(
        nome: nome,
        email: email,
        senha: senha,
        codigo: codigo,
      );
    } else {
      await ClientRegisterService.registerClient(
        nome: nome,
        email: email,
        senha: senha,
        codigo: codigo,
      );
    }
  }
}
