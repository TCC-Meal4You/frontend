import 'package:flutter/material.dart';
import 'package:meal4you_app/controllers/logout_handlers/client_logout_handler.dart';
import 'package:meal4you_app/services/search_profile/search_client_profile_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/widgets/profile/client_profile_banner/client_profile_banner.dart';
import 'package:meal4you_app/widgets/profile/client_profile_config_button/client_profile_config_button.dart';
import 'package:meal4you_app/widgets/profile/client_profile_restrictions_card/client_profile_restrictions_card.dart';
import 'package:meal4you_app/widgets/profile/client_profile_stats_row/client_profile_stats_row.dart';
import 'package:meal4you_app/widgets/profile/client_restrictions_modal/client_restrictions_modal.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  String _nome = '';
  String _email = '';
  bool _isLoading = true;
  List<String> _restricoes = [];
  int _numFavoritos = 0;
  int _numAvaliacoes = 0;

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
        _restricoes = _extractRestrictions(profileData);
        _numFavoritos = 0;
        _numAvaliacoes = 0;
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

  List<String> _extractRestrictions(Map<String, dynamic> profileData) {
    try {
      final restricoes = profileData['restricoes'];
      if (restricoes is List) {
        return restricoes
            .map((r) => r.toString().trim())
            .where((r) => r.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao extrair restrições: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final clientLogoutHandler = ClientLogoutHandler();

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClientProfileBanner(
                  isLoading: _isLoading,
                  initial: _getInitial(),
                  emailText: _isLoading
                      ? 'Carregando e-mail...'
                      : (_email.isNotEmpty ? _email : 'E-mail não encontrado'),
                  onLogout: () => clientLogoutHandler.showLogoutDialog(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClientProfileStatsRow(
                        numRestricoes: _restricoes.length,
                        numFavoritos: _numFavoritos,
                        numAvaliacoes: _numAvaliacoes,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Minhas Restrições',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClientProfileRestrictionsCard(
                        restricoes: _restricoes,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ClientRestrictionsModal(
                              restricoesAtuais: _restricoes,
                              onRestrictionsSaved: _loadUserName,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Configurações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClientProfileConfigButton(
                        icon: Icons.rate_review_outlined,
                        color: const Color.fromARGB(255, 100, 150, 255),
                        label: 'Minhas Avaliações',
                        onTap: () {
                          Navigator.pushNamed(context, '/clientRatings');
                        },
                      ),
                      const SizedBox(height: 12),
                      ClientProfileConfigButton(
                        icon: Icons.favorite_outline,
                        color: Colors.red.shade400,
                        label: 'Meus Favoritos',
                        onTap: () {
                          Navigator.pushNamed(context, '/clientFavorites');
                        },
                      ),
                      const SizedBox(height: 12),
                      ClientProfileConfigButton(
                        icon: Icons.settings_outlined,
                        color: const Color.fromARGB(255, 157, 0, 255),
                        label: 'Configurações Gerais',
                        onTap: () {
                          Navigator.pushNamed(context, '/clientSettings');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
