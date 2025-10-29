import 'dart:convert';
import 'package:http/http.dart' as http;

class VerifyEmailService {
  final String baseUrl;

  VerifyEmailService({required this.baseUrl});

  Future<String> sendVerificationCode({
    required String email,
    bool isAdmin = false,
  }) async {
    final endpoint = isAdmin
        ? '$baseUrl/admins/verifica-email'
        : '$baseUrl/usuarios/verifica-email';

    final uri = Uri.parse(endpoint);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['mensagem'] ?? 'Código enviado com sucesso.';
    } else {
      throw Exception(
        'Erro ao enviar código: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
