import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/user_restriction_request_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class UserRestrictionService {
  static const String baseUrl =
      'https://backend-production-bc8d.up.railway.app/usuarios/restricoes';

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
