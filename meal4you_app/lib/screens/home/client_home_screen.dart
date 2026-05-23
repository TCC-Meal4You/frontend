import 'package:flutter/material.dart';
import 'package:meal4you_app/controllers/logout_handlers/client_logout_handler.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/models/restaurante_response_dto.dart';
import 'package:meal4you_app/screens/meal_detail/meal_detail_screen.dart';
import 'package:meal4you_app/screens/restaurant_detail/restaurant_detail_screen.dart';
import 'package:meal4you_app/screens/search_restaurant_and_dish/search_restaurant_and_dish_screen.dart';
import 'package:meal4you_app/services/recommendation/knn_recommendation_service.dart';
import 'package:meal4you_app/services/search_meal/search_meal_service.dart';
import 'package:meal4you_app/services/search_restaurant/search_restaurant_service.dart';
import 'package:meal4you_app/services/user_restriction/user_restriction_service.dart';
import 'package:meal4you_app/widgets/navigation/client_bottom_navigation_bar.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});
  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final ClientLogoutHandler _clientlogoutHandler = ClientLogoutHandler();
  List<String> _restricoes = [];
  bool _loadingRestricoes = true;
  bool _loadingRecomendacoes = true;
  String? _erroRecomendacoes;
  List<RestauranteResponseDTO> _restaurantesRecomendados = [];
  List<MealResponseDTO> _refeicoesRecomendadas = [];

  @override
  void initState() {
    super.initState();
    _carregarRestricoes();
    _carregarRecomendacoes();
  }

  Future<void> _carregarRestricoes() async {
    try {
      final nomesRestricoes = await UserRestrictionService.buscarRestricoes();
      if (!mounted) return;
      setState(() {
        _restricoes = nomesRestricoes.isNotEmpty
            ? nomesRestricoes
            : ['Nenhuma restrição'];
        _loadingRestricoes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _restricoes = ['Erro ao carregar'];
        _loadingRestricoes = false;
      });
    }
  }

  Future<void> _carregarRecomendacoes() async {
    if (!mounted) return;
    setState(() {
      _loadingRecomendacoes = true;
      _erroRecomendacoes = null;
    });

    try {
      final results = await Future.wait<List<int>>([
        KnnRecommendationService.obterRecomendacoesRestaurantes(),
        KnnRecommendationService.obterRecomendacoesRefeicoes(),
      ]);

      final restaurantes = await _buscarRestaurantesPorIds(results[0]);
      final refeicoes = await _buscarRefeicoesPorIds(results[1]);

      if (!mounted) return;
      setState(() {
        _restaurantesRecomendados = restaurantes;
        _refeicoesRecomendadas = refeicoes;
        _loadingRecomendacoes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroRecomendacoes = e.toString().replaceAll('Exception: ', '');
        _loadingRecomendacoes = false;
      });
    }
  }

  Future<List<RestauranteResponseDTO>> _buscarRestaurantesPorIds(
    List<int> ids,
  ) async {
    if (ids.isEmpty) return [];

    final ordem = ids.toSet().toList();
    final encontrados = <int, RestauranteResponseDTO>{};
    var pagina = 0;
    var totalPaginas = 1;

    while (pagina < totalPaginas && encontrados.length < ordem.length) {
      final response = await SearchRestaurantService.listarRestaurantes(
        pagina + 1,
      );
      totalPaginas = response.totalPaginas;

      for (final restaurante in response.restaurantes) {
        if (ordem.contains(restaurante.idRestaurante)) {
          encontrados[restaurante.idRestaurante] = restaurante;
        }
      }

      pagina += 1;
    }

    return ordem
        .where((id) => encontrados.containsKey(id))
        .map((id) => encontrados[id]!)
        .toList();
  }

  Future<List<MealResponseDTO>> _buscarRefeicoesPorIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final ordem = ids.toSet().toList();
    final encontrados = <int, MealResponseDTO>{};
    var pagina = 0;
    var totalPaginas = 1;

    while (pagina < totalPaginas && encontrados.length < ordem.length) {
      final response = await SearchMealService.listarRefeicoes(pagina + 1);
      totalPaginas = response.totalPaginas;

      for (final refeicao in response.refeicoes) {
        if (ordem.contains(refeicao.idRefeicao)) {
          encontrados[refeicao.idRefeicao] = refeicao;
        }
      }

      pagina += 1;
    }

    return ordem
        .where((id) => encontrados.containsKey(id))
        .map((id) => encontrados[id]!)
        .toList();
  }

  Widget _buildHeaderSection(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SearchRestaurantAndDishScreen(),
                ),
              );
            },
            child: const Text(
              'Ver todos',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                color: Color(0xFF0AA84F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenciasCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFDF4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrando por suas preferências:',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 15,
              color: Color(0xFF236742),
            ),
          ),
          const SizedBox(height: 10),
          if (_loadingRestricoes)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _restricoes
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF8E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Color(0xFF0A8E43),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRestaurantItem(RestauranteResponseDTO restaurant) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(left: 16, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 128,
              decoration: const BoxDecoration(
                color: Color(0xFFE7E9EF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  color: Colors.grey[500],
                  size: 42,
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
                          restaurant.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (restaurant.avaliacaoMedia != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              restaurant.avaliacaoMedia!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    restaurant.tipoComida,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
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
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (restaurant.distancia != null) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${restaurant.distancia!.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(MealResponseDTO meal) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)));
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(left: 16, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 128,
              decoration: const BoxDecoration(
                color: Color(0xFFE7E9EF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant_menu,
                  color: Colors.grey[500],
                  size: 42,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'R\$ ${meal.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0AA84F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    meal.tipo,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                  if (meal.restricoes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: meal.restricoes
                            .take(3)
                            .map(
                              (item) => Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFFDF4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 11,
                                    color: Color(0xFF236742),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList<T>(
    List<T> items,
    Widget Function(T) itemBuilder,
  ) {
    if (_loadingRecomendacoes) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_erroRecomendacoes != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          _erroRecomendacoes!,
          style: TextStyle(fontFamily: 'Ubuntu', color: Colors.grey[700]),
        ),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Sem recomendações no momento.',
          style: TextStyle(fontFamily: 'Ubuntu', color: Colors.grey[700]),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => itemBuilder(items[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFFCF9FF),
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                    mainAxisSize: MainAxisSize.min,
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
                              onPressed: () => _clientlogoutHandler
                                  .showLogoutDialog(context),
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _loadingRestricoes
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Column(
                              children: [
                                const Text(
                                  'Buscando opções para:',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontFamily: 'Ubuntu',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _restricoes.join(', '),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Ubuntu',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                _buildPreferenciasCard(),
                _buildHeaderSection('Restaurantes Recomendados'),
                _buildHorizontalList<RestauranteResponseDTO>(
                  _restaurantesRecomendados,
                  _buildRestaurantItem,
                ),
                _buildHeaderSection('Refeições Recomendadas'),
                _buildHorizontalList<MealResponseDTO>(
                  _refeicoesRecomendadas,
                  _buildMealItem,
                ),
              ],
            ),
          ),
          bottomNavigationBar: const ClientBottomNavigationBar(currentIndex: 0),
        ),
      ),
    );
  }
}
