class MealResponseDTO {
  final int idRefeicao;
  final String nome;
  final double preco;
  final String tipo;
  final String? descricao;
  final bool disponivel;
  final List<MealIngredientDTO> ingredientes;
  final List<String> restricoes;

  MealResponseDTO({
    required this.idRefeicao,
    required this.nome,
    required this.preco,
    required this.tipo,
    this.descricao,
    required this.disponivel,
    required this.ingredientes,
    required this.restricoes,
  });

  factory MealResponseDTO.fromJson(Map<String, dynamic> json) {
    final ingredientesJson = json['ingredientes'] ?? json['ingrediente'];
    final restricoesJson = json['restricoes'] ?? json['restricao'];

    final restricoesList =
        (restricoesJson as List<dynamic>?)
            ?.map((e) {
              if (e is Map<String, dynamic>) {
                return e['tipo']?.toString() ?? '';
              }
              return e.toString();
            })
            .where((r) => r.isNotEmpty)
            .toList() ??
        [];

    final ingredientesList =
        (ingredientesJson as List<dynamic>?)
            ?.map((e) => MealIngredientDTO.fromJson(e, restricoesList))
            .toList() ??
        [];

    return MealResponseDTO(
      idRefeicao: json['idRefeicao'] ?? json['id_refeicao'] ?? 0,
      nome: json['nome'] ?? '',
      preco: (json['preco'] ?? 0).toDouble(),
      tipo: json['tipo'] ?? '',
      descricao: json['descricao'],
      disponivel: json['disponivel'] ?? false,
      ingredientes: ingredientesList,
      restricoes: restricoesList,
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

  factory MealIngredientDTO.fromJson(
    Map<String, dynamic> json,
    List<String> restricoesDaRefeicao,
  ) {
    return MealIngredientDTO(
      idIngrediente: json['idIngrediente'] ?? json['id_ingrediente'] ?? 0,
      nome: json['nome'] ?? '',
      restricoes: restricoesDaRefeicao,
    );
  }
}
