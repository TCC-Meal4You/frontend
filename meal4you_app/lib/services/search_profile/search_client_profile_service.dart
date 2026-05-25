import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class SearchClientProfileService {
  static const String baseUrl =
      'https://backend-production-1e17.up.railway.app/usuarios';
  static Future<Map<String, dynamic>> buscarMeuPerfil() async {
    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception('Token nao encontrado');
    }
    final client = http.Client();
    try {
      final req = http.Request('GET', Uri.parse(baseUrl));
      req.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      req.followRedirects = false;
      final streamed = await client.send(req);
      final response = await http.Response.fromStream(streamed);
      final location = response.headers['location'] ?? '';
      if (response.statusCode >= 300 && response.statusCode < 400) {
        if (location.contains('/oauth2/authorization/google')) {
          throw Exception('Sessao expirada ou invalida. Faça login novamente.');
        }
        throw Exception('Redirecionamento inesperado ao buscar perfil.');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }
}
