import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class AdmLogoutService {
  static const String _baseUrl =
      "https://backend-production-38906.up.railway.app/admins";

  final http.Client adm;

  AdmLogoutService({http.Client? adm}) : adm = adm ?? http.Client();

  Future<void> logout() async {
    final header = await UserTokenSaving.getAuthorizationHeader();

    final response = await adm.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        if (header != null) 'Authorization': header,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await UserTokenSaving.clearAll();
    } else {
      throw HttpException("Erro logout ADM: ${response.statusCode}");
    }
  }
}
