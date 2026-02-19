import 'package:meal4you_app/models/restaurante_response_dto.dart';

class PaginacaoRestauranteResponseDTO {
  final List<RestauranteResponseDTO> restaurantes;
  final int totalPaginas;
  final int paginaAtual;

  PaginacaoRestauranteResponseDTO({
    required this.restaurantes,
    required this.totalPaginas,
    required this.paginaAtual,
  });

  factory PaginacaoRestauranteResponseDTO.fromJson(Map<String, dynamic> json) {
    final restaurantesList =
        (json['restaurantes'] as List<dynamic>?)
            ?.map((item) => RestauranteResponseDTO.fromJson(item))
            .toList() ??
        [];

    return PaginacaoRestauranteResponseDTO(
      restaurantes: restaurantesList,
      totalPaginas: json['totalPaginas'] ?? 0,
      paginaAtual: json['paginaAtual'] ?? 0,
    );
  }
}
