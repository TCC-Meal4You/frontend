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

    final direct = _stringValue(json[key]);
    if (direct != null) return direct;

    final addressAlias = json['address'];
    if (addressAlias is Map && addressAlias[key] != null) {
      return _stringValue(addressAlias[key]);
    }

    return null;
  }

  factory RestauranteResponseDTO.fromJson(Map<String, dynamic> json) {
    return RestauranteResponseDTO(
      idRestaurante: json['idRestaurante'] ?? json['id'] ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      tipoComida: json['tipoComida'] ?? '',
      ativo: json['ativo'] ?? false,
      favorito: json['favorito'] ?? false,
      distancia: json['distancia'] != null
          ? (json['distancia'] as num).toDouble()
          : null,
      tempoEntrega: json['tempoEntrega'],
      avaliacaoMedia: json['avaliacaoMedia'] != null
          ? (json['avaliacaoMedia'] as num).toDouble()
          : null,
      cep: _extractAddressField(json, 'cep'),
      logradouro: _extractAddressField(json, 'logradouro'),
      numero: _extractAddressField(json, 'numero'),
      complemento: _extractAddressField(json, 'complemento'),
      bairro: _extractAddressField(json, 'bairro'),
      cidade: _extractAddressField(json, 'cidade'),
      uf: _extractAddressField(json, 'uf'),
    );
  }
}
