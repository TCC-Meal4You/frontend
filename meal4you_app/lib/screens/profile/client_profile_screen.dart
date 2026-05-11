import 'package:flutter/material.dart';
import 'package:meal4you_app/controllers/logout_handlers/client_logout_handler.dart';
import 'package:meal4you_app/services/search_profile/search_client_profile_service.dart';
import 'package:meal4you_app/widgets/navigation/client_bottom_navigation_bar.dart';
import 'package:meal4you_app/widgets/profile/client_profile_banner/client_profile_banner.dart';
import 'package:meal4you_app/widgets/profile/client_profile_config_button/client_profile_config_button.dart';
import 'package:meal4you_app/widgets/profile/client_profile_restrictions_card/client_profile_restrictions_card.dart';
import 'package:meal4you_app/widgets/profile/client_profile_stats_row/client_profile_stats_row.dart';
import 'package:meal4you_app/widgets/profile/client_restrictions_modal/client_restrictions_modal.dart';
import 'package:meal4you_app/services/favorite/restaurant_favorite_service.dart';
import 'package:meal4you_app/services/favorite/meal_favorite_service.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});
  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  String _nome = '';
  bool _isLoading = true;
  List<String> _restricoes = [];
  int _numFavoritos = 0;
  int _numAvaliacoes = 0;
  bool _isCountsLoading = true;
  bool _isRefreshingCounts = false;
  bool _refreshCountsQueued = false;
  @override
  void initState() {
    super.initState();
    RestaurantFavoriteService.changeNotifier.addListener(_onCountsChanged);
    MealFavoriteService.changeNotifier.addListener(_onCountsChanged);
    RatingService.changeNotifier.addListener(_onCountsChanged);
    _loadUserName();
    _loadCounts();
  }

  @override
  void dispose() {
    RestaurantFavoriteService.changeNotifier.removeListener(_onCountsChanged);
    MealFavoriteService.changeNotifier.removeListener(_onCountsChanged);
    RatingService.changeNotifier.removeListener(_onCountsChanged);
    super.dispose();
  }

  void _onCountsChanged() {
    _refreshCounts();
  }

  Future<void> _refreshCounts() async {
    if (!mounted) {
      return;
    }
    if (_isRefreshingCounts) {
      _refreshCountsQueued = true;
      return;
    }
    _isRefreshingCounts = true;
    try {
      do {
        _refreshCountsQueued = false;
        await _loadCounts();
      } while (_refreshCountsQueued && mounted);
    } finally {
      _isRefreshingCounts = false;
    }
  }

  Future<void> _loadUserName() async {
    try {
      final profileData = await SearchClientProfileService.buscarMeuPerfil();
      if (!mounted) return;
      setState(() {
        _nome = (profileData['nome'] ?? '').toString().trim();
        _restricoes = _extractRestrictions(profileData);
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

  Future<void> _loadCounts() async {
    try {
      final results = await Future.wait<int>([
        RestaurantFavoriteService.contarFavoritos(),
        MealFavoriteService.contarFavoritos(),
        RatingService.contarAvaliacoes(),
      ]);
      if (!mounted) return;
      setState(() {
        _numFavoritos = results[0] + results[1];
        _numAvaliacoes = results[2];
        _isCountsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCountsLoading = false;
      });
      return;
    }
  }

  String _getInitial() {
    if (_nome.isEmpty) return '...';
    return _nome[0].toUpperCase();
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
    } catch (_) {
      return [];
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
                      ? 'Carregando...'
                      : (_nome.isNotEmpty ? _nome : 'Nome não encontrado'),
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
                        isLoading: _isCountsLoading,
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
          bottomNavigationBar: const ClientBottomNavigationBar(currentIndex: 3),
        ),
      ),
    );
  }
}
