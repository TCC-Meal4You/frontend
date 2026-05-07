import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/models/user_rating_request_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

String _safeBase64Decode(String input) {
  var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
  while (normalized.length % 4 != 0) {
    normalized += '=';
  }
  return utf8.decode(base64Url.decode(normalized));
}

void _logTokenClaims(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return;
    final payload = parts[1];
    final decoded = _safeBase64Decode(payload);
    debugPrint('🌟 [RatingService] Token payload: $decoded');
    try {
      final Map<String, dynamic> map = jsonDecode(decoded);
      if (map.containsKey('exp'))
        debugPrint('🌟 [RatingService] token.exp=${map['exp']}');
      if (map.containsKey('sub'))
        debugPrint('🌟 [RatingService] token.sub=${map['sub']}');
      if (map.containsKey('roles'))
        debugPrint('🌟 [RatingService] token.roles=${map['roles']}');
      if (map.containsKey('restaurantId'))
        debugPrint(
          '🌟 [RatingService] token.restaurantId=${map['restaurantId']}',
        );
    } catch (_) {}
  } catch (e) {
    debugPrint('🌟 [RatingService] falha ao decodificar token: $e');
  }
}

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

    debugPrint(
      '🌟 [RatingService] Candidates for verMinhasAvaliacoes: ${candidates.join(', ')}',
    );

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
        if (response.statusCode == 401) {
          throw Exception('Usuário não autenticado');
        }
        if (response.statusCode == 404) {
          throw Exception('Restaurante não encontrado');
        }
        if (response.statusCode == 409) {
          throw Exception('Você já avaliou este restaurante');
        }
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
    int redirectCount = 0;

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

      // Track redirects to detect auth failures
      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        redirectCount++;
        continue;
      }

      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }

      if (response.statusCode == 400) {
        throw Exception('Nota inválida (0-5)');
      }
      if (response.statusCode == 401) {
        _logTokenClaims(token);
        await UserTokenSaving.clearToken();
        throw Exception('Usuário não autenticado');
      }
      if (response.statusCode == 404) {
        throw Exception('Restaurante ou avaliação não encontrados');
      }
      throw Exception(
        'Erro ao atualizar avaliação (${response.statusCode}): ${response.body}',
      );
    }

    // If all candidates returned redirects (302), it's likely auth failure
    if (redirectCount == candidates.length && redirectCount > 0) {
      debugPrint(
        '🌟 [RatingService] Todos os redirects ($redirectCount/${candidates.length}) - assumindo falha de autenticação',
      );
      await UserTokenSaving.clearToken();
      throw Exception(
        'Sessão expirada. Faça login novamente para atualizar a avaliação.',
      );
    }

    throw Exception(
      'Erro ao atualizar avaliação; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<List<UserRatingResponseDTO>> verMinhasAvaliacoes() async {
    final token = await UserTokenSaving.getToken();
    debugPrint(
      '🌟 [RatingService] verMinhasAvaliacoes - Token recuperado: ${token == null ? "NULL" : "PRESENTE (${token.length} chars)"}',
    );
    if (token == null) {
      debugPrint(
        '🌟 [RatingService] ❌ TOKEN NULO - verificar se foi limpo incorretamente',
      );
      throw Exception('Token não encontrado');
    }

    final masked = token.length > 8 ? '${token.substring(0, 8)}...' : token;
    debugPrint(
      '🌟 [RatingService] Token (mascarado) para verMinhasAvaliacoes: $masked',
    );

    final candidates = [
      ..._candidateUris('/restaurantes/ver-minhas-avaliacoes'),
      ..._candidateUris('/restaurantes/avaliacoes'),
    ];
    List<String> errors = [];

    for (final uri in candidates) {
      http.Response? response;
      try {
        response = await http.get(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (e, st) {
        debugPrint('🌟 [RatingService] EXCEPTION ao GET $uri: $e');
        debugPrint('🌟 [RatingService] Stack: $st');
        final msg = e.toString();
        // Detect redirect loop -> likely unauthenticated/OAuth redirect
        if (msg.contains('Redirect loop') || msg.contains('redirect loop')) {
          debugPrint(
            '🌟 [RatingService] ⚠️ REDIRECT LOOP detectado em $uri - continuando para próximo candidato',
          );
          // DO NOT clear token immediately - continue to next candidate
          errors.add('${uri.toString()} => REDIRECT LOOP: $e');
          continue;
        }
        errors.add('${uri.toString()} => EXCEPTION: $e');
        // continue to next candidate instead of failing immediately
        continue;
      }

      debugPrint(
        '🌟 [RatingService] GET $uri -> ${response.statusCode}: ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => UserRatingResponseDTO.fromJson(json))
            .toList();
      }

      // Detect specific backend internal error caused by external service (viacep)
      if (response.statusCode == 500 && response.body.contains('viacep')) {
        debugPrint(
          '🌟 [RatingService] Backend 500 contendo viacep detectado em $uri',
        );
        throw Exception(
          'Serviço temporariamente indisponível (erro no backend ao consultar viacep). Tente mais tarde.',
        );
      }

      // Detect error 400 caused by viacep lookup
      if (response.statusCode == 400 && response.body.contains('CEP')) {
        debugPrint(
          '🌟 [RatingService] Backend 400 de CEP detectado em $uri - continuando para próximo candidato',
        );
        errors.add(
          '${uri.toString()} => ${response.statusCode} (CEP error): ${response.body}',
        );
        continue;
      }

      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );

      // Detect redirects (302) as potential auth failures
      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        debugPrint(
          '🌟 [RatingService] Redirect (${response.statusCode}) detectado em $uri',
        );
        continue;
      }

      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }

      if (response.statusCode == 401) {
        debugPrint('🌟 [RatingService] Recebido 401 em $uri - DELETANDO TOKEN');
        _logTokenClaims(token);
        await UserTokenSaving.clearToken();
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
    final token = await UserTokenSaving.getToken();
    final masked = token != null && token.length > 8
        ? '${token.substring(0, 8)}...'
        : (token ?? 'NULL');
    debugPrint(
      '🌟 [RatingService] Token (mascarado) para listarAvaliacoesPorRestaurante: $masked',
    );

    // Tentativas: 1) endpoints com query idRestaurante 2) endpoints com id no path 3) versões sem query
    final candidates = [
      Uri.parse(
        '$host/usuarios/restaurantes/avaliacoes?idRestaurante=$idRestaurante',
      ),
      Uri.parse('$host/restaurantes/avaliacoes?idRestaurante=$idRestaurante'),
      Uri.parse('$host/usuarios/restaurantes/$idRestaurante/avaliacoes'),
      Uri.parse('$host/restaurantes/$idRestaurante/avaliacoes'),
      Uri.parse('$host/usuarios/restaurantes/avaliacoes'),
      Uri.parse('$host/restaurantes/avaliacoes'),
    ];

    List<String> errors = [];

    for (final uri in candidates) {
      // Primeiro tente com Authorization (se existir token)
      http.Response? response;
      try {
        if (token != null) {
          response = await http.get(
            uri,
            headers: {'Authorization': 'Bearer $token'},
          );
        } else {
          response = await http.get(uri);
        }
      } catch (e) {
        errors.add('${uri.toString()} => EXCEPTION: $e');
        debugPrint('🌟 [RatingService] EXCEPTION ao GET $uri: $e');
        continue;
      }

      debugPrint(
        '🌟 [RatingService] GET $uri -> ${response.statusCode}: ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => UserRatingResponseDTO.fromJson(json))
            .toList();
      }

      // Se falhou e ainda tinha token, tentar versão pública (sem Authorization)
      if (token != null) {
        try {
          final publicResp = await http.get(uri);
          debugPrint(
            '🌟 [RatingService] GET (public) $uri -> ${publicResp.statusCode}: ${publicResp.body}',
          );
          if (publicResp.statusCode == 200) {
            final List<dynamic> data = jsonDecode(publicResp.body);
            return data
                .map((json) => UserRatingResponseDTO.fromJson(json))
                .toList();
          }
          errors.add(
            '${uri.toString()} (public) => ${publicResp.statusCode}: ${publicResp.body}',
          );
        } catch (e) {
          errors.add('${uri.toString()} (public) => EXCEPTION: $e');
        }
      } else {
        errors.add(
          '${uri.toString()} => ${response.statusCode}: ${response.body}',
        );
      }

      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        // Redirect; likely auth issue (deleted account)
        debugPrint(
          '🌟 [RatingService] Redirect (${response.statusCode}) detectado em listarAvaliacoesPorRestaurante',
        );
        continue;
      }

      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }

      if (response.statusCode == 401) {
        // token inválido/expirado
        throw Exception('Usuário não autenticado');
      }

      // continue tentando outras URIs antes de falhar
      continue;
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

    List<String> errors = [];
    int redirectCount = 0;

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

      // Track redirects to detect auth failures
      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        redirectCount++;
        continue;
      }

      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }

      if (response.statusCode == 400) {
        throw Exception('Avaliação não encontrada');
      }
      if (response.statusCode == 401) {
        throw Exception('Usuário não autenticado');
      }
      throw Exception(
        'Erro ao excluir avaliação (${response.statusCode}): ${response.body}',
      );
    }

    // If all candidates returned redirects (302), it's likely auth failure (account deleted)
    if (redirectCount == candidates.length && redirectCount > 0) {
      debugPrint(
        '🌟 [RatingService] Todos os redirects ($redirectCount/${candidates.length}) - assumindo falha de autenticação',
      );
      await UserTokenSaving.clearToken();
      throw Exception(
        'Sessão expirada ou conta removida. Faça login novamente para deletar a avaliação.',
      );
    }

    throw Exception(
      'Erro ao excluir avaliação; tentativas: ${errors.join(' | ')}',
    );
  }

  /// Limpa qualquer cache local de avaliações.
  /// Chamado quando usuário deleta conta para garantir que avaliações órfãs não fiquem em memória.
  static void clearCachedData() {
    debugPrint('🌟 [RatingService] Cache de avaliações limpo');
    // Por enquanto, as avaliações são armazenadas em memória das screens individuais,
    // e são destruídas quando as screens são removidas do widget tree.
    // Este método existe para documentar a intenção e permitir expansão futura com cache global.
  }
}
