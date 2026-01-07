import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class ClientLogoutService {
  static const String _baseUrl =
      "https://backend-production-38906.up.railway.app/usuarios";

  final http.Client client;

  ClientLogoutService({http.Client? client}) : client = client ?? http.Client();

  Future<void> logout() async {
    final header = await UserTokenSaving.getAuthorizationHeader();
    if (header == null) return;

    final uri = Uri.parse('$_baseUrl/logout');

    final response = await client.post(uri, headers: {'Authorization': header});

    if (response.statusCode == 200 || response.statusCode == 204) {
      await UserTokenSaving.clearAll();
    } else {
      throw HttpException("Erro ao deslogar: ${response.statusCode}");
    }
  }
}
