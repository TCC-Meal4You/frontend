class RestauranteResponseDTO {
  final int idRestaurante;
  final String nome;
  final String? descricao;
  final String tipoComida;
  final bool ativo;
  final bool favorito;
  final double? distancia;
  final String? tempoEntrega;
  final double? avaliacaoMedia;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? uf;

  RestauranteResponseDTO({
    required this.idRestaurante,
    required this.nome,
    this.descricao,
    required this.tipoComida,
    required this.ativo,
    required this.favorito,
    this.distancia,
    this.tempoEntrega,
    this.avaliacaoMedia,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.uf,
  });

  String? get formattedAddress {
    final parts = <String>[
      if (logradouro != null && logradouro!.trim().isNotEmpty)
        logradouro!.trim(),
      if (numero != null && numero!.trim().isNotEmpty) numero!.trim(),
      if (complemento != null && complemento!.trim().isNotEmpty)
        complemento!.trim(),
      if (bairro != null && bairro!.trim().isNotEmpty) bairro!.trim(),
      if (cidade != null && cidade!.trim().isNotEmpty) cidade!.trim(),
      if (uf != null && uf!.trim().isNotEmpty) uf!.trim(),
      if (cep != null && cep!.trim().isNotEmpty) cep!.trim(),
    ];
    if (parts.isEmpty) return null;
    parts.add('Brasil');
    return parts.join(', ');
  }

  String? get routeAddress {
    final parts = <String>[
      if (logradouro != null && logradouro!.trim().isNotEmpty)
        logradouro!.trim(),
      if (numero != null && numero!.trim().isNotEmpty) numero!.trim(),
      if (complemento != null && complemento!.trim().isNotEmpty)
        complemento!.trim(),
    ];
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  RestauranteResponseDTO copyWith({
    int? idRestaurante,
    String? nome,
    String? descricao,
    String? tipoComida,
    bool? ativo,
    bool? favorito,
    double? distancia,
    String? tempoEntrega,
    double? avaliacaoMedia,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? uf,
  }) {
    return RestauranteResponseDTO(
      idRestaurante: idRestaurante ?? this.idRestaurante,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tipoComida: tipoComida ?? this.tipoComida,
      ativo: ativo ?? this.ativo,
      favorito: favorito ?? this.favorito,
      distancia: distancia ?? this.distancia,
      tempoEntrega: tempoEntrega ?? this.tempoEntrega,
      avaliacaoMedia: avaliacaoMedia ?? this.avaliacaoMedia,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
    );
  }

  static String? _stringValue(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static String? _extractAddressField(Map<String, dynamic> json, String key) {
    final nested = json['endereco'];
    if (nested is Map && nested[key] != null) {
      return _stringValue(nested[key]);
    }

    final nestedRestaurant = json['restaurante'];
    if (nestedRestaurant is Map && nestedRestaurant[key] != null) {
      return _stringValue(nestedRestaurant[key]);
    }

    final nestedRestaurantAlias = json['restaurant'];
    if (nestedRestaurantAlias is Map && nestedRestaurantAlias[key] != null) {
      return _stringValue(nestedRestaurantAlias[key]);
    }

    final nestedData = json['data'];
    if (nestedData is Map && nestedData[key] != null) {
      return _stringValue(nestedData[key]);
    }

    final direct = _stringValue(json[key]);
    if (direct != null) return direct;

    final addressAlias = json['address'];
    if (addressAlias is Map && addressAlias[key] != null) {
      return _stringValue(addressAlias[key]);
    }

    return null;
  }

  static String? _findFieldRecursive(dynamic value, Set<String> keys) {
    if (value is Map) {
      for (final entry in value.entries) {
        final entryKey = entry.key.toString();
        final entryValue = entry.value;

        if (keys.contains(entryKey)) {
          final resolved = _stringValue(entryValue);
          if (resolved != null) {
            return resolved;
          }
        }

        final nestedResult = _findFieldRecursive(entryValue, keys);
        if (nestedResult != null) {
          return nestedResult;
        }
      }
    }

    if (value is Iterable) {
      for (final item in value) {
        final nestedResult = _findFieldRecursive(item, keys);
        if (nestedResult != null) {
          return nestedResult;
        }
      }
    }

    return null;
  }

  static dynamic _findValueRecursive(dynamic value, Set<String> keys) {
    if (value is Map) {
      for (final entry in value.entries) {
        final entryKey = entry.key.toString();
        final entryValue = entry.value;

        if (keys.contains(entryKey)) {
          return entryValue;
        }

        final nestedResult = _findValueRecursive(entryValue, keys);
        if (nestedResult != null) {
          return nestedResult;
        }
      }
    }

    if (value is Iterable) {
      for (final item in value) {
        final nestedResult = _findValueRecursive(item, keys);
        if (nestedResult != null) {
          return nestedResult;
        }
      }
    }

    return null;
  }

  static Map<String, dynamic> _unwrapJson(Map<String, dynamic> json) {
    final candidates = [json['data'], json['restaurante'], json['restaurant']];
    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        return candidate;
      }
      if (candidate is Map) {
        return Map<String, dynamic>.from(candidate);
      }
    }
    return json;
  }

  factory RestauranteResponseDTO.fromJson(Map<String, dynamic> json) {
    final source = _unwrapJson(json);
    print('[RestauranteResponseDTO] fromJson source=$source');
    final idValue = _findValueRecursive(source, {'idRestaurante', 'id'});
    final nomeValue = _findValueRecursive(source, {'nome'});
    final descricaoValue = _findValueRecursive(source, {'descricao'});
    final tipoComidaValue = _findValueRecursive(source, {'tipoComida'});
    final ativoValue = _findValueRecursive(source, {'ativo'});
    final favoritoValue = _findValueRecursive(source, {'favorito'});
    final distanciaValue = _findValueRecursive(source, {'distancia'});
    final tempoEntregaValue = _findValueRecursive(source, {'tempoEntrega'});
    final avaliacaoMediaValue = _findValueRecursive(source, {'avaliacaoMedia'});

    return RestauranteResponseDTO(
      idRestaurante: int.tryParse(idValue?.toString() ?? '') ?? 0,
      nome: nomeValue?.toString() ?? '',
      descricao: descricaoValue?.toString(),
      tipoComida: tipoComidaValue?.toString() ?? '',
      ativo: ativoValue is bool
          ? ativoValue
          : ativoValue?.toString().toLowerCase() == 'true',
      favorito: favoritoValue is bool
          ? favoritoValue
          : favoritoValue?.toString().toLowerCase() == 'true',
      distancia: distanciaValue != null
          ? (distanciaValue as num?)?.toDouble() ??
                double.tryParse(distanciaValue.toString())
          : null,
      tempoEntrega: tempoEntregaValue?.toString(),
      avaliacaoMedia: avaliacaoMediaValue != null
          ? (avaliacaoMediaValue as num?)?.toDouble() ??
                double.tryParse(avaliacaoMediaValue.toString())
          : null,
      cep:
          _extractAddressField(source, 'cep') ??
          _findFieldRecursive(source, {'cep'}),
      logradouro:
          _extractAddressField(source, 'logradouro') ??
          _findFieldRecursive(source, {'logradouro', 'rua', 'street'}),
      numero:
          _extractAddressField(source, 'numero') ??
          _findFieldRecursive(source, {'numero', 'number', 'numeroEndereco'}),
      complemento:
          _extractAddressField(source, 'complemento') ??
          _findFieldRecursive(source, {'complemento'}),
      bairro:
          _extractAddressField(source, 'bairro') ??
          _findFieldRecursive(source, {'bairro'}),
      cidade:
          _extractAddressField(source, 'cidade') ??
          _findFieldRecursive(source, {'cidade', 'localidade'}),
      uf:
          _extractAddressField(source, 'uf') ??
          _findFieldRecursive(source, {'uf', 'estado'}),
    );
  }
}
