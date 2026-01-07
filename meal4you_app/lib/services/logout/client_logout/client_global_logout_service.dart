import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class ClientGlobalLogoutService {
  static const String _baseUrl =
      "https://backend-production-38906.up.railway.app/usuarios";

  final http.Client client;

  ClientGlobalLogoutService({http.Client? client})
    : client = client ?? http.Client();

  Future<void> logoutGlobal() async {
    final header = await UserTokenSaving.getAuthorizationHeader();

    final response = await client.post(
      Uri.parse('$_baseUrl/logout-global'),
      headers: {
        'Content-Type': 'application/json',
        if (header != null) 'Authorization': header,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await UserTokenSaving.clearAll();
    } else {
      throw HttpException("Erro no logout global: ${response.statusCode}");
    }
  }
}
