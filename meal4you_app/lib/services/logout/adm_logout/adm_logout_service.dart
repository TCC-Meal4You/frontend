import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class AdmLogoutService {
  static const String _baseUrl =
      "https://backend-production-7a83.up.railway.app/admins";

  final http.Client adm;

  AdmLogoutService({http.Client? adm}) : adm = adm ?? http.Client();

  Future<void> logout() async {
    final header = await UserTokenSaving.getAuthorizationHeader();
    if (header == null) return;

    final uri = Uri.parse('$_baseUrl/logout');

    try {
      final response = await adm.post(
        uri,
        headers: {'Authorization': header, 'Content-Type': 'application/json'},
      );

      await UserTokenSaving.clearAll();

      if (response.statusCode != 200 && response.statusCode != 204) {
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
