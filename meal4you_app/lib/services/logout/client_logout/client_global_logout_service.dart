import 'dart:io';
import 'package:http/http.dart' as http;
import 'client_prefs.dart';

class ClientGlobalLogoutService {
  static const String _baseUrl =
      "https://backend-production-7a83.up.railway.app/usuarios";

  final http.Client client;

  ClientGlobalLogoutService({http.Client? client})
    : client = client ?? http.Client();

  Future<void> logoutGlobal() async {
    final header = await ClientPrefs.getAuthorizationHeader();
    final uri = Uri.parse('$_baseUrl/logout-global');

    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (header != null) {
        headers['Authorization'] = header;
      }

      final response = await client.post(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        await ClientPrefs.clearAllUserData();
        return;
      } else {
        throw HttpException(
          'Falha ao tentar sair de todas as contas: '
          '${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw const SocketException('Sem conexão com a internet');
    } catch (e) {
      rethrow;
    }
  }
}
