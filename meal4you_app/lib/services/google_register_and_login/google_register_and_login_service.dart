import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/services/search_restaurant_data/search_restaurant_data_service.dart';
import 'package:meal4you_app/providers/restaurant/restaurant_provider.dart';
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

  final String baseUrl = "https://backend-production-38906.up.railway.app";

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

        final email = googleUser.email;

        await UserTokenSaving.saveCurrentUserEmail(email);
        await UserTokenSaving.saveToken(jwt);

        final userData = <String, dynamic>{
          ...Map<String, dynamic>.from(data),
          'email': email,
          'userType': isAdmin ? 'adm' : 'client',
          'isAdm': isAdmin,
        };
        await UserTokenSaving.saveUserData(userData);

        debugPrint('✅ GOOGLE LOGIN - Email salvo: $email');
        debugPrint('✅ GOOGLE LOGIN - Token salvo');
        debugPrint(
          '✅ GOOGLE LOGIN - UserData salvo com userType: ${isAdmin ? "adm" : "client"}',
        );

        if (isAdmin) {
          debugPrint('🔍 GOOGLE LOGIN - Buscando dados do restaurante...');

          final restaurantData =
              await SearchRestaurantDataService.searchMyRestaurant(jwt);

          if (restaurantData != null && restaurantData.isNotEmpty) {
            debugPrint('✅ GOOGLE LOGIN - Restaurante encontrado no backend');

            final restaurantProvider = Provider.of<RestaurantProvider>(
              context,
              listen: false,
            );

            final rawId =
                restaurantData['idRestaurante'] ??
                restaurantData['id'] ??
                restaurantData['id_restaurante'];
            final id = rawId is int
                ? rawId
                : int.tryParse(rawId.toString()) ?? 0;

            debugPrint('🆔 GOOGLE LOGIN - ID do restaurante: $id');

            if (id > 0) {
              restaurantProvider.updateRestaurant(
                id: id,
                name: restaurantData['nome'] ?? '',
                description: restaurantData['descricao'] ?? '',
                isActive: restaurantData['ativo'] ?? false,
                foodTypes: (restaurantData['tipoComida'] is String)
                    ? restaurantData['tipoComida']
                          .split(',')
                          .map((e) => e.trim())
                          .toList()
                    : (restaurantData['tipoComida'] as List? ?? [])
                          .map((e) => e.toString())
                          .toList(),
              );

              await UserTokenSaving.saveRestaurantId(id);

              final restaurantDataToSave = <String, dynamic>{
                ...Map<String, dynamic>.from(restaurantData),
                'id': id,
                'idRestaurante': id,
              };

              await UserTokenSaving.saveRestaurantDataForCurrentUser(
                restaurantDataToSave,
              );

              debugPrint('✅ GOOGLE LOGIN - Restaurante salvo localmente');

              final savedData =
                  await UserTokenSaving.getRestaurantDataForCurrentUser();
              debugPrint(
                '🔍 GOOGLE LOGIN - Verificação: ${savedData != null ? "OK" : "FALHOU"}',
              );

              await Future.delayed(const Duration(milliseconds: 300));

              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/admRestaurantHome');
            } else {
              debugPrint('⚠️ GOOGLE LOGIN - ID inválido, indo para criação');
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/createAdmRestaurant');
            }
          } else {
            debugPrint(
              '⚠️ GOOGLE LOGIN - Nenhum restaurante encontrado, indo para criação',
            );
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, '/createAdmRestaurant');
          }
        } else {
          debugPrint('👤 GOOGLE LOGIN - Cliente, indo para restrictionsChoice');
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/restrictionsChoice');
        }
      } else {
        debugPrint(
          '❌ Falha na autenticação: ${response.statusCode} - ${response.body}',
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha na autenticação com Google.')),
        );
      }
    } catch (e, stack) {
      debugPrint('Erro ao autenticar com Google: $e');
      debugPrintStack(stackTrace: stack);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao autenticar com Google: $e')),
      );
    }
  }

  User? get currentUser => _auth.currentUser;
}
