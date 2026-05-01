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

    // Primeiro, faz uma requisição para saber o total de páginas
    const String uriPrimeiraRequisicao = '$baseUrl/listar-todas?pagina=1';
    final responsePrimeira = await http.get(
      Uri.parse(uriPrimeiraRequisicao),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (responsePrimeira.statusCode != 200) {
      throw Exception(
        'Erro ao listar refeições (${responsePrimeira.statusCode})',
      );
    }

    final dataPrimeira = jsonDecode(responsePrimeira.body);
    final paginacaoPrimeira = PaginacaoRefeicoesResponseDTO.fromJson(
      dataPrimeira,
    );
    final totalPaginas = paginacaoPrimeira.totalPaginas;

    debugPrint('🍽️ [SearchMealService] Total de páginas: $totalPaginas');

    // Limita a 5 páginas para evitar carregamento muito lento
    final maxPaginas = (totalPaginas > 5) ? 5 : totalPaginas;

    // Faz requisições para as demais páginas em paralelo
    final futures = <Future<http.Response>>[];
    for (int i = 2; i <= maxPaginas; i++) {
      final uri = '$baseUrl/listar-todas?pagina=$i';
      futures.add(
        http.get(Uri.parse(uri), headers: {'Authorization': 'Bearer $token'}),
      );
    }

    // Aguarda todas as requisições em paralelo
    final respostasParalelas = await Future.wait(futures);

    final List<MealResponseDTO> todasRefeicoesDoRestaurante = [];

    // Processa a primeira página
    final refeicoesPage1 = paginacaoPrimeira.refeicoes
        .where((refeicao) => refeicao.idRestaurante == idRestaurante)
        .toList();
    todasRefeicoesDoRestaurante.addAll(refeicoesPage1);

    debugPrint(
      '🍽️ [SearchMealService] Página 1: ${refeicoesPage1.length} refeições encontradas',
    );

    // Processa as demais páginas
    for (int i = 0; i < respostasParalelas.length; i++) {
      final response = respostasParalelas[i];
      final pageNumber = i + 2;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paginacao = PaginacaoRefeicoesResponseDTO.fromJson(data);

        final refeicoesDoRestaurante = paginacao.refeicoes
            .where((refeicao) => refeicao.idRestaurante == idRestaurante)
            .toList();

        todasRefeicoesDoRestaurante.addAll(refeicoesDoRestaurante);

        debugPrint(
          '🍽️ [SearchMealService] Página $pageNumber: ${refeicoesDoRestaurante.length} refeições encontradas',
        );
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
