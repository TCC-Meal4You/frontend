import 'package:flutter/material.dart';
import 'package:meal4you_app/models/restaurante_response_dto.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/services/search_restaurant/search_restaurant_service.dart';
import 'package:meal4you_app/services/search_meal/search_meal_service.dart';
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
              return RestaurantCard(restaurant: restaurant);
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
              return MealCard(meal: meal);
            },
          ),
        ),
      ],
    );
  }
}
