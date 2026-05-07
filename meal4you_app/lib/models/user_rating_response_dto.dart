class UserRatingResponseDTO {
  final int ratingId;
  final int? userId;
  final int? restaurantId;
  final String? restaurantName;
  final String userName;
  final String? userEmail;
  final double rating;
  final String? comment;
  final DateTime ratingDate;
  final bool hasTime;

  UserRatingResponseDTO({
    required this.ratingId,
    this.userId,
    this.restaurantId,
    this.restaurantName,
    required this.userName,
    this.userEmail,
    required this.rating,
    this.comment,
    required this.ratingDate,
    this.hasTime = false,
  });

  factory UserRatingResponseDTO.fromJson(Map<String, dynamic> json) {
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

      final directPatterns = [
        RegExp(r'^(\d{2})/(\d{2})/(\d{4})[ T](\d{2}):(\d{2})(?::(\d{2}))?$'),
        RegExp(r'^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?$'),
      ];

      for (final pattern in directPatterns) {
        final match = pattern.firstMatch(raw);
        if (match != null) {
          final groups = [
            match.group(1),
            match.group(2),
            match.group(3),
            match.group(4),
            match.group(5),
            match.group(6),
          ];

          if (pattern.pattern.startsWith('^(\\d{2})')) {
            final day = int.tryParse(groups[0] ?? '');
            final month = int.tryParse(groups[1] ?? '');
            final year = int.tryParse(groups[2] ?? '');
            final hour = int.tryParse(groups[3] ?? '0') ?? 0;
            final minute = int.tryParse(groups[4] ?? '0') ?? 0;
            final second = int.tryParse(groups[5] ?? '0') ?? 0;
            if (day != null && month != null && year != null) {
              return DateTime(year, month, day, hour, minute, second);
            }
          } else {
            final year = int.tryParse(groups[0] ?? '');
            final month = int.tryParse(groups[1] ?? '');
            final day = int.tryParse(groups[2] ?? '');
            final hour = int.tryParse(groups[3] ?? '0') ?? 0;
            final minute = int.tryParse(groups[4] ?? '0') ?? 0;
            final second = int.tryParse(groups[5] ?? '0') ?? 0;
            if (day != null && month != null && year != null) {
              return DateTime(year, month, day, hour, minute, second);
            }
          }
        }
      }

      final normalized = raw
          .replaceAll('T', ' ')
          .replaceAll('Z', '')
          .replaceAll('z', '');
      final parts = normalized.split(' ');

      final dateParts = parts.first.split('/');
      if (dateParts.length == 3) {
        final day = int.tryParse(dateParts[0]);
        final month = int.tryParse(dateParts[1]);
        final year = int.tryParse(dateParts[2]);
        if (day != null && month != null && year != null) {
          if (parts.length > 1) {
            final timeParts = parts[1].split(':');
            final hour = int.tryParse(timeParts[0]) ?? 0;
            final minute = timeParts.length > 1
                ? int.tryParse(timeParts[1]) ?? 0
                : 0;
            final second = timeParts.length > 2
                ? int.tryParse(timeParts[2]) ?? 0
                : 0;
            return DateTime(year, month, day, hour, minute, second);
          }

          return DateTime(year, month, day);
        }
      }

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

    return UserRatingResponseDTO(
      ratingId: json['idAvaliacao'] ?? 0,
      userId: json['idUsuario'] ?? json['id_usuario'],
      restaurantId: json['idRestaurante'] ?? json['id_restaurante'],
      restaurantName: json['nomeRestaurante'] ?? json['restaurantName'],
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
