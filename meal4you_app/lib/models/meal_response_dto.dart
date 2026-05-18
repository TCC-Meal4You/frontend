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
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
    }

    int? resolveRestaurantId() {
      final direct = parseInt(
        json['idRestaurante'] ??
            json['id_restaurante'] ??
            json['restauranteId'] ??
            json['restaurantId'],
      );

      if (direct != null) return direct;

      final restaurante = json['restaurante'] ?? json['restaurant'];

      if (restaurante is Map) {
        return parseInt(
          restaurante['idRestaurante'] ??
              restaurante['id'] ??
              restaurante['id_restaurante'],
        );
      }

      return null;
    }

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
            ?.whereType<Map>()
            .map(
              (e) => MealIngredientDTO.fromJson(
                Map<String, dynamic>.from(e),
                restricoesList,
              ),
            )
            .toList() ??
        [];

    return MealResponseDTO(
      idRefeicao:
          parseInt(json['idRefeicao'] ?? json['id_refeicao'] ?? json['id']) ??
          0,
      idRestaurante: resolveRestaurantId(),
      nome: json['nome']?.toString() ?? '',
      preco: parseDouble(json['preco']),
      tipo: json['tipo']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
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
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return MealIngredientDTO(
      idIngrediente: parseInt(
        json['idIngrediente'] ?? json['id_ingrediente'] ?? json['id'],
      ),
      nome: json['nome']?.toString() ?? '',
      restricoes: restricoesDaRefeicao,
    );
  }
}