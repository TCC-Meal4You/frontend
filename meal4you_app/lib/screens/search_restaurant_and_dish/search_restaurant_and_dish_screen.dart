import 'package:flutter/material.dart';
import 'package:meal4you_app/models/restaurante_response_dto.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/services/favorite/meal_favorite_service.dart';
import 'package:meal4you_app/services/favorite/restaurant_favorite_service.dart';
import 'package:meal4you_app/services/search_restaurant/search_restaurant_service.dart';
import 'package:meal4you_app/services/search_meal/search_meal_service.dart';
import 'package:meal4you_app/widgets/navigation/client_bottom_navigation_bar.dart';
import 'package:meal4you_app/widgets/search/restaurant_card.dart';
import 'package:meal4you_app/widgets/search/meal_card.dart';

class SearchRestaurantAndDishScreen extends StatefulWidget {
  const SearchRestaurantAndDishScreen({super.key});

  @override
  State<SearchRestaurantAndDishScreen> createState() =>
      _SearchRestaurantAndDishScreenState();
}

class _SearchRestaurantAndDishScreenState
    extends State<SearchRestaurantAndDishScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<RestauranteResponseDTO> _restaurantes = [];
  List<MealResponseDTO> _refeicoes = [];

  int _restaurantPage = 0;
  int _mealPage = 0;
  int _restaurantTotalPages = 1;
  int _mealTotalPages = 1;

  bool _loadingRestaurants = false;
  bool _loadingMeals = false;
  final Set<int> _restaurantFavoriteLoading = {};
  final Set<int> _mealFavoriteLoading = {};

  String get _query => _searchController.text.trim().toLowerCase();
  bool get _isSearching => _query.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadRestaurants(0);
    });
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {});

    if (_query.isNotEmpty && _refeicoes.isEmpty && !_loadingMeals) {
      _loadMeals(0);
    }
  }

  List<RestauranteResponseDTO> _filteredRestaurants() {
    if (!_isSearching) return _restaurantes;

    return _restaurantes.where((restaurant) {
      final nome = restaurant.nome.toLowerCase();
      final tipo = restaurant.tipoComida.toLowerCase();
      final descricao = (restaurant.descricao ?? '').toLowerCase();
      return nome.contains(_query) ||
          tipo.contains(_query) ||
          descricao.contains(_query);
    }).toList();
  }

  List<MealResponseDTO> _filteredMeals() {
    if (!_isSearching) return _refeicoes;

    return _refeicoes.where((meal) {
      final nome = meal.nome.toLowerCase();
      final tipo = meal.tipo.toLowerCase();
      final descricao = (meal.descricao ?? '').toLowerCase();
      final restricoes = meal.restricoes.join(' ').toLowerCase();
      return nome.contains(_query) ||
          tipo.contains(_query) ||
          descricao.contains(_query) ||
          restricoes.contains(_query);
    }).toList();
  }

  Future<void> _loadRestaurants(int pageNumber) async {
    if (!mounted) return;
    if (_loadingRestaurants) {
      return;
    }

    setState(() => _loadingRestaurants = true);

    try {
      final response = await SearchRestaurantService.listarRestaurantes(
        pageNumber + 1,
      );

      if (!mounted) return;
      setState(() {
        _restaurantes = response.restaurantes;
        _restaurantTotalPages = response.totalPaginas;
        _restaurantPage = pageNumber;
        _loadingRestaurants = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingRestaurants = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar restaurantes: $e')),
      );
    }
  }

  Future<void> _loadMeals(int pageNumber) async {
    if (!mounted) return;
    if (_loadingMeals) {
      return;
    }

    setState(() => _loadingMeals = true);

    try {
      final response = await SearchMealService.listarRefeicoes(pageNumber + 1);

      if (!mounted) return;
      setState(() {
        _refeicoes = response.refeicoes;
        _mealTotalPages = response.totalPaginas;
        _mealPage = pageNumber;
        _loadingMeals = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMeals = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar refeições: $e')));
    }
  }

  Future<void> _toggleRestaurantFavoriteById(int restaurantId) async {
    final index = _restaurantes.indexWhere(
      (restaurant) => restaurant.idRestaurante == restaurantId,
    );
    if (index == -1) return;

    final restaurante = _restaurantes[index];
    final restauranteId = restaurante.idRestaurante;

    if (_restaurantFavoriteLoading.contains(restauranteId)) {
      return;
    }

    setState(() {
      _restaurantFavoriteLoading.add(restauranteId);
      _restaurantes[index] = restaurante.copyWith(
        favorito: !restaurante.favorito,
      );
    });

    try {
      await RestaurantFavoriteService.alternarFavorito(restauranteId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _restaurantes[index] = restaurante;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao favoritar restaurante: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _restaurantFavoriteLoading.remove(restauranteId);
      });
    }
  }

  Future<void> _toggleMealFavoriteById(int mealId) async {
    final index = _refeicoes.indexWhere((meal) => meal.idRefeicao == mealId);
    if (index == -1) return;

    final refeicao = _refeicoes[index];
    final refeicaoId = refeicao.idRefeicao;

    if (_mealFavoriteLoading.contains(refeicaoId)) {
      return;
    }

    setState(() {
      _mealFavoriteLoading.add(refeicaoId);
      _refeicoes[index] = refeicao.copyWith(favorito: !refeicao.favorito);
    });

    try {
      await MealFavoriteService.alternarFavorito(refeicaoId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _refeicoes[index] = refeicao;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao favoritar prato: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _mealFavoriteLoading.remove(refeicaoId);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar restaurantes, culinária...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[400],
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.tune),
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              onTap: (index) {
                if (index == 1 && _refeicoes.isEmpty && !_loadingMeals) {
                  _loadMeals(0);
                }
              },
              labelColor: const Color(0xFF9D00FF),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF9D00FF),
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.store_mall_directory_outlined),
                  text: 'Restaurantes',
                ),
                Tab(icon: Icon(Icons.restaurant_menu), text: 'Pratos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildRestaurantsTab(), _buildMealsTab()],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const ClientBottomNavigationBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    final restaurantes = _filteredRestaurants();

    if (_restaurantes.isEmpty && _loadingRestaurants) {
      return const Center(child: CircularProgressIndicator());
    }

    if (restaurantes.isEmpty) {
      final message = _isSearching
          ? 'Nenhum restaurante encontrado para "${_searchController.text.trim()}"'
          : 'Nenhum restaurante encontrado';
      return Center(child: Text(message));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Restaurantes próximos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: restaurantes.length,
            itemBuilder: (context, index) {
              final restaurant = restaurantes[index];
              return RestaurantCard(
                restaurant: restaurant,
                onFavorite: () =>
                    _toggleRestaurantFavoriteById(restaurant.idRestaurante),
              );
            },
          ),
        ),
        if (!_isSearching)
          _buildPaginationControls(
            currentPage: _restaurantPage,
            totalPages: _restaurantTotalPages,
            onPageChanged: (page) => _loadRestaurants(page),
          ),
      ],
    );
  }

  Widget _buildMealsTab() {
    final refeicoes = _filteredMeals();

    if (_refeicoes.isEmpty && _loadingMeals) {
      return const Center(child: CircularProgressIndicator());
    }

    if (refeicoes.isEmpty && !_loadingMeals) {
      final message = _isSearching
          ? 'Nenhum prato encontrado para "${_searchController.text.trim()}"'
          : 'Nenhuma refeição encontrada';
      return Center(child: Text(message));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Pratos disponíveis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: refeicoes.length,
            itemBuilder: (context, index) {
              final meal = refeicoes[index];
              return MealCard(
                meal: meal,
                onFavorite: () => _toggleMealFavoriteById(meal.idRefeicao),
              );
            },
          ),
        ),
        if (!_isSearching)
          _buildPaginationControls(
            currentPage: _mealPage,
            totalPages: _mealTotalPages,
            onPageChanged: (page) => _loadMeals(page),
          ),
      ],
    );
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
  }) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 0
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: const Color.fromARGB(255, 157, 0, 255),
            disabledColor: Colors.grey[300],
          ),
          const SizedBox(width: 16),
          Text(
            'Página ${currentPage + 1} de $totalPages',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            color: const Color.fromARGB(255, 157, 0, 255),
            disabledColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
