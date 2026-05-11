import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/models/user_rating_request_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/models/meal_rating_request_dto.dart';
import 'package:meal4you_app/models/meal_rating_response_dto.dart';

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
    try {
      jsonDecode(decoded);
    } catch (_) {
      return;
    }
  } catch (_) {
    return;
  }
}

String? _extractTextValue(dynamic source, List<String> keys) {
  if (source == null) return null;
  if (source is Map) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) return trimmed;
      } else if (value is Map || value is List) {
        final nested = _extractTextValue(value, keys);
        if (nested != null && nested.isNotEmpty) return nested;
      } else {
        final text = value.toString().trim();
        if (text.isNotEmpty && text != 'null') return text;
      }
    }
    for (final value in source.values) {
      final nested = _extractTextValue(value, keys);
      if (nested != null && nested.isNotEmpty) return nested;
    }
  }
  if (source is List) {
    for (final value in source) {
      final nested = _extractTextValue(value, keys);
      if (nested != null && nested.isNotEmpty) return nested;
    }
  }
  return null;
}

class RatingService {
  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);
  static final Map<int, String> _userNameCache = <int, String>{};
  static final Set<int> _resolvingUserIds = <int>{};
  static const String host = 'https://backend-production-b24f.up.railway.app';
  static List<Uri> _candidateUris(String pathWithLeadingSlash) {
    return [
      Uri.parse('$host/usuarios$pathWithLeadingSlash'),
      Uri.parse('$host$pathWithLeadingSlash'),
    ];
  }

  static Future<String?> _resolveUserNameById(int userId) async {
    final cached = _userNameCache[userId];
    if (cached != null && cached.trim().isNotEmpty) {
      return cached;
    }
    final token = await UserTokenSaving.getToken();
    final candidates = [
      Uri.parse('$host/usuarios/$userId'),
      Uri.parse('$host/usuarios/perfil/$userId'),
      Uri.parse('$host/usuarios?idUsuario=$userId'),
      Uri.parse('$host/usuarios?id=$userId'),
      Uri.parse('$host/clientes/$userId'),
    ];
    for (final uri in candidates) {
      try {
        final response = await http.get(
          uri,
          headers: token == null
              ? const <String, String>{}
              : {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode != 200) {
          continue;
        }
        final decoded = jsonDecode(response.body);
        final resolvedName = _extractTextValue(decoded, [
          'nomeUsuario',
          'nomeCliente',
          'nomeAutor',
          'usuarioNome',
          'userName',
          'nome',
          'clienteNome',
          'autorNome',
          'avaliadorNome',
          'nomeCompleto',
          'nome_completo',
          'fullName',
          'full_name',
          'primeiroNome',
          'firstName',
          'usuario_nome',
        ]);
        if (resolvedName != null && resolvedName.trim().isNotEmpty) {
          _userNameCache[userId] = resolvedName.trim();
          return resolvedName.trim();
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> _normalizeRatingsPayload(
    List<dynamic> data,
  ) async {
    final maps = data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    // Build map list and schedule background name resolution for missing authors.
    final idsToResolve = <int>{};
    for (final item in maps) {
      final currentName = _extractTextValue(item, [
        'nomeUsuario',
        'nomeCliente',
        'nomeAutor',
        'usuarioNome',
        'userName',
        'nome',
        'clienteNome',
        'autorNome',
        'avaliadorNome',
        'nomeCompleto',
        'nome_completo',
        'fullName',
        'full_name',
        'primeiroNome',
        'firstName',
        'usuario_nome',
      ]);
      if (currentName != null && currentName.trim().isNotEmpty) {
        continue;
      }
      final rawUserId = item['idUsuario'] ?? item['id_usuario'];
      final userId = int.tryParse(rawUserId.toString());
      if (userId != null) {
        // If we already have a cached name, fill it immediately.
        final cached = _userNameCache[userId];
        if (cached != null && cached.trim().isNotEmpty) {
          item['nomeUsuario'] = cached;
          continue;
        }
        if (!_resolvingUserIds.contains(userId)) idsToResolve.add(userId);
      }
    }

    // Schedule background resolution for each id (non-blocking).
    for (final id in idsToResolve) {
      _resolvingUserIds.add(id);
      _resolveUserNameById(id)
          .then((resolved) {
            if (resolved != null && resolved.trim().isNotEmpty) {
              _userNameCache[id] = resolved.trim();
              notifyChanged();
            }
          })
          .catchError((_) {})
          .whenComplete(() => _resolvingUserIds.remove(id));
    }

    return maps;
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
        final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: requestBody,
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          notifyChanged();
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
      if (response.statusCode == 200) {
        notifyChanged();
        return UserRatingResponseDTO.fromJson(jsonDecode(response.body));
      }
      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
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
        notifyChanged();
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
    if (redirectCount == candidates.length && redirectCount > 0) {
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
    if (token == null) {
      throw Exception('Token não encontrado');
    }
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
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('Redirect loop') || msg.contains('redirect loop')) {
          errors.add('${uri.toString()} => REDIRECT LOOP: $e');
          continue;
        }
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final normalized = await _normalizeRatingsPayload(data);
        return normalized
            .map((json) => UserRatingResponseDTO.fromJson(json))
            .toList();
      }
      if (response.statusCode == 500 && response.body.contains('viacep')) {
        throw Exception(
          'Serviço temporariamente indisponível (erro no backend ao consultar viacep). Tente mais tarde.',
        );
      }
      if (response.statusCode == 400 && response.body.contains('CEP')) {
        errors.add(
          '${uri.toString()} => ${response.statusCode} (CEP error): ${response.body}',
        );
        continue;
      }
      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        continue;
      }
      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }
      if (response.statusCode == 401) {
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
        continue;
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => UserRatingResponseDTO.fromJson(json))
            .toList();
      }
      if (token != null) {
        try {
          final publicResp = await http.get(uri);
          if (publicResp.statusCode == 200) {
            final List<dynamic> data = jsonDecode(publicResp.body);
            final normalized = await _normalizeRatingsPayload(data);
            return normalized
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
        continue;
      }
      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }
      if (response.statusCode == 401) {
        throw Exception('Usuário não autenticado');
      }
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
      if (response.statusCode == 200) return;
      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
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
    if (redirectCount == candidates.length && redirectCount > 0) {
      await UserTokenSaving.clearToken();
      throw Exception(
        'Sessão expirada ou conta removida. Faça login novamente para deletar a avaliação.',
      );
    }
    throw Exception(
      'Erro ao excluir avaliação; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<MealRatingResponseDTO> avaliarRefeicao(
    MealRatingRequestDTO dto,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) throw Exception('Token não encontrado');
    final requestBody = jsonEncode(dto.toJson());
    final candidates = _candidateUris('/refeicoes/avaliar');
    List<String> errors = [];
    for (final uri in candidates) {
      try {
        final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: requestBody,
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return MealRatingResponseDTO.fromJson(jsonDecode(response.body));
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
        if (response.statusCode == 409) {
          throw Exception('Você já avaliou esta refeição');
        }
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
    final requestBody = jsonEncode(dto.toJson());
    final candidates = _candidateUris('/refeicoes/atualizar-avaliacao');
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
      if (response.statusCode == 200) {
        return MealRatingResponseDTO.fromJson(jsonDecode(response.body));
      }
      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
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
        throw Exception('Refeição ou avaliação não encontrados');
      }
      throw Exception(
        'Erro ao atualizar avaliação de refeição (${response.statusCode}): ${response.body}',
      );
    }
    if (redirectCount == candidates.length && redirectCount > 0) {
      await UserTokenSaving.clearToken();
      throw Exception(
        'Sessão expirada. Faça login novamente para atualizar a avaliação.',
      );
    }
    throw Exception(
      'Erro ao atualizar avaliação de refeição; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<List<MealRatingResponseDTO>>
  verMinhasAvaliacoesDRefeicao() async {
    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }
    final candidates = [
      ..._candidateUris('/refeicoes/minhas-avaliacoes'),
      ..._candidateUris('/refeicoes/avaliacoes'),
    ];
    List<String> errors = [];
    for (final uri in candidates) {
      http.Response? response;
      try {
        response = await http.get(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('Redirect loop') || msg.contains('redirect loop')) {
          errors.add('${uri.toString()} => REDIRECT LOOP: $e');
          continue;
        }
        errors.add('${uri.toString()} => EXCEPTION: $e');
        continue;
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final normalized = await _normalizeRatingsPayload(data);
        return normalized
            .map((json) => MealRatingResponseDTO.fromJson(json))
            .toList();
      }
      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        continue;
      }
      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }
      if (response.statusCode == 401) {
        _logTokenClaims(token);
        await UserTokenSaving.clearToken();
        throw Exception('Usuário não autenticado');
      }
      throw Exception(
        'Erro ao buscar avaliações de refeição (${response.statusCode})',
      );
    }
    throw Exception(
      'Erro ao buscar avaliações de refeição; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<List<MealRatingResponseDTO>> listarAvaliacoesPorRefeicao(
    int idRefeicao,
  ) async {
    final token = await UserTokenSaving.getToken();
    final candidates = [
      Uri.parse('$host/usuarios/refeicoes/avaliacoes?idRefeicao=$idRefeicao'),
      Uri.parse('$host/refeicoes/$idRefeicao/avaliacoes'),
      Uri.parse('$host/usuarios/refeicoes/$idRefeicao/avaliacoes'),
      Uri.parse('$host/refeicoes/avaliacoes?idRefeicao=$idRefeicao'),
    ];
    List<String> errors = [];
    for (final uri in candidates) {
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
        continue;
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => MealRatingResponseDTO.fromJson(json))
            .toList();
      }
      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        continue;
      }
      if (response.statusCode == 404 || response.statusCode == 405) {
        continue;
      }
      if (response.statusCode == 401) {
        throw Exception('Usuário não autenticado');
      }
      continue;
    }
    throw Exception(
      'Erro ao buscar avaliações de refeição; tentativas: ${errors.join(' | ')}',
    );
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
    List<String> errors = [];
    int redirectCount = 0;
    for (final uri in candidates) {
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return;
      errors.add(
        '${uri.toString()} => ${response.statusCode}: ${response.body}',
      );
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
        'Erro ao excluir avaliação de refeição (${response.statusCode}): ${response.body}',
      );
    }
    if (redirectCount == candidates.length && redirectCount > 0) {
      await UserTokenSaving.clearToken();
      throw Exception(
        'Sessão expirada ou conta removida. Faça login novamente para deletar a avaliação.',
      );
    }
    throw Exception(
      'Erro ao excluir avaliação de refeição; tentativas: ${errors.join(' | ')}',
    );
  }

  static Future<int> contarAvaliacoes() async {
    try {
      final avaliacoesRestaurante = await verMinhasAvaliacoes();
      final avaliacoesRefeicao = await verMinhasAvaliacoesDRefeicao();
      return avaliacoesRestaurante.length + avaliacoesRefeicao.length;
    } catch (e) {
      return 0;
    }
  }

  static void clearCachedData() {}

  static void notifyChanged() {
    changeNotifier.value += 1;
  }
}
