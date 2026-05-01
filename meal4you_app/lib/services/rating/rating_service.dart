import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/models/user_rating_request_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class RatingService {
  static const String host = 'https://backend-production-b24f.up.railway.app';

  static List<Uri> _candidateUris(String pathWithLeadingSlash) {
    return [
      Uri.parse('$host/usuarios$pathWithLeadingSlash'),
      Uri.parse('$host$pathWithLeadingSlash'),
    ];
  }

  static Future<UserRatingResponseDTO> avaliarRestaurante(
    UsuarioAvaliaRequestDTO dto,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');

    final requestBody = jsonEncode(dto.toJson());
    final candidates = _candidateUris('/restaurantes/avaliar');

    List<String> errors = [];

    for (final uri in candidates) {
      try {
        debugPrint(
          '🌟 [RatingService] Tentando POST $uri com body: $requestBody',
        );
        final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: requestBody,
        );
        debugPrint(
          '🌟 [RatingService] $uri -> ${response.statusCode} : ${response.body}',
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return UserRatingResponseDTO.fromJson(jsonDecode(response.body));
        }

        errors.add(
          '${uri.toString()} => ${response.statusCode}: ${response.body}',
        );
        if (response.statusCode == 404 || response.statusCode == 405) {
          continue;
        }

        if (response.statusCode == 400) throw Exception('Nota inválida (0-5)');
        if (response.statusCode == 401)
          throw Exception('Usuário não autenticado');
        if (response.statusCode == 404)
          throw Exception('Restaurante não encontrado');
        if (response.statusCode == 409)
          throw Exception('Você já avaliou este restaurante');
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

    final requestBody = jsonEncode(dto.toJson());
    final candidates = _candidateUris('/restaurantes/atualizar-avaliacao');
    List<String> errors = [];

    for (final uri in candidates) {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      debugPrint(
        '🌟 [RatingService] PUT $uri -> ${response.statusCode}: ${response.body}',
      );

      if (response.statusCode == 200) {
        return UserRatingResponseDTO.fromJson(jsonDecode(response.body));
      }

      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }

      if (response.statusCode == 400) {
        throw Exception('Nota inválida (0-5)');
      }
      if (response.statusCode == 401) {
        throw Exception('Usuário não autenticado');
      }
      if (response.statusCode == 404) {
        throw Exception('Restaurante ou avaliação não encontrados');
      }
      throw Exception(
        'Erro ao atualizar avaliação (${response.statusCode}): ${response.body}',
      );
    }

    throw Exception(
      'Erro ao atualizar avaliação; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<List<UserRatingResponseDTO>> verMinhasAvaliacoes() async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');

    final candidates = _candidateUris('/restaurantes/ver-minhas-avaliacoes');
    List<String> errors = [];

    for (final uri in candidates) {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint(
        '🌟 [RatingService] GET $uri -> ${response.statusCode}: ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => UserRatingResponseDTO.fromJson(json))
            .toList();
      }

      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }

      if (response.statusCode == 401) {
        throw Exception('Usuário não autenticado');
      }

      throw Exception('Erro ao buscar avaliações (${response.statusCode})');
    }

    throw Exception(
      'Erro ao buscar avaliações; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<List<UserRatingResponseDTO>> listarAvaliacoesPorRestaurante(
    int idRestaurante,
  ) async {
    // Backend atual não expõe endpoint público de avaliações por restaurante.
    // Mantém compatibilidade retornando apenas as avaliações do usuário para o restaurante informado.
    final all = await verMinhasAvaliacoes();
    return all.where((r) => r.restaurantId == idRestaurante).toList();
  }

  static Future<void> excluirAvaliacao(int idRestaurante) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');

    final candidates = _candidateUris(
      '/restaurantes/excluir-avaliacao?idRestaurante=$idRestaurante',
    );

    List<String> errors = [];

    for (final uri in candidates) {
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      final redirectTo = response.headers['location'];
      debugPrint(
        '🌟 [RatingService] DELETE $uri -> ${response.statusCode}: ${response.body}${redirectTo != null ? ' | location: $redirectTo' : ''}',
      );

      if (response.statusCode == 200) return;

      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308 ||
          response.statusCode == 404 ||
          response.statusCode == 405) {
        continue;
      }

      if (response.statusCode == 400)
        throw Exception('Avaliação não encontrada');
      if (response.statusCode == 401)
        throw Exception('Usuário não autenticado');
      throw Exception(
        'Erro ao excluir avaliação (${response.statusCode}): ${response.body}',
      );
    }

    throw Exception(
      'Erro ao excluir avaliação; tentativas: ${errors.join(' | ')}',
    );
  }
}
