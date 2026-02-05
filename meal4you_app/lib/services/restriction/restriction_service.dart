import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/restriction_response_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class RestrictionService {
  static const String baseUrl =
      'https://backend-production-bc8d.up.railway.app/restricoes';

  static Future<List<RestrictionResponseDTO>> listarRestricoes() async {
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
      return data.map((json) => RestrictionResponseDTO.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Usuário não autenticado');
    } else {
      throw Exception('Erro ao listar restrições (${response.statusCode})');
    }
  }
}
