import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/logout/adm_logout/adm_prefs.dart';

class AdmLogoutService {
  static const String _baseUrl =
      "https://backend-backendmeal4you.up.railway.app/admin";

  final http.Client adm;

  AdmLogoutService({http.Client? adm}) : adm = adm ?? http.Client();

  Future<void> logout() async {
    final header = await AdmPrefs.getAuthorizationHeader();
    if (header == null) {
      return;
    }

    final uri = Uri.parse('$_baseUrl/logout');

    try {
      final response = await adm.post(
        uri,
        headers: {'Authorization': header, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await AdmPrefs.clearToken();
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
