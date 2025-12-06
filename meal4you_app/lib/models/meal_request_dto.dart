class MealRequestDTO {
  final String nome;
  final double preco;
  final String tipo;
  final String? descricao;
  final bool disponivel;
  final List<int> ingredientesIds;

  MealRequestDTO({
    required this.nome,
    required this.preco,
    required this.tipo,
    this.descricao,
    required this.disponivel,
    required this.ingredientesIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'preco': preco,
      'tipo': tipo,
      'descricao': descricao,
      'disponivel': disponivel,
      'ingredientesIds': ingredientesIds,
    };
  }
}
