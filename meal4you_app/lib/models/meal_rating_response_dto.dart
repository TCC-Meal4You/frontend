bool _looksLikeAnonymousUserLabel(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return true;
  if (normalized == 'usuário' || normalized == 'usuario') return true;
  if (normalized.startsWith('usuário #') ||
      normalized.startsWith('usuario #')) {
    return true;
  }
  if (normalized.startsWith('user #')) return true;
  return false;
}

class MealRatingResponseDTO {
  final int ratingId;
  final int? userId;
  final int? mealId;
  final String? mealName;
  final String userName;
  final String? userEmail;
  final double rating;
  final String? comment;
  final DateTime ratingDate;
  final bool hasTime;

  MealRatingResponseDTO({
    required this.ratingId,
    this.userId,
    this.mealId,
    this.mealName,
    required this.userName,
    this.userEmail,
    required this.rating,
    this.comment,
    required this.ratingDate,
    this.hasTime = false,
  });

  factory MealRatingResponseDTO.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
    }

    String? readStringFrom(dynamic source, List<String> keys) {
      if (source == null) return null;
      if (source is Map) {
        for (final key in keys) {
          final value = source[key];
          if (value == null) continue;
          if (value is String) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty && !_looksLikeAnonymousUserLabel(trimmed)) {
              return trimmed;
            }
          } else if (value is Map || value is List) {
            final nested = readStringFrom(value, keys);
            if (nested != null && nested.isNotEmpty) return nested;
          } else {
            final text = value.toString().trim();
            if (text.isNotEmpty &&
                text != 'null' &&
                !_looksLikeAnonymousUserLabel(text)) {
              return text;
            }
          }
        }
        for (final value in source.values) {
          final nested = readStringFrom(value, keys);
          if (nested != null && nested.isNotEmpty) return nested;
        }
      }
      if (source is List) {
        for (final value in source) {
          final nested = readStringFrom(value, keys);
          if (nested != null && nested.isNotEmpty) return nested;
        }
      }
      return null;
    }

    dynamic findValueFrom(dynamic source, List<String> keys) {
      if (source == null) return null;
      if (source is Map) {
        for (final key in keys) {
          if (source.containsKey(key) && source[key] != null) {
            return source[key];
          }
        }
        for (final value in source.values) {
          final nested = findValueFrom(value, keys);
          if (nested != null) return nested;
        }
      }
      if (source is List) {
        for (final value in source) {
          final nested = findValueFrom(value, keys);
          if (nested != null) return nested;
        }
      }
      return null;
    }

    String? readMealName(dynamic source) {
      if (source == null) return null;
      if (source is Map) {
        final direct =
            source['nomeRefeicao'] ??
            source['refeicaoNome'] ??
            source['mealName'] ??
            source['nomePrato'] ??
            source['pratoNome'] ??
            source['nome'] ??
            source['name'];
        if (direct is String && direct.trim().isNotEmpty) {
          return direct.trim();
        }

        final nestedKeys = ['refeicao', 'meal', 'data'];
        for (final key in nestedKeys) {
          final nested = source[key];
          final nestedName = readMealName(nested);
          if (nestedName != null && nestedName.isNotEmpty) {
            return nestedName;
          }
        }

        for (final value in source.values) {
          final nestedName = readMealName(value);
          if (nestedName != null && nestedName.isNotEmpty) {
            return nestedName;
          }
        }
      }

      if (source is List) {
        for (final value in source) {
          final nestedName = readMealName(value);
          if (nestedName != null && nestedName.isNotEmpty) {
            return nestedName;
          }
        }
      }

      return null;
    }

    DateTime parseRatingDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is int) {
        if (value > 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
        }
        if (value > 1000000000) {
          return DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
        }
      }
      final raw = value.toString().trim();
      if (raw.isEmpty) return DateTime.now();
      final iso = DateTime.tryParse(raw);
      if (iso != null) return iso.toLocal();
      return DateTime.now();
    }

    final rawDateValue = findValueFrom(json, [
      'dataAvaliacao',
      'createdAt',
      'dataCriacao',
      'dataCadastro',
      'dataHoraAvaliacao',
      'timestamp',
      'created_at',
      'updatedAt',
      'data',
    ]);

    bool detectHasTime(dynamic value) {
      if (value == null) return false;
      if (value is int) return true;
      final s = value.toString();
      if (s.contains('T') || s.contains(':')) return true;
      return false;
    }

    final parsedDate = parseRatingDate(rawDateValue);
    final hasTimeFlag = detectHasTime(rawDateValue);
    final userName =
        readStringFrom(json, [
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
        ]) ??
        '';
    final rawMealId = findValueFrom(json, [
      'idRefeicao',
      'id_refeicao',
      'refeicaoId',
      'mealId',
      'idMeal',
    ]);
    final rawUserId = findValueFrom(json, [
      'idUsuario',
      'id_usuario',
      'usuarioId',
      'userId',
      'clienteId',
      'idCliente',
    ]);
    final rawRatingId = findValueFrom(json, [
      'idAvaliacao',
      'id_avaliacao',
      'avaliacaoId',
      'ratingId',
      'id',
    ]);
    final rawMealName = readStringFrom(json, [
      'nomeRefeicao',
      'refeicaoNome',
      'mealName',
      'nomePrato',
      'pratoNome',
    ]);
    final rawRating = findValueFrom(json, [
      'nota',
      'rating',
      'avaliacao',
      'estrelas',
      'score',
    ]);

    return MealRatingResponseDTO(
      ratingId: parseInt(rawRatingId) ?? 0,
      userId: parseInt(rawUserId),
      mealId: parseInt(rawMealId),
      mealName: rawMealName ?? readMealName(json),
      userName: userName,
      userEmail: readStringFrom(json, [
        'email',
        'emailUsuario',
        'usuarioEmail',
        'clienteEmail',
        'autorEmail',
        'avaliadorEmail',
        'userEmail',
        'mail',
      ]),
      rating: parseDouble(rawRating),
      comment: findValueFrom(json, [
        'comentario',
        'comment',
        'descricao',
        'observacao',
      ])?.toString(),
      ratingDate: parsedDate,
      hasTime: hasTimeFlag,
    );
  }
}
