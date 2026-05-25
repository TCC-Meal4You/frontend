import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/services/search_restaurant_data/search_restaurant_data_service.dart';
import 'package:meal4you_app/providers/restaurant/restaurant_provider.dart';
import 'package:meal4you_app/services/user_restriction/user_restriction_service.dart';
import 'package:provider/provider.dart';

class GoogleRegisterAndLoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final String baseUrl = "https://backend-production-1e17.up.railway.app";
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
        if (isAdmin) {
          final restaurantData =
              await SearchRestaurantDataService.searchMyRestaurant(jwt);
          if (restaurantData != null && restaurantData.isNotEmpty) {
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
              await Future.delayed(const Duration(milliseconds: 300));
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/admRestaurantHome');
            } else {
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/createAdmRestaurant');
            }
          } else {
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, '/createAdmRestaurant');
          }
        } else {
          bool hasCompletedRestrictions = false;
          try {
            final restricoes = await UserRestrictionService.buscarRestricoes();
            hasCompletedRestrictions = restricoes.isNotEmpty;
            if (hasCompletedRestrictions) {
              await UserTokenSaving.setRestrictionsCompleted(true);
            } else {}
          } catch (e) {
            if (e.toString().contains('ACCOUNT_NOT_FOUND')) {
              await UserTokenSaving.clearAll();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/profileChoice');
              }
              return;
            }
          }
          final destino = hasCompletedRestrictions
              ? '/clientHome'
              : '/restrictionsChoice';
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, destino);
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha na autenticação com Google.')),
        );
      }
    } catch (e) {
      String errorMessage = 'Erro ao autenticar com Google';
      if (e.toString().contains('network_error')) {
        errorMessage =
            'Erro de configuração do Google Sign In.\n'
            'Verifique:\n'
            '1. Conexão com internet\n'
            '2. SHA-1 configurado no Firebase Console\n'
            '3. google-services.json atualizado';
      } else if (e.toString().contains('sign_in_canceled')) {
        errorMessage = 'Login cancelado pelo usuário';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = 'Falha no login. Tente novamente.';
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  User? get currentUser => _auth.currentUser;
}
