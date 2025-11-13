import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/services/search_restaurant_data/search_restaurant_data_service.dart';
import 'package:meal4you_app/providers/restaurant_provider.dart';
import 'package:provider/provider.dart';

class GoogleRegisterAndLoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/user.emails.read',
    ],
  );

  final String baseUrl = "https://backend-production-7a83.up.railway.app";

  Future<void> signInWithGoogle({
    required BuildContext context,
    required bool isAdmin,
  }) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      if (accessToken == null) {
        throw Exception("Não foi possível obter o accessToken do Google.");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      final endpoint = isAdmin
          ? "$baseUrl/admins/login/oauth2/google"
          : "$baseUrl/usuarios/login/oauth2/google";

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': accessToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jwt = data['token'];
        await UserTokenSaving.saveToken(jwt);

        final email = googleUser.email;
        await UserTokenSaving.saveUserId(email);
        await UserTokenSaving.saveCurrentUserEmail(email);

        if (isAdmin) {
          final restaurantData =
              await SearchRestaurantDataService.searchMyRestaurant(jwt);

          if (restaurantData != null) {
            final restaurantProvider = Provider.of<RestaurantProvider>(
              context,
              listen: false,
            );

            final id =
                restaurantData['idRestaurante'] ?? restaurantData['id'] ?? 0;

            debugPrint('🧾 [GoogleLogin] ID carregado do backend: $id');

            restaurantProvider.updateRestaurant(
              id: id,
              name: restaurantData['nome'] ?? '',
              description: restaurantData['descricao'] ?? '',
              location: restaurantData['localizacao'] ?? '',
              isActive: restaurantData['ativo'] ?? false,
              foodTypes: (restaurantData['tipoComida'] != null)
                  ? restaurantData['tipoComida']
                        .toString()
                        .split(',')
                        .map((e) => e.trim())
                        .toList()
                  : [],
            );

            await UserTokenSaving.saveRestaurantId(id);
            await UserTokenSaving.saveRestaurantDataForUser(email, {
              ...restaurantData,
              "id": id,
            });

            debugPrint('✅ [GoogleLogin] Restaurante salvo localmente: id=$id');
            await Future.delayed(const Duration(milliseconds: 300));

            Navigator.pushReplacementNamed(context, '/admRestaurantHome');
          } else {
            debugPrint(
              '⚠️ [GoogleLogin] Nenhum restaurante encontrado — indo para criação.',
            );
            Navigator.pushReplacementNamed(context, '/createAdmRestaurant');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/restrictionsChoice');
        }
      } else {
        debugPrint(
          '❌ Falha na autenticação: ${response.statusCode} - ${response.body}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha na autenticação com Google.')),
        );
      }
    } catch (e, stack) {
      debugPrint('Erro ao autenticar com Google: $e');
      debugPrintStack(stackTrace: stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao autenticar com Google: $e')),
      );
    }
  }

  User? get currentUser => _auth.currentUser;
}
