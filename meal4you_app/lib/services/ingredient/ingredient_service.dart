import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/ingredient_request_dto.dart';
import 'package:meal4you_app/models/ingredient_response_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class IngredientService {
  static const String baseUrl =
      'https://backend-production-bc8d.up.railway.app/ingredientes';

  static Future<IngredientResponseDTO> cadastrarIngrediente(
    IngredientRequestDTO dto,
  ) async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
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
      return IngredientResponseDTO.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Um ou mais IDs de restrição são inválidos');
    } else if (response.statusCode == 401) {
      throw Exception('Administrador não autenticado');
    } else if (response.statusCode == 404) {
      throw Exception(
        'Você precisa cadastrar um restaurante para ter ingredientes',
      );
    } else if (response.statusCode == 409) {
      throw Exception('Você já cadastrou um ingrediente com este nome');
    } else {
      throw Exception('Erro ao cadastrar ingrediente');
    }
  }

  static Future<List<IngredientResponseDTO>> listarMeusIngredientes() async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => IngredientResponseDTO.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Administrador não autenticado');
    } else if (response.statusCode == 404) {
      throw Exception(
        'Você precisa cadastrar um restaurante para ter ingredientes',
      );
    } else {
      throw Exception('Erro ao listar ingredientes');
    }
  }

  static Future<void> deletarIngrediente(int id) async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Administrador não autenticado');
    } else if (response.statusCode == 404) {
      throw Exception('Ingrediente não encontrado ou não pertence a você');
    } else if (response.statusCode == 409) {
      throw Exception(
        'Ingrediente não pode ser deletado pois está em uso em uma ou mais refeições',
      );
    } else {
      throw Exception('Erro ao deletar ingrediente');
    }
  }
}
