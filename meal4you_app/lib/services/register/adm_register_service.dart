import 'dart:convert';
import 'package:http/http.dart' as http;

class AdmRegisterService {
  static const String baseUrl =
      "https://backend-backendmeal4you.up.railway.app/admin";

  static Future<Map<String, dynamic>> registerAdm({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nome": nome, "email": email, "senha": senha}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao cadastrar: ${response.body}");
    }
  }
}
