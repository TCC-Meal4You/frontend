import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/providers/restaurant/restaurant_provider.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class UpdateRestaurantService {
  static const String baseUrl =
      'https://backend-production-9aaf.up.railway.app/restaurantes';

  static Future<Map<String, dynamic>?> updateRestaurant({
    required RestaurantProvider provider,
  }) async {
    try {
     int? id = provider.id ?? await UserTokenSaving.getRestaurantId();
if (id == null || id == 0) {
  throw Exception("ID do restaurante não encontrado. Faça login novamente.");
}


      final token = await UserTokenSaving.getToken();
      if (token == null) {
        throw Exception("Token não encontrado.");
      }

      final url = Uri.parse('$baseUrl/$id');
      print("🔸 Atualizando restaurante ID: $id");

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nome': provider.name,
          'descricao': provider.description,
          'ativo': provider.isActive,
          'tipoComida': provider.foodTypes.join(', '),
          'cep': provider.cep,
          'logradouro': provider.logradouro,
          'numero': provider.numero,
          'complemento': provider.complemento.isNotEmpty ? provider.complemento : null,
          'bairro': provider.bairro,
          'cidade': provider.cidade,
          'uf': provider.uf,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['id'] != null) {
          await UserTokenSaving.saveRestaurantId(data['id']);
        }

        await UserTokenSaving.saveRestaurantDataForCurrentUser(data);
        return data;
      } else {
        throw Exception(
            'Erro ao atualizar restaurante: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao atualizar restaurante: $e');
      rethrow;
    }
  }
}
