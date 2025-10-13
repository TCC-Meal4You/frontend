import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/logout/adm_logout/adm_prefs.dart';

class AdmGlobalLogoutService {
  static const String _baseUrl =
      "https://backend-backendmeal4you.up.railway.app/admins";

  final http.Client adm;

  AdmGlobalLogoutService({http.Client? adm})
    : adm = adm ?? http.Client();

  Future<void> logoutGlobal() async {
    final header = await AdmPrefs.getAuthorizationHeader();
    final uri = Uri.parse('$_baseUrl/logout-global');

    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (header != null) {
        headers['Authorization'] = header;
      }

      final response = await adm.post(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        await AdmPrefs.clearAllUserData();
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
