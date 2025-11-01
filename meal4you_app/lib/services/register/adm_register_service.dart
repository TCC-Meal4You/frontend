import 'dart:convert';
import 'package:http/http.dart' as http;

class AdmRegisterService {
  static const String baseUrl =
      "https://backend-production-7a83.up.railway.app/admins";

  static Future<Map<String, dynamic>> registerAdm({
    required String nome,
    required String email,
    required String senha,
    required String codigo,
  }) async {
    final url = Uri.parse(baseUrl);

    final body = jsonEncode({
      "nome": nome,
      "email": email,
      "senha": senha,
      "codigoVerificacao": codigo,
    });


    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );


    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erro ao cadastrar ADM: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
