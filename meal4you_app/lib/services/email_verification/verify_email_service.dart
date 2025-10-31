import 'dart:convert';
import 'package:http/http.dart' as http;

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

    final uri = Uri.parse(endpoint);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['erro'] ?? 'Erro ao enviar código');
    }
  }

  Future<void> confirmCode({
    required String email,
    required String nome,
    required String senha,
    required String codigo,
    bool isAdmin = false,
  }) async {
    final endpoint = isAdmin
        ? '$baseUrl/admins/verifica-email'
        : '$baseUrl/usuarios/verifica-email';

    final uri = Uri.parse(endpoint);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'nome': nome,
        'senha': senha,
        'codigo': codigo,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['erro'] ?? 'Código inválido ou expirado');
    }
  }
}
