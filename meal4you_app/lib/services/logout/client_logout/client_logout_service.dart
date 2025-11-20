import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class ClientLogoutService {
  static const String _baseUrl =
      "https://backend-production-9aaf.up.railway.app/usuarios";

  final http.Client client;

  ClientLogoutService({http.Client? client}) : client = client ?? http.Client();

  Future<void> logout() async {
    final header = await UserTokenSaving.getAuthorizationHeader();
    if (header == null) {
      return;
    }

    final uri = Uri.parse('$_baseUrl/logout');

    try {
      final response = await client.post(
        uri,
        headers: {'Authorization': header, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await UserTokenSaving.clearToken();
        return;
      } else {
        throw HttpException(
          'Falha ao tentar sair: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw const SocketException('Sem conexão com a internet');
    } catch (e) {
      rethrow;
    }
  }
}
