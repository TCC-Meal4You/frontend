class MealRatingRequestDTO {
  final int idRefeicao;
  final double nota;
  final String? comentario;

  MealRatingRequestDTO({
    required this.idRefeicao,
    required this.nota,
    this.comentario,
  });

  Map<String, dynamic> toJson() {
    return {
      'idRefeicao': idRefeicao,
      'nota': nota,
      if (comentario != null) 'comentario': comentario,
    };
  }
}
