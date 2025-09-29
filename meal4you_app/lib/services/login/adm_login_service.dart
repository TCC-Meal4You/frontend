import 'dart:convert';
import 'package:http/http.dart' as http;

class AdmLoginService {
  static const String baseUrl = "https://backend-production-6abd.up.railway.app/admin/login";

  static Future<Map<String, dynamic>> loginAdm({
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "senha": senha,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Erro ao fazer login: ${response.body}");
    }
  }
}
