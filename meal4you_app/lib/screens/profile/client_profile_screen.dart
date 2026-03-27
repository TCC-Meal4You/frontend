import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/controllers/logout_handlers/client_logout_handler.dart';
import 'package:meal4you_app/services/search_profile/search_client_profile_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  String _nome = '';
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final profileData = await SearchClientProfileService.buscarMeuPerfil();
      final savedEmail = await UserTokenSaving.getUserEmail();
      final extractedEmail = _extractEmail(profileData, savedEmail);

      if (!mounted) return;
      setState(() {
        _nome = (profileData['nome'] ?? '').toString().trim();
        _email = extractedEmail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getInitial() {
    if (_nome.isEmpty) return '...';
    return _nome[0].toUpperCase();
  }

  String _extractEmail(Map<String, dynamic> profileData, String? savedEmail) {
    final topLevelEmail = (profileData['email'] ?? '').toString().trim();
    if (topLevelEmail.isNotEmpty) return topLevelEmail;

    final usuario = profileData['usuario'];
    if (usuario is Map<String, dynamic>) {
      final usuarioEmail = (usuario['email'] ?? '').toString().trim();
      if (usuarioEmail.isNotEmpty) return usuarioEmail;
    }

    final user = profileData['user'];
    if (user is Map<String, dynamic>) {
      final userEmail = (user['email'] ?? '').toString().trim();
      if (userEmail.isNotEmpty) return userEmail;
    }

    final login = (profileData['login'] ?? '').toString().trim();
    if (login.contains('@')) return login;

    return (savedEmail ?? '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final clientLogoutHandler = ClientLogoutHandler();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 157, 0, 255),
                      Color.fromARGB(255, 15, 230, 135),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'MEAL4YOU',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 27,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'c  o  m  i  d  a    c  o  n  s  c  i  e  n  t  e',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () =>
                                clientLogoutHandler.showLogoutDialog(context),
                            icon: const FaIcon(
                              FontAwesomeIcons.rightFromBracket,
                              color: Colors.white,
                            ),
                            tooltip: 'Sair',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.3),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.3,
                                ),
                              )
                            : Text(
                                _getInitial(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Ubuntu',
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Meu Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
                    Text(
                      _isLoading
                          ? 'Carregando e-mail...'
                          : (_email.isNotEmpty
                                ? _email
                                : 'E-mail não encontrado'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
