import 'package:meal4you_app/models/meal_response_dto.dart';

class PaginacaoRefeicoesResponseDTO {
  final List<MealResponseDTO> refeicoes;
  final int totalPaginas;
  final int paginaAtual;

  PaginacaoRefeicoesResponseDTO({
    required this.refeicoes,
    required this.totalPaginas,
    required this.paginaAtual,
  });

  factory PaginacaoRefeicoesResponseDTO.fromJson(Map<String, dynamic> json) {
    final refeicoesList =
        (json['refeicoes'] as List<dynamic>?)
            ?.map((item) => MealResponseDTO.fromJson(item))
            .toList() ??
        [];

    return PaginacaoRefeicoesResponseDTO(
      refeicoes: refeicoesList,
      totalPaginas: json['totalPaginas'] ?? 0,
      paginaAtual: json['paginaAtual'] ?? 0,
    );
  }
}
