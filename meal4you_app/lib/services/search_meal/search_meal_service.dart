import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/models/paginacao_refeicoes_response_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class SearchMealService {
  static const String host = 'https://backend-production-b24f.up.railway.app';
  static const String baseUrl = '$host/refeicoes';

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

  static Future<PaginacaoRefeicoesResponseDTO> listarRefeicoesPorRestaurante(
    int idRestaurante,
  ) async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }

    final List<MealResponseDTO> todasRefeicoesDoRestaurante = [];
    int paginaAtual = 1;
    int totalPaginas = 1;

    // Itera por todas as páginas até encontrar refeições do restaurante
    while (paginaAtual <= totalPaginas) {
      final uri = '$baseUrl/listar-todas?pagina=$paginaAtual';

      final response = await http.get(
        Uri.parse(uri),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint(
        '🍽️ [SearchMealService] GET $uri -> ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paginacao = PaginacaoRefeicoesResponseDTO.fromJson(data);

        totalPaginas = paginacao.totalPaginas;

        debugPrint(
          '🍽️ [SearchMealService] Página $paginaAtual/$totalPaginas: ${paginacao.refeicoes.length} refeições',
        );

        // Filtra apenas refeições do restaurante solicitado
        final refeicoesDoRestaurante = paginacao.refeicoes
            .where((refeicao) => refeicao.idRestaurante == idRestaurante)
            .toList();

        todasRefeicoesDoRestaurante.addAll(refeicoesDoRestaurante);

        if (refeicoesDoRestaurante.isNotEmpty) {
          debugPrint(
            '🍽️ [SearchMealService] Encontradas ${refeicoesDoRestaurante.length} refeições do restaurante $idRestaurante',
          );
        }

        paginaAtual++;
      } else if (response.statusCode == 401) {
        throw Exception('Usuário não autenticado');
      } else {
        throw Exception('Erro ao listar refeições (${response.statusCode})');
      }
    }

    debugPrint(
      '🍽️ [SearchMealService] Total final: ${todasRefeicoesDoRestaurante.length} refeições do restaurante $idRestaurante',
    );

    return PaginacaoRefeicoesResponseDTO(
      refeicoes: todasRefeicoesDoRestaurante,
      totalPaginas: totalPaginas,
      paginaAtual: 1,
    );
  }
}
