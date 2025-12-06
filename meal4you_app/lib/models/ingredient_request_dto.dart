class IngredientRequestDTO {
  final String nome;
  final List<int> restricoesIds;

  IngredientRequestDTO({required this.nome, this.restricoesIds = const []});

  Map<String, dynamic> toJson() {
    return {'nome': nome, 'restricoesIds': restricoesIds};
  }
}
