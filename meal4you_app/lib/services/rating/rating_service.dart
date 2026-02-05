import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class RatingService {
  static const String baseUrl =
      'https://backend-production-bc8d.up.railway.app/restaurantes/avaliacoes';

  static Future<List<UserRatingResponseDTO>> getMyRestaurantRatings() async {
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
      return data.map((json) => UserRatingResponseDTO.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Administrador não autenticado');
    } else if (response.statusCode == 404) {
      throw Exception('Restaurante não encontrado');
    } else {
      throw Exception('Erro ao listar avaliações: ${response.statusCode}');
    }
  }
}
