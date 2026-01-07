import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/meal_request_dto.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class MealService {
  static const String baseUrl =
      'https://backend-production-38906.up.railway.app/refeicoes';

  static Future<MealResponseDTO> cadastrarRefeicao(MealRequestDTO dto) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return MealResponseDTO.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Refeição deve ter pelo menos 1 ingrediente');
    } else if (response.statusCode == 404) {
      throw Exception(
        'Restaurante não encontrado. Cadastre um restaurante primeiro',
      );
    } else if (response.statusCode == 409) {
      throw Exception('Já existe uma refeição com este nome no seu cardápio');
    } else {
      throw Exception('Erro ao cadastrar refeição: ${response.statusCode}');
    }
  }

  static Future<List<MealResponseDTO>> listarMinhasRefeicoes() async {
    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MealResponseDTO.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('Restaurante não encontrado para este administrador');
    } else {
      throw Exception('Erro ao listar refeições: ${response.statusCode}');
    }
  }

  static Future<MealResponseDTO> atualizarRefeicao(
    int id,
    MealRequestDTO dto,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return MealResponseDTO.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Nenhuma alteração detectada ou dados inválidos');
    } else if (response.statusCode == 403) {
      throw Exception('Sem permissão para alterar esta refeição');
    } else if (response.statusCode == 404) {
      throw Exception('Refeição não encontrada');
    } else if (response.statusCode == 409) {
      throw Exception('Já existe outra refeição com este nome no seu cardápio');
    } else {
      throw Exception('Erro ao atualizar refeição: ${response.statusCode}');
    }
  }

  static Future<void> deletarRefeicao(int id) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 403) {
      throw Exception('Sem permissão para deletar esta refeição');
    } else if (response.statusCode == 404) {
      throw Exception('Refeição não encontrada');
    } else {
      throw Exception('Erro ao deletar refeição: ${response.statusCode}');
    }
  }

  static Future<MealResponseDTO> atualizarDisponibilidade(
    int id,
    bool disponivel,
  ) async {
    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/$id/disponibilidade'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'disponivel': disponivel}),
    );

    if (response.statusCode == 200) {
      return MealResponseDTO.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Refeição já está neste estado');
    } else if (response.statusCode == 403) {
      throw Exception('Sem permissão para alterar esta refeição');
    } else if (response.statusCode == 404) {
      throw Exception('Refeição não encontrada');
    } else {
      throw Exception(
        'Erro ao atualizar disponibilidade: ${response.statusCode}',
      );
    }
  }
}
