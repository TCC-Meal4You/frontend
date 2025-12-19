class IngredientResponseDTO {
  final int idIngrediente;
  final String nome;
  final List<String> restricoes;

  IngredientResponseDTO({
    required this.idIngrediente,
    required this.nome,
    required this.restricoes,
  });

  factory IngredientResponseDTO.fromJson(Map<String, dynamic> json) {
    return IngredientResponseDTO(
      idIngrediente: json['idIngrediente'] ?? json['id_ingrediente'] ?? 0,
      nome: json['nome'] ?? '',
      restricoes:
          (json['restricoes'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  return e['tipo'] ?? e['nome'] ?? '';
                }
                return e.toString();
              })
              .where((r) => r.isNotEmpty)
              .toList()
              .cast<String>() ??
          [],
    );
  }
}
