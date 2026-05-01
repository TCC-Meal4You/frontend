class MealResponseDTO {
  final int idRefeicao;
  final int? idRestaurante;
  final String nome;
  final double preco;
  final String tipo;
  final String? descricao;
  final bool disponivel;
  final bool favorito;
  final List<MealIngredientDTO> ingredientes;
  final List<String> restricoes;

  MealResponseDTO({
    required this.idRefeicao,
    this.idRestaurante,
    required this.nome,
    required this.preco,
    required this.tipo,
    this.descricao,
    required this.disponivel,
    required this.favorito,
    required this.ingredientes,
    required this.restricoes,
  });

  MealResponseDTO copyWith({
    int? idRefeicao,
    int? idRestaurante,
    String? nome,
    double? preco,
    String? tipo,
    String? descricao,
    bool? disponivel,
    bool? favorito,
    List<MealIngredientDTO>? ingredientes,
    List<String>? restricoes,
  }) {
    return MealResponseDTO(
      idRefeicao: idRefeicao ?? this.idRefeicao,
      idRestaurante: idRestaurante ?? this.idRestaurante,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      disponivel: disponivel ?? this.disponivel,
      favorito: favorito ?? this.favorito,
      ingredientes: ingredientes ?? this.ingredientes,
      restricoes: restricoes ?? this.restricoes,
    );
  }

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
      idRefeicao: json['idRefeicao'] ?? json['id_refeicao'] ?? json['id'] ?? 0,
      idRestaurante: json['idRestaurante'] ?? json['id_restaurante'],
      nome: json['nome'] ?? '',
      preco: (json['preco'] ?? 0).toDouble(),
      tipo: json['tipo'] ?? '',
      descricao: json['descricao'],
      disponivel: json['disponivel'] ?? false,
      favorito: json['favorito'] ?? false,
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
