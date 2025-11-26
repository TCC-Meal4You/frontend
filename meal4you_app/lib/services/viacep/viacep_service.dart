import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class ViaCepService {
  static const String baseUrl =
      "https://backend-production-9aaf.up.railway.app/restaurantes";

  static Future<Map<String, dynamic>?> consultarCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cepLimpo.length != 8) {
      throw Exception("CEP deve conter exatamente 8 dígitos");
    }

    final token = await UserTokenSaving.getToken();
    if (token == null) {
      throw Exception("Token não encontrado. Faça login novamente.");
    }

    final url = Uri.parse("$baseUrl/$cep");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'cep': data['cep'] ?? '',
          'logradouro': data['logradouro'] ?? '',
          'complemento': data['complemento'] ?? '',
          'bairro': data['bairro'] ?? '',
          'cidade': data['localidade'] ?? '',
          'uf': data['uf'] ?? '',
        };
      } else if (response.statusCode == 400) {
        throw Exception("CEP inválido ou não encontrado");
      } else if (response.statusCode == 401) {
        throw Exception("Sessão expirada. Faça login novamente.");
      } else {
        throw Exception("Erro ao consultar CEP: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("CEP inválido") ||
          e.toString().contains("Sessão expirada")) {
        rethrow;
      }
      throw Exception("Erro na consulta do CEP: $e");
    }
  }

  static String formatarCep(String cep) {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cepLimpo.length == 8) {
      return "${cep.substring(0, 5)}-${cep.substring(5)}";
    }

    return cep;
  }

  static bool validarCep(String cep) {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cepLimpo.length == 8;
  }
}
