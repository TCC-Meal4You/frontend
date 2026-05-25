import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';

class KnnRecommendationService {
  static const String _host = 'https://backend-production-1e17.up.railway.app';

  static Future<List<int>> obterRecomendacoesRefeicoes() async {
    return _obterIds('/usuarios/recomendacoes-refeicoes-knn');
  }

  static Future<List<int>> obterRecomendacoesRestaurantes() async {
    return _obterIds('/usuarios/recomendacoes-restaurantes-knn');
  }

  static Future<List<int>> _obterIds(String path) async {
    final token = await UserTokenSaving.getToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception('Usuário não autenticado');
    }

    final response = await http.get(
      Uri.parse('$_host$path'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final dynamic payload = jsonDecode(response.body);
      return _extrairIds(payload);
    }
    if (response.statusCode == 400) {
      throw Exception('ID do usuário inválido ou problema ao solicitar modelo');
    }
    if (response.statusCode == 401) {
      throw Exception('Usuário não autenticado');
    }
    throw Exception('Erro ao buscar recomendações (${response.statusCode})');
  }

  static Future<bool> isUserReadyForRecommendations({
    int minRatings = 3,
  }) async {
    try {
      final count = await RatingService.contarAvaliacoes();
      return count >= minRatings;
    } catch (_) {
      return false;
    }
  }

  static List<int> _extrairIds(dynamic payload) {
    if (payload == null) {
      return [];
    }

    if (payload is List) {
      return payload
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      const keys = [
        'idsRecomendados',
        'ids',
        'recomendacoes',
        'idRefeicoes',
        'idRestaurantes',
        'refeicoes',
        'restaurantes',
        'dados',
      ];

      for (final key in keys) {
        final value = payload[key];
        if (value is List) {
          final ids = value
              .map((e) {
                if (e is Map<String, dynamic>) {
                  final candidate =
                      e['id'] ??
                      e['idRefeicao'] ??
                      e['idRestaurante'] ??
                      e['id_refeicao'] ??
                      e['id_restaurante'];
                  return int.tryParse(candidate.toString());
                }
                return int.tryParse(e.toString());
              })
              .whereType<int>()
              .toList();
          if (ids.isNotEmpty) {
            return ids;
          }
        }
      }
    }

    return [];
  }
}
