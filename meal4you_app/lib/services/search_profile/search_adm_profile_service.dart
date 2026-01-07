import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class SearchAdmProfileService {
  static const String baseUrl =
      'https://backend-production-38906.up.railway.app/admins';

  static Future<Map<String, dynamic>> buscarMeuPerfil() async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw Exception('Não autorizado. Faça login novamente.');
    } else {
      throw Exception('Erro ao buscar perfil: ${response.statusCode}');
    }
  }
}
