import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/models/user_rating_request_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/models/meal_rating_request_dto.dart';
import 'package:meal4you_app/models/meal_rating_response_dto.dart';

class RatingService {
  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);
  static const String host = 'https://backend-production-1e17.up.railway.app';
  static const Duration _requestTimeout = Duration(seconds: 20);

  static List<Uri> _candidateUris(String pathWithLeadingSlash) {
    return [
      Uri.parse('$host/usuarios$pathWithLeadingSlash'),
      Uri.parse('$host$pathWithLeadingSlash'),
    ];
  }

  static void notifyChanged() {
    changeNotifier.value += 1;
  }

  // ----- Restaurante (mantidos para compatibilidade) -----
  static Future<UserRatingResponseDTO> avaliarRestaurante(
    UsuarioAvaliaRequestDTO dto,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');
    final body = jsonEncode(dto.toJson());
    final candidates = _candidateUris('/restaurantes/avaliar');
    final errors = <String>[];
    for (final uri in candidates) {
      try {
        final resp = await http
            .post(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: body,
            )
            .timeout(_requestTimeout);
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          notifyChanged();
          return UserRatingResponseDTO.fromJson(jsonDecode(resp.body));
        }
        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
        if (resp.statusCode == 400) throw Exception('Nota inválida (0-5)');
        if (resp.statusCode == 401) throw Exception('Usuário não autenticado');
        if (resp.statusCode == 409) {
          throw Exception('Você já avaliou este restaurante');
        }
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }
    throw Exception(
      'Erro ao criar avaliação; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<UserRatingResponseDTO> atualizarAvaliacao(
    UsuarioAvaliaRequestDTO dto,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');
    final body = jsonEncode(dto.toJson());
    final candidates = _candidateUris('/restaurantes/atualizar-avaliacao');
    final errors = <String>[];
    for (final uri in candidates) {
      try {
        final resp = await http
            .put(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: body,
            )
            .timeout(_requestTimeout);
        if (resp.statusCode == 200) {
          notifyChanged();
          return UserRatingResponseDTO.fromJson(jsonDecode(resp.body));
        }
        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
        if (resp.statusCode == 400) throw Exception('Nota inválida (0-5)');
        if (resp.statusCode == 401) {
          await UserTokenSaving.clearToken();
          throw Exception('Usuário não autenticado');
        }
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }
    throw Exception(
      'Erro ao atualizar avaliação; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<List<UserRatingResponseDTO>> verMinhasAvaliacoes() async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');
    final candidates = [
      ..._candidateUris('/restaurantes/ver-minhas-avaliacoes'),
      ..._candidateUris('/restaurantes/avaliacoes'),
    ];
    final errors = <String>[];
    for (final uri in candidates) {
      try {
        final resp = await http
            .get(uri, headers: {'Authorization': 'Bearer $token'})
            .timeout(_requestTimeout);
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as List<dynamic>;
          return data.map((j) => UserRatingResponseDTO.fromJson(j)).toList();
        }
        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }
    throw Exception(
      'Erro ao buscar avaliações; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<List<UserRatingResponseDTO>> listarAvaliacoesPorRestaurante(
    int idRestaurante,
  ) async {
    final token = await UserTokenSaving.getToken();
    final candidates = [
      Uri.parse(
        '$host/usuarios/restaurantes/avaliacoes?idRestaurante=$idRestaurante',
      ),
      Uri.parse('$host/restaurantes/avaliacoes?idRestaurante=$idRestaurante'),
      Uri.parse('$host/usuarios/restaurantes/$idRestaurante/avaliacoes'),
      Uri.parse('$host/restaurantes/$idRestaurante/avaliacoes'),
    ];
    final errors = <String>[];
    for (final uri in candidates) {
      try {
        final resp = token != null
            ? await http
                  .get(uri, headers: {'Authorization': 'Bearer $token'})
                  .timeout(_requestTimeout)
            : await http.get(uri).timeout(_requestTimeout);
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as List<dynamic>;
          return data.map((j) => UserRatingResponseDTO.fromJson(j)).toList();
        }
        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }
    throw Exception(
      'Erro ao buscar avaliações; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<void> excluirAvaliacao({
    int? idAvaliacao,
    int? idRestaurante,
  }) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');
    final queryParams = <String>[];
    if (idAvaliacao != null && idAvaliacao > 0) {
      queryParams.add('idAvaliacao=$idAvaliacao');
    }
    if (idRestaurante != null && idRestaurante > 0) {
      queryParams.add('idRestaurante=$idRestaurante');
    }
    if (queryParams.isEmpty) {
      throw Exception('Identificador da avaliação não informado');
    }
    final query = queryParams.join('&');
    final candidates = _candidateUris('/restaurantes/excluir-avaliacao?$query');
    final errors = <String>[];
    for (final uri in candidates) {
      try {
        final resp = await http
            .delete(uri, headers: {'Authorization': 'Bearer $token'})
            .timeout(_requestTimeout);
        if (resp.statusCode == 200) return;
        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
        if (resp.statusCode == 400) throw Exception('Avaliação não encontrada');
        if (resp.statusCode == 401) throw Exception('Usuário não autenticado');
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }
    throw Exception(
      'Erro ao excluir avaliação; tentativas: ${errors.join(' | ')}',
    );
  }

  // ----- Refeição (meals) -----
  static Future<MealRatingResponseDTO> avaliarRefeicao(
    MealRatingRequestDTO dto,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');
    final body = jsonEncode(dto.toJson());
    final candidates = _candidateUris('/refeicoes/avaliar');
    final errors = <String>[];
    for (final uri in candidates) {
      try {
        if (kDebugMode) print('[RatingService] POST $uri (avaliarRefeicao)');
        final resp = await http
            .post(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: body,
            )
            .timeout(_requestTimeout);
        if (kDebugMode) {
          print('[RatingService] POST $uri => ${resp.statusCode}');
        }
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          return MealRatingResponseDTO.fromJson(jsonDecode(resp.body));
        }
        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
        if (resp.statusCode == 400) throw Exception('Nota inválida (0-5)');
        if (resp.statusCode == 401) throw Exception('Usuário não autenticado');
        if (resp.statusCode == 409) {
          throw Exception('Você já avaliou esta refeição');
        }
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }
    throw Exception(
      'Erro ao criar avaliação de refeição; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<MealRatingResponseDTO> atualizarAvaliacaoRefeicao(
    MealRatingRequestDTO dto,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');
    final body = jsonEncode(dto.toJson());
    final candidates = _candidateUris('/refeicoes/atualizar-avaliacao');
    final errors = <String>[];
    for (final uri in candidates) {
      try {
        if (kDebugMode) {
          print('[RatingService] PUT $uri (atualizarAvaliacaoRefeicao)');
        }
        final resp = await http
            .put(
              uri,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: body,
            )
            .timeout(_requestTimeout);
        if (kDebugMode) print('[RatingService] PUT $uri => ${resp.statusCode}');
        if (resp.statusCode == 200) {
          return MealRatingResponseDTO.fromJson(jsonDecode(resp.body));
        }
        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
        if (resp.statusCode == 400) throw Exception('Nota inválida (0-5)');
        if (resp.statusCode == 401) {
          await UserTokenSaving.clearToken();
          throw Exception('Usuário não autenticado');
        }
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }
    throw Exception(
      'Erro ao atualizar avaliação de refeição; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<List<MealRatingResponseDTO>>
  verMinhasAvaliacoesDRefeicao() async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');

    final candidates = [
      ..._candidateUris('/refeicoes/minhas-avaliacoes'),
      ..._candidateUris('/refeicoes/avaliacoes'),
    ];

    final errors = <String>[];

    for (final uri in candidates) {
      try {
        if (kDebugMode) {
          print('[RatingService] GET $uri (verMinhasAvaliacoesDRefeicao)');
        }

        final resp = await http
            .get(uri, headers: {'Authorization': 'Bearer $token'})
            .timeout(_requestTimeout);

        if (kDebugMode) {
          print('[RatingService] GET $uri => ${resp.statusCode}');
        }

        if (resp.statusCode == 200) {
          return _parseMealRatings(jsonDecode(resp.body));
        }

        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }

    throw Exception(
      'Erro ao buscar avaliações de refeição; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<List<MealRatingResponseDTO>>
  listarAvaliacoesDeRefeicoesPorRestaurante({
    required int idRestaurante,
    required Set<int> idsRefeicoes,
  }) async {
    final token = await UserTokenSaving.getToken();
    final candidates = [
      Uri.parse(
        '$host/usuarios/restaurantes/$idRestaurante/refeicoes/avaliacoes',
      ),
      Uri.parse('$host/restaurantes/$idRestaurante/refeicoes/avaliacoes'),
      Uri.parse(
        '$host/usuarios/refeicoes/avaliacoes?idRestaurante=$idRestaurante',
      ),
      Uri.parse('$host/refeicoes/avaliacoes?idRestaurante=$idRestaurante'),
      Uri.parse(
        '$host/usuarios/refeicoes/avaliacoes?restauranteId=$idRestaurante',
      ),
      Uri.parse('$host/refeicoes/avaliacoes?restauranteId=$idRestaurante'),
      Uri.parse(
        '$host/usuarios/refeicoes/avaliacoes?id_restaurante=$idRestaurante',
      ),
      Uri.parse('$host/refeicoes/avaliacoes?id_restaurante=$idRestaurante'),
      Uri.parse(
        '$host/usuarios/restaurantes/avaliacoes-refeicoes?idRestaurante=$idRestaurante',
      ),
      Uri.parse(
        '$host/restaurantes/avaliacoes-refeicoes?idRestaurante=$idRestaurante',
      ),
    ];

    final errors = <String>[];
    List<MealRatingResponseDTO>? emptySuccessfulResponse;

    for (final uri in candidates) {
      try {
        if (kDebugMode) {
          print('[RatingService] GET $uri (avaliações refeições restaurante)');
        }

        final resp = token != null
            ? await http
                  .get(uri, headers: {'Authorization': 'Bearer $token'})
                  .timeout(_requestTimeout)
            : await http.get(uri).timeout(_requestTimeout);

        if (kDebugMode) {
          print('[RatingService] GET $uri => ${resp.statusCode}');
        }

        if (resp.statusCode == 200) {
          final ratings = _filtrarAvaliacoesDoRestaurante(
            _parseMealRatings(jsonDecode(resp.body)),
            idsRefeicoes,
          );

          if (ratings.isNotEmpty) {
            return ratings;
          }

          emptySuccessfulResponse ??= ratings;
          errors.add('${uri.toString()} => 200: lista vazia');
          continue;
        }

        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }

    if (emptySuccessfulResponse != null) {
      return emptySuccessfulResponse;
    }

    if (kDebugMode) {
      print(
        '[RatingService] nenhum endpoint de avaliações de refeições do restaurante funcionou: ${errors.join(' | ')}',
      );
    }

    return [];
  }

  static Future<List<MealRatingResponseDTO>> listarAvaliacoesPorRefeicao(
    int idRefeicao,
  ) async {
    final token = await UserTokenSaving.getToken();

    final candidates = [
      Uri.parse('$host/usuarios/refeicoes/avaliacoes?idRefeicao=$idRefeicao'),
      Uri.parse('$host/usuarios/refeicoes/avaliacoes?id_refeicao=$idRefeicao'),
      Uri.parse('$host/usuarios/refeicoes/avaliacoes?refeicaoId=$idRefeicao'),
      Uri.parse('$host/refeicoes/avaliacoes?idRefeicao=$idRefeicao'),
      Uri.parse('$host/refeicoes/avaliacoes?id_refeicao=$idRefeicao'),
      Uri.parse('$host/refeicoes/avaliacoes?refeicaoId=$idRefeicao'),
      Uri.parse('$host/refeicoes/$idRefeicao/avaliacoes'),
      Uri.parse('$host/usuarios/refeicoes/$idRefeicao/avaliacoes'),
    ];

    final errors = <String>[];
    List<MealRatingResponseDTO>? emptySuccessfulResponse;

    for (final uri in candidates) {
      try {
        final resp = token != null
            ? await http
                  .get(uri, headers: {'Authorization': 'Bearer $token'})
                  .timeout(_requestTimeout)
            : await http.get(uri).timeout(_requestTimeout);

        if (resp.statusCode == 200) {
          final ratings = _parseMealRatings(jsonDecode(resp.body)).where((
            rating,
          ) {
            final mealId = rating.mealId;
            return mealId == null || mealId == idRefeicao;
          }).toList();

          if (ratings.isNotEmpty) {
            return ratings;
          }

          emptySuccessfulResponse ??= ratings;
          errors.add('${uri.toString()} => 200: lista vazia');
          continue;
        }

        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }

    if (emptySuccessfulResponse != null) {
      return emptySuccessfulResponse;
    }

    throw Exception(
      'Erro ao buscar avaliações de refeição; tentativas: ${errors.join(' | ')}',
    );
  }

  static List<MealRatingResponseDTO> _parseMealRatings(dynamic decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                MealRatingResponseDTO.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      final possibleLists = [
        map['avaliacoes'],
        map['avaliacoesRefeicao'],
        map['mealRatings'],
        map['ratings'],
        map['dados'],
        map['data'],
        map['content'],
      ];

      for (final value in possibleLists) {
        if (value is List) {
          return _parseMealRatings(value);
        }
      }

      final looksLikeSingleRating =
          map.containsKey('nota') ||
          map.containsKey('rating') ||
          map.containsKey('idAvaliacao') ||
          map.containsKey('comentario');

      if (looksLikeSingleRating) {
        return [MealRatingResponseDTO.fromJson(map)];
      }
    }

    return [];
  }

  static List<MealRatingResponseDTO> _filtrarAvaliacoesDoRestaurante(
    List<MealRatingResponseDTO> ratings,
    Set<int> idsRefeicoes,
  ) {
    if (idsRefeicoes.isEmpty) {
      return ratings;
    }

    return ratings.where((rating) {
      final mealId = rating.mealId;
      return mealId == null || idsRefeicoes.contains(mealId);
    }).toList();
  }

  static Future<void> excluirAvaliacaoRefeicao({
    int? idAvaliacao,
    int? idRefeicao,
  }) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');
    final queryParams = <String>[];
    if (idAvaliacao != null && idAvaliacao > 0) {
      queryParams.add('idAvaliacao=$idAvaliacao');
    }
    if (idRefeicao != null && idRefeicao > 0) {
      queryParams.add('idRefeicao=$idRefeicao');
    }
    if (queryParams.isEmpty) {
      throw Exception('Identificador da avaliação não informado');
    }
    final query = queryParams.join('&');
    final candidates = _candidateUris('/refeicoes/excluir-avaliacao?$query');
    final errors = <String>[];
    for (final uri in candidates) {
      try {
        if (kDebugMode) {
          print('[RatingService] DELETE $uri (excluirAvaliacaoRefeicao)');
        }
        final resp = await http
            .delete(uri, headers: {'Authorization': 'Bearer $token'})
            .timeout(_requestTimeout);
        if (kDebugMode) {
          print('[RatingService] DELETE $uri => ${resp.statusCode}');
        }
        if (resp.statusCode == 200) {
          if (kDebugMode) {
            print('[RatingService] Avaliação excluída com sucesso');
          }
          return;
        }
        errors.add('${uri.toString()} => ${resp.statusCode}: ${resp.body}');
        if (resp.statusCode == 400) throw Exception('Avaliação não encontrada');
        if (resp.statusCode == 401) throw Exception('Usuário não autenticado');
      } on TimeoutException catch (e) {
        errors.add('${uri.toString()} => TIMEOUT: $e');
        continue;
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
    }
    throw Exception(
      'Erro ao excluir avaliação de refeição; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<int> contarAvaliacoes() async {
    try {
      final r = await verMinhasAvaliacoes();
      final m = await verMinhasAvaliacoesDRefeicao();
      return r.length + m.length;
    } catch (e) {
      return 0;
    }
  }

  static void clearCachedData() {}
}
