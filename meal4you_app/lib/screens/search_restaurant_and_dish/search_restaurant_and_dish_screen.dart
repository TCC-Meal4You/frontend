import 'package:flutter/material.dart';
import 'package:meal4you_app/models/restaurante_response_dto.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/services/search_restaurant/search_restaurant_service.dart';
import 'package:meal4you_app/services/search_meal/search_meal_service.dart';

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
  final ScrollController _restaurantScrollController = ScrollController();
  final ScrollController _mealScrollController = ScrollController();

  List<RestauranteResponseDTO> _restaurantes = [];
  List<MealResponseDTO> _refeicoes = [];

  int _restaurantPage = 0;
  int _mealPage = 0;
  int _restaurantTotalPages = 1;
  int _mealTotalPages = 1;

  bool _loadingRestaurants = false;
  bool _loadingMeals = false;
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _restaurantScrollController.addListener(_onRestaurantScroll);
    _mealScrollController.addListener(_onMealScroll);

    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    if (_loadingRestaurants ||
        _restaurantPage >= _restaurantTotalPages - 1 && _initialLoadDone) {
      return;
    }

    setState(() => _loadingRestaurants = true);

    try {
      final response = await SearchRestaurantService.listarRestaurantes(
        _restaurantPage,
      );

      setState(() {
        _restaurantes.addAll(response.restaurantes);
        _restaurantTotalPages = response.totalPaginas;
        _restaurantPage++;
        _loadingRestaurants = false;
        _initialLoadDone = true;
      });
    } catch (e) {
      setState(() => _loadingRestaurants = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar restaurantes: $e')),
        );
      }
    }
  }

  Future<void> _loadMeals() async {
    if (_loadingMeals || _mealPage >= _mealTotalPages - 1 && _initialLoadDone) {
      return;
    }

    setState(() => _loadingMeals = true);

    try {
      final response = await SearchMealService.listarRefeicoes(_mealPage);

      setState(() {
        _refeicoes.addAll(response.refeicoes);
        _mealTotalPages = response.totalPaginas;
        _mealPage++;
        _loadingMeals = false;
      });
    } catch (e) {
      setState(() => _loadingMeals = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar refeições: $e')),
        );
      }
    }
  }

  void _onRestaurantScroll() {
    if (_restaurantScrollController.position.pixels >=
        _restaurantScrollController.position.maxScrollExtent * 0.8) {
      _loadRestaurants();
    }
  }

  void _onMealScroll() {
    if (_mealScrollController.position.pixels >=
        _mealScrollController.position.maxScrollExtent * 0.8) {
      _loadMeals();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _restaurantScrollController.dispose();
    _mealScrollController.dispose();
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
                  _loadMeals();
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
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 157, 0, 255),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          ],
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/clientHome');
            }
          },
        ),
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    if (_restaurantes.isEmpty && _loadingRestaurants) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_restaurantes.isEmpty) {
      return const Center(child: Text('Nenhum restaurante encontrado'));
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
            controller: _restaurantScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _restaurantes.length + (_loadingRestaurants ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _restaurantes.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final restaurant = _restaurantes[index];
              return _buildRestaurantCard(restaurant);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMealsTab() {
    if (_refeicoes.isEmpty && _loadingMeals) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_refeicoes.isEmpty && !_loadingMeals) {
      return const Center(child: Text('Nenhuma refeição encontrada'));
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
            controller: _mealScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _refeicoes.length + (_loadingMeals ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _refeicoes.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final meal = _refeicoes[index];
              return _buildMealCard(meal);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(RestauranteResponseDTO restaurant) {
    final compatibilidade = _calcularCompatibilidade(restaurant);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              if (compatibilidade != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      compatibilidade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      restaurant.favorito
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: restaurant.favorito
                          ? Colors.red
                          : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (restaurant.avaliacaoMedia != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            restaurant.avaliacaoMedia!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.tipoComida,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (restaurant.tempoEntrega != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.tempoEntrega!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    if (restaurant.distancia != null) ...[
                      if (restaurant.tempoEntrega != null)
                        const SizedBox(width: 12),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.distancia!.toStringAsFixed(1)} km',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _buildRestrictionChips(restaurant.tipoComida),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(MealResponseDTO meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.restaurant_menu,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        meal.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'R\$ ${meal.preco.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9D00FF),
                      ),
                    ),
                  ],
                ),
                if (meal.descricao != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    meal.descricao!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: meal.restricoes
                      .map((restricao) => _buildRestrictionChip(restricao))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _calcularCompatibilidade(RestauranteResponseDTO restaurant) {
    return '100% compatível';
  }

  List<Widget> _buildRestrictionChips(String tipoComida) {
    final tipos = tipoComida.split(',').map((e) => e.trim()).toList();
    return tipos.map((tipo) => _buildRestrictionChip(tipo)).toList();
  }

  Widget _buildRestrictionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: Colors.green[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}
