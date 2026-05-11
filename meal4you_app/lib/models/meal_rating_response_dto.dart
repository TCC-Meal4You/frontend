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
    String? readStringFrom(dynamic source, List<String> keys) {
      if (source == null) return null;
      if (source is Map) {
        for (final key in keys) {
          final value = source[key];
          if (value == null) continue;
          if (value is String) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) return trimmed;
          } else if (value is Map || value is List) {
            final nested = readStringFrom(value, keys);
            if (nested != null && nested.isNotEmpty) return nested;
          } else {
            final text = value.toString().trim();
            if (text.isNotEmpty && text != 'null') return text;
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

    return MealRatingResponseDTO(
      ratingId: json['idAvaliacao'] ?? 0,
      userId: json['idUsuario'] ?? json['id_usuario'],
      mealId: json['idRefeicao'] ?? json['id_refeicao'],
      mealName: json['nomeRefeicao'] ?? json['mealName'],
      userName:
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
          '',
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
      rating: (json['nota'] ?? 0).toDouble(),
      comment: json['comentario'],
      ratingDate: parsedDate,
      hasTime: hasTimeFlag,
    );
  }
}
