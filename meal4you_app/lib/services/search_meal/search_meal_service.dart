import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/models/paginacao_refeicoes_response_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class SearchMealService {
  static const String host = 'https://backend-production-b24f.up.railway.app';
  static const String baseUrl = '$host/refeicoes';
  static Future<PaginacaoRefeicoesResponseDTO> listarRefeicoes(
    int pagina,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/listar-todas?pagina=$pagina'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaginacaoRefeicoesResponseDTO.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Usuário não autenticado');
    } else {
      throw Exception('Erro ao listar refeições (${response.statusCode})');
    }
  }

  static Future<PaginacaoRefeicoesResponseDTO> listarRefeicoesPorRestaurante(
    int idRestaurante,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }
    const String uriPrimeiraRequisicao = '$baseUrl/listar-todas?pagina=1';
    final responsePrimeira = await http.get(
      Uri.parse(uriPrimeiraRequisicao),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (responsePrimeira.statusCode != 200) {
      throw Exception(
        'Erro ao listar refeições (${responsePrimeira.statusCode})',
      );
    }
    final dataPrimeira = jsonDecode(responsePrimeira.body);
    final paginacaoPrimeira = PaginacaoRefeicoesResponseDTO.fromJson(
      dataPrimeira,
    );
    final totalPaginas = paginacaoPrimeira.totalPaginas;
    final maxPaginas = (totalPaginas > 5) ? 5 : totalPaginas;
    final futures = <Future<http.Response>>[];
    for (int i = 2; i <= maxPaginas; i++) {
      final uri = '$baseUrl/listar-todas?pagina=$i';
      futures.add(
        http.get(Uri.parse(uri), headers: {'Authorization': 'Bearer $token'}),
      );
    }
    final respostasParalelas = await Future.wait(futures);
    final List<MealResponseDTO> todasRefeicoesDoRestaurante = [];
    final refeicoesPage1 = paginacaoPrimeira.refeicoes
        .where((refeicao) => refeicao.idRestaurante == idRestaurante)
        .toList();
    todasRefeicoesDoRestaurante.addAll(refeicoesPage1);
    for (int i = 0; i < respostasParalelas.length; i++) {
      final response = respostasParalelas[i];
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paginacao = PaginacaoRefeicoesResponseDTO.fromJson(data);
        final refeicoesDoRestaurante = paginacao.refeicoes
            .where((refeicao) => refeicao.idRestaurante == idRestaurante)
            .toList();
        todasRefeicoesDoRestaurante.addAll(refeicoesDoRestaurante);
      }
    }
    return PaginacaoRefeicoesResponseDTO(
      refeicoes: todasRefeicoesDoRestaurante,
      totalPaginas: totalPaginas,
      paginaAtual: 1,
    );
  }
}
