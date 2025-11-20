import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class AdmGlobalLogoutService {
  static const String _baseUrl =
      "https://backend-production-9aaf.up.railway.app/admins";

  final http.Client adm;

  AdmGlobalLogoutService({http.Client? adm}) : adm = adm ?? http.Client();

  Future<void> logoutGlobal() async {
    final header = await UserTokenSaving.getAuthorizationHeader();
    final uri = Uri.parse('$_baseUrl/logout-global');

    try {
      final response = await adm.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (header != null) 'Authorization': header,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await UserTokenSaving.clearAll();
      } else {
        throw HttpException(
          'Falha ao tentar sair de todas as contas: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw const SocketException('Sem conexão com a internet');
    } catch (e) {
      rethrow;
    }
  }
}
