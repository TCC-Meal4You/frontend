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
  });

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
    );
  }
}
