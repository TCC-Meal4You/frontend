import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/user_restriction_request_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class UserRestrictionService {
  static const String baseUrl =
      'https://backend-production-bc8d.up.railway.app/usuarios/restricoes';

  static Future<List<int>> buscarRestricoes() async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => item['idRestricao'] as int).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('ACCOUNT_NOT_FOUND');
    } else if (response.statusCode == 404) {
      throw Exception('ACCOUNT_NOT_FOUND');
    } else {
      throw Exception('Erro ao buscar restrições (${response.statusCode})');
    }
  }

  static Future<void> atualizarRestricoes(List<int> idsRestricoes) async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }

    final dto = UserRestrictionRequestDTO(idsRestricoes: idsRestricoes);

    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 400) {
      throw Exception('Um ou mais IDs de restrição são inválidos');
    } else if (response.statusCode == 401) {
      throw Exception('Usuário não autenticado');
    } else {
      throw Exception('Erro ao atualizar restrições (${response.statusCode})');
    }
  }
}
