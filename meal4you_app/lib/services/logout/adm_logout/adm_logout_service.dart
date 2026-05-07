import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class AdmLogoutService {
  static const String _baseUrl =
      "https://backend-production-b24f.up.railway.app/admins";

  final http.Client adm;

  AdmLogoutService({http.Client? adm}) : adm = adm ?? http.Client();

  Future<void> logout() async {
    final header = await UserTokenSaving.getAuthorizationHeader();

    final candidates = [
      Uri.parse('$_baseUrl/logout'),
      Uri.parse('https://backend-production-b24f.up.railway.app/logout'),
    ];
    List<String> errors = [];

    for (final uri in candidates) {
      try {
        final request = http.Request('POST', uri);
        request.headers['Content-Type'] = 'application/json';
        if (header != null) request.headers['Authorization'] = header;
        final streamedResponse = await adm.send(request);
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200 || response.statusCode == 204) {
          await UserTokenSaving.clearAll();
          return;
        }
        
        errors.add('${uri.toString()} => ${response.statusCode}');
        
        if (response.statusCode == 301 || response.statusCode == 302 || 
            response.statusCode == 307 || response.statusCode == 308) {
          continue;
        }
      } catch (e) {
        errors.add('${uri.toString()} => Exception: $e');
        continue;
      }
    }
    
    await UserTokenSaving.clearAll();
    throw HttpException("Erro logout ADM (todos os candidates falharam): ${errors.join(' | ')}");
  }
}
