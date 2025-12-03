import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class UpdateAdmProfileService {
  static const String baseUrl =
      'https://backend-production-9aaf.up.railway.app/admins';

  static Future<Map<String, dynamic>> atualizarMeuPerfil({
    String? nome,
    String? senha,
  }) async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final body = <String, dynamic>{};
    if (nome != null && nome.isNotEmpty) body['nome'] = nome;
    if (senha != null && senha.isNotEmpty) body['senha'] = senha;

    if (body.isEmpty) {
      throw Exception('Nenhuma alteração detectada');
    }

    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 400) {
      throw Exception('Nenhuma alteração detectada ou operação não permitida');
    } else if (response.statusCode == 401) {
      throw Exception('Não autorizado. Faça login novamente.');
    } else {
      throw Exception('Erro ao atualizar perfil: ${response.statusCode}');
    }
  }
}
