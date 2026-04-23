import 'package:flutter/material.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/models/restaurante_response_dto.dart';
import 'package:meal4you_app/screens/home/client_home_screen.dart';
import 'package:meal4you_app/screens/profile/client_profile_screen.dart';
import 'package:meal4you_app/screens/search_restaurant_and_dish/search_restaurant_and_dish_screen.dart';
import 'package:meal4you_app/services/favorite/meal_favorite_service.dart';
import 'package:meal4you_app/services/favorite/restaurant_favorite_service.dart';
import 'package:meal4you_app/widgets/search/meal_card.dart';
import 'package:meal4you_app/widgets/search/restaurant_card.dart';

class ClientFavoritesScreen extends StatefulWidget {
  const ClientFavoritesScreen({super.key});

  @override
  State<ClientFavoritesScreen> createState() => _ClientFavoritesScreenState();
}

class _ClientFavoritesScreenState extends State<ClientFavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<RestauranteResponseDTO> _restaurantes = [];
  List<MealResponseDTO> _refeicoes = [];

  bool _isLoadingRestaurants = true;
  bool _isLoadingMeals = true;

  final Set<int> _restaurantFavoriteLoading = {};
  final Set<int> _mealFavoriteLoading = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavoriteRestaurants();
    _loadFavoriteMeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteRestaurants() async {
    if (!mounted) return;
    setState(() => _isLoadingRestaurants = true);

    try {
      final restaurantes = await RestaurantFavoriteService.listarFavoritos();

      if (!mounted) return;
      setState(() {
        _restaurantes = restaurantes;
        _isLoadingRestaurants = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRestaurants = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar restaurantes favoritos: $e')),
      );
    }
  }

  Future<void> _loadFavoriteMeals() async {
    if (!mounted) return;
    setState(() => _isLoadingMeals = true);

    try {
      final refeicoes = await MealFavoriteService.listarFavoritos();

      if (!mounted) return;
      setState(() {
        _refeicoes = refeicoes;
        _isLoadingMeals = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMeals = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pratos favoritos: $e')),
      );
    }
  }

  Future<void> _toggleRestaurantFavorite(int index) async {
    final restaurante = _restaurantes[index];
    final restauranteId = restaurante.idRestaurante;

    if (_restaurantFavoriteLoading.contains(restauranteId)) {
      return;
    }

    setState(() {
      _restaurantFavoriteLoading.add(restauranteId);
      _restaurantes.removeAt(index);
    });

    try {
      await RestaurantFavoriteService.alternarFavorito(restauranteId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _restaurantes.insert(index, restaurante);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao desfavoritar restaurante: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _restaurantFavoriteLoading.remove(restauranteId);
      });
    }
  }

  Future<void> _toggleMealFavorite(int index) async {
    final refeicao = _refeicoes[index];
    final refeicaoId = refeicao.idRefeicao;

    if (_mealFavoriteLoading.contains(refeicaoId)) {
      return;
    }

    setState(() {
      _mealFavoriteLoading.add(refeicaoId);
      _refeicoes.removeAt(index);
    });

    try {
      await MealFavoriteService.alternarFavorito(refeicaoId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _refeicoes.insert(index, refeicao);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao desfavoritar prato: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _mealFavoriteLoading.remove(refeicaoId);
      });
    }
  }

  Widget _buildRestaurantsTab() {
    if (_isLoadingRestaurants) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_restaurantes.isEmpty) {
      return const Center(child: Text('Nenhum restaurante favorito ainda'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: _restaurantes.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurantes[index];
        return RestaurantCard(
          restaurant: restaurant,
          onFavorite: () => _toggleRestaurantFavorite(index),
        );
      },
    );
  }

  Widget _buildMealsTab() {
    if (_isLoadingMeals) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_refeicoes.isEmpty) {
      return const Center(child: Text('Nenhum prato favorito ainda'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: _refeicoes.length,
      itemBuilder: (context, index) {
        final meal = _refeicoes[index];
        return MealCard(
          meal: meal,
          onFavorite: () => _toggleMealFavorite(index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFFFE9EC),
                    child: Icon(Icons.favorite, color: Colors.red, size: 18),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Seus Favoritos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_restaurantes.length + _refeicoes.length} favorito(s)',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475467),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E9EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF101828),
                  unselectedLabelColor: const Color(0xFF667085),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'Restaurantes (${_restaurantes.length})'),
                    Tab(text: 'Pratos (${_refeicoes.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildRestaurantsTab(), _buildMealsTab()],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 157, 0, 255),
          unselectedItemColor: const Color(0xFF475467),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
              );
            } else if (index == 1) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const SearchRestaurantAndDishScreen(),
                ),
              );
            } else if (index == 2) {
              return;
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ClientProfileScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
