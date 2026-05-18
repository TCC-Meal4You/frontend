import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/models/paginacao_refeicoes_response_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/services/meal/meal_service.dart';

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
      return PaginacaoRefeicoesResponseDTO.fromJson(
        Map<String, dynamic>.from(data),
      );
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

    try {
      final todasRefeicoesDoRestaurante = <MealResponseDTO>[];
      var paginaAtual = 1;
      var totalPaginas = 1;

      while (paginaAtual <= totalPaginas) {
        final response = await http.get(
          Uri.parse('$baseUrl/listar-todas?pagina=$paginaAtual'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Erro ao listar página $paginaAtual (${response.statusCode})',
          );
        }

        final data = jsonDecode(response.body);
        final paginacao = PaginacaoRefeicoesResponseDTO.fromJson(
          Map<String, dynamic>.from(data),
        );

        totalPaginas = paginacao.totalPaginas <= 0 ? 1 : paginacao.totalPaginas;

        final refeicoesDaPagina = paginacao.refeicoes
            .where((refeicao) => refeicao.idRestaurante == idRestaurante)
            .toList();

        todasRefeicoesDoRestaurante.addAll(refeicoesDaPagina);
        paginaAtual++;
      }

      if (kDebugMode) {
        print(
          '[SearchMealService] restaurante $idRestaurante => '
          '${todasRefeicoesDoRestaurante.length} refeições encontradas',
        );
      }

      if (todasRefeicoesDoRestaurante.isNotEmpty) {
        return PaginacaoRefeicoesResponseDTO(
          refeicoes: todasRefeicoesDoRestaurante,
          totalPaginas: totalPaginas,
          paginaAtual: 1,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SearchMealService] busca paginada falhou: $e');
      }
    }

    final candidateUris = [
      Uri.parse('$host/usuarios/restaurantes/$idRestaurante/refeicoes'),
      Uri.parse('$host/restaurantes/$idRestaurante/refeicoes'),
      Uri.parse('$host/restaurantes/$idRestaurante/refeicoes?pagina=1'),
      Uri.parse('$host/refeicoes?restauranteId=$idRestaurante'),
      Uri.parse('$host/refeicoes?restaurantId=$idRestaurante'),
    ];

    for (final uri in candidateUris) {
      try {
        if (kDebugMode) {
          print('[SearchMealService] tentando $uri');
        }

        final resp = await http.get(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (kDebugMode) {
          print('[SearchMealService] $uri => ${resp.statusCode}');
        }

        if (resp.statusCode != 200) {
          continue;
        }

        final decoded = jsonDecode(resp.body);
        List<MealResponseDTO> refeicoes = [];

        if (decoded is List) {
          refeicoes = decoded
              .whereType<Map>()
              .map(
                (j) => MealResponseDTO.fromJson(Map<String, dynamic>.from(j)),
              )
              .toList();
        } else if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);

          if (map.containsKey('refeicoes')) {
            final pag = PaginacaoRefeicoesResponseDTO.fromJson(map);
            refeicoes = pag.refeicoes;
          } else if (map.values.any((v) => v is List)) {
            final firstList = map.values.firstWhere((v) => v is List) as List;

            refeicoes = firstList
                .whereType<Map>()
                .map(
                  (j) => MealResponseDTO.fromJson(Map<String, dynamic>.from(j)),
                )
                .toList();
          }
        }

        final refeicoesFiltradas = refeicoes
            .where((r) => r.idRestaurante == idRestaurante)
            .toList();

        if (refeicoesFiltradas.isNotEmpty) {
          return PaginacaoRefeicoesResponseDTO(
            refeicoes: refeicoesFiltradas,
            totalPaginas: 1,
            paginaAtual: 1,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('[SearchMealService] fallback $uri falhou: $e');
        }
        continue;
      }
    }

    try {
      if (kDebugMode) {
        print(
          '[SearchMealService] tentando listarMinhasRefeicoes como último recurso',
        );
      }

      final minhas = await MealService.listarMinhasRefeicoes();

      final filtradas = minhas
          .where((r) => r.idRestaurante == idRestaurante)
          .toList();

      return PaginacaoRefeicoesResponseDTO(
        refeicoes: filtradas,
        totalPaginas: 1,
        paginaAtual: 1,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[SearchMealService] listarMinhasRefeicoes falhou: $e');
      }
    }

    return PaginacaoRefeicoesResponseDTO(
      refeicoes: [],
      totalPaginas: 1,
      paginaAtual: 1,
    );
  }
}
