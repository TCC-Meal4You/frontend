import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class MealFavoriteService {
  static const String baseUrl =
      'https://backend-production-b24f.up.railway.app/refeicoes';

  static Future<void> alternarFavorito(int refeicaoId) async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token de autenticacao nao encontrado');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/$refeicaoId/favorito'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw Exception('Usuario nao autenticado');
    }

    if (response.statusCode == 404) {
      throw Exception('Refeicao nao encontrada');
    }

    throw Exception(
      'Erro ao alternar favorito da refeicao (${response.statusCode})',
    );
  }

  static Future<List<MealResponseDTO>> listarFavoritos() async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token de autenticacao nao encontrado');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/favoritos'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is! List) {
        return [];
      }

      return data.map((item) {
        final map = item as Map<String, dynamic>;
        return MealResponseDTO.fromJson({...map, 'favorito': true});
      }).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Usuario nao autenticado');
    }

    throw Exception(
      'Erro ao listar refeicoes favoritas (${response.statusCode})',
    );
  }
}
