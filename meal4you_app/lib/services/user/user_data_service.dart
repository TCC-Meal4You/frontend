import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class UserDataService {
  static const String _baseUrl =
      'https://backend-production-1e17.up.railway.app';
  static const Duration _requestTimeout = Duration(seconds: 20);

  static final Map<int, String> _userNameCache = {};

  static Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{'Accept': 'application/json'};
    try {
      final authHeader = await UserTokenSaving.getAuthorizationHeader();
      if (authHeader != null) {
        headers['Authorization'] = authHeader;
      }
    } catch (e) {}
    return headers;
  }

  static Future<String?> getUserNameById(int userId) async {
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId];
    }

    try {
      final headers = await _buildHeaders();
      final candidates = [
        Uri.parse('$_baseUrl/usuarios/$userId'),
        Uri.parse('$_baseUrl/usuarios?id=$userId'),
        Uri.parse('$_baseUrl/users/$userId'),
      ];

      for (final uri in candidates) {
        try {
          final response = await http
              .get(uri, headers: headers)
              .timeout(_requestTimeout);

          if (response.statusCode == 401 || response.statusCode == 403) {
            continue;
          }

          if (response.statusCode == 200) {
            final contentType = response.headers['content-type'] ?? '';
            if (!contentType.toLowerCase().contains('application/json')) {
              continue;
            }
            final data = jsonDecode(response.body);

            String? name =
                data['nome'] ??
                data['name'] ??
                data['nomeUsuario'] ??
                data['userName'] ??
                data['fullName'] ??
                data['full_name'] ??
                data['nomeCompleto'] ??
                data['nome_completo'] ??
                data['primeiroNome'] ??
                data['firstName'];

            if (name != null) {
              name = name.trim();
              if (name.isNotEmpty) {
                _userNameCache[userId] = name;
                return name;
              }
            }
          }
        } catch (e) {
          continue;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static void clearCache() {
    _userNameCache.clear();
  }
}
