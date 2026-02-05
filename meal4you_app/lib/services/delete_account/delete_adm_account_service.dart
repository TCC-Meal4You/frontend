import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class DeleteAdmAccountService {
  static const String baseUrl =
      'https://backend-production-bc8d.up.railway.app';

  static Future<void> deletarMinhaConta(String email) async {
    final token = await UserTokenSaving.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token de autenticação não encontrado');
    }

    final url = Uri.parse(
      '$baseUrl/admins?email=${Uri.encodeComponent(email)}',
    );

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 400) {
      throw Exception('E-mail de confirmação incorreto');
    } else if (response.statusCode == 401) {
      throw Exception('Não autorizado');
    } else {
      throw Exception('Erro ao deletar conta: ${response.body}');
    }
  }
}
