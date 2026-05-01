class UsuarioAvaliaRequestDTO {
  final int idRestaurante;
  final double nota;
  final String? comentario;

  UsuarioAvaliaRequestDTO({
    required this.idRestaurante,
    required this.nota,
    this.comentario,
  });

  Map<String, dynamic> toJson() {
    return {
      'idRestaurante': idRestaurante,
      'nota': nota,
      if (comentario != null) 'comentario': comentario,
    };
  }
}
