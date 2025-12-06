class MealResponseDTO {
  final int idRefeicao;
  final String nome;
  final double preco;
  final String tipo;
  final String? descricao;
  final bool disponivel;
  final List<MealIngredientDTO> ingredientes;

  MealResponseDTO({
    required this.idRefeicao,
    required this.nome,
    required this.preco,
    required this.tipo,
    this.descricao,
    required this.disponivel,
    required this.ingredientes,
  });

  factory MealResponseDTO.fromJson(Map<String, dynamic> json) {
    // Tenta pegar 'ingredientes' primeiro, depois 'ingrediente'
    final ingredientesJson = json['ingredientes'] ?? json['ingrediente'];

    return MealResponseDTO(
      idRefeicao: json['idRefeicao'] ?? json['id_refeicao'] ?? 0,
      nome: json['nome'] ?? '',
      preco: (json['preco'] ?? 0).toDouble(),
      tipo: json['tipo'] ?? '',
      descricao: json['descricao'],
      disponivel: json['disponivel'] ?? false,
      ingredientes:
          (ingredientesJson as List<dynamic>?)
              ?.map((e) => MealIngredientDTO.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MealIngredientDTO {
  final int idIngrediente;
  final String nome;
  final List<String> restricoes;

  MealIngredientDTO({
    required this.idIngrediente,
    required this.nome,
    required this.restricoes,
  });

  factory MealIngredientDTO.fromJson(Map<String, dynamic> json) {
    return MealIngredientDTO(
      idIngrediente: json['idIngrediente'] ?? json['id_ingrediente'] ?? 0,
      nome: json['nome'] ?? '',
      restricoes:
          (json['restricoes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
