class RestrictionResponseDTO {
  final int idRestricao;
  final String nome;

  RestrictionResponseDTO({required this.idRestricao, required this.nome});

  factory RestrictionResponseDTO.fromJson(Map<String, dynamic> json) {
    return RestrictionResponseDTO(
      idRestricao: json['idRestricao'] ?? json['id_restricao'] ?? 0,
      nome: (json['tipo'] ?? json['nome'] ?? '').toString(),
    );
  }
}
