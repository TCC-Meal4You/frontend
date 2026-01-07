import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class RequestEmailChangeService {
  static const String baseUrl =
      'https://backend-production-38906.up.railway.app/admins/solicitar-alteracao-email';

  static Future<void> solicitarAlteracaoEmail(String novoEmail) async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': novoEmail}),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 400) {
      throw Exception(
        'Administrador criado via social login não pode alterar e-mail',
      );
    } else if (response.statusCode == 401) {
      throw Exception('Não autorizado. Faça login novamente.');
    } else if (response.statusCode == 409) {
      throw Exception('O novo e-mail é igual ao atual');
    } else {
      throw Exception('Erro ao solicitar alteração: ${response.statusCode}');
    }
  }
}
