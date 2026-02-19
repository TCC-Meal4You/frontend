import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/paginacao_refeicoes_response_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class SearchMealService {
  static const String baseUrl =
      'https://backend-production-bc8d.up.railway.app/refeicoes';

  static Future<PaginacaoRefeicoesResponseDTO> listarRefeicoes(
    int pagina,
  ) async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/listar-todas?pagina=$pagina'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaginacaoRefeicoesResponseDTO.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Usuário não autenticado');
    } else {
      throw Exception('Erro ao listar refeições (${response.statusCode})');
    }
  }
}
