import 'package:flutter/material.dart';
import 'package:meal4you_app/models/restaurante_response_dto.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/services/search_meal/search_meal_service.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/widgets/search/meal_card.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/rating_card.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/rating_editor.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestauranteResponseDTO restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MealResponseDTO> _meals = [];
  List<UserRatingResponseDTO> _ratings = [];
  bool _loadingMeals = false;
  bool _loadingRatings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMeals();
    _loadRatings();
  }

  Future<void> _loadMeals() async {
    setState(() => _loadingMeals = true);
    try {
      final response = await SearchMealService.listarRefeicoesPorRestaurante(
        widget.restaurant.idRestaurante,
      );
      setState(() {
        _meals = response.refeicoes;
        _loadingMeals = false;
      });
    } catch (e) {
      setState(() => _loadingMeals = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar cardápio: $e')));
    }
  }

  Future<void> _loadRatings() async {
    setState(() => _loadingRatings = true);
    try {
      try {
        final public = await RatingService.listarAvaliacoesPorRestaurante(
          widget.restaurant.idRestaurante,
        );
        setState(() {
          _ratings = public;
          _loadingRatings = false;
        });
        return;
      } catch (e) {
      }

      final all = await RatingService.verMinhasAvaliacoes();
      setState(() {
        _ratings = all
            .where((r) => r.restaurantId == widget.restaurant.idRestaurante)
            .toList();
        _loadingRatings = false;
      });
    } catch (e) {
      setState(() => _loadingRatings = false);
    }
  }

  Future<void> _openEditor({UserRatingResponseDTO? existing}) async {
    await showDialog(
      context: context,
      builder: (_) => RatingEditor(
        restaurantId: widget.restaurant.idRestaurante,
        restaurantName: widget.restaurant.nome,
        existing: existing,
        onSaved: (saved) => _loadRatings(),
      ),
    );
  }

  Future<bool> _confirmDeleteRating() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir avaliação'),
        content: const Text('Tem certeza que deseja excluir esta avaliação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return shouldDelete ?? false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.restaurant.nome,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final existing = _ratings.isNotEmpty ? _ratings.first : null;
              await _openEditor(existing: existing);
            },
            icon: const Icon(
              Icons.rate_review_outlined,
              color: Colors.redAccent,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF9D00FF),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Cardápio'),
            Tab(icon: Icon(Icons.reviews), text: 'Avaliações'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMenuTab(), _buildRatingsTab()],
      ),
    );
  }

  Widget _buildMenuTab() {
    if (_loadingMeals) return const Center(child: CircularProgressIndicator());
    if (_meals.isEmpty)
      return const Center(child: Text('Nenhum prato disponível'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _meals.length,
      itemBuilder: (context, i) {
        final meal = _meals[i];
        return MealCard(meal: meal, onFavorite: () {});
      },
    );
  }

  Widget _buildRatingsTab() {
    if (_loadingRatings)
      return const Center(child: CircularProgressIndicator());
    if (_ratings.isEmpty)
      return const Center(child: Text('Nenhuma avaliação ainda'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ratings.length,
      itemBuilder: (context, i) {
        final r = _ratings[i];
        return RatingCard(
          rating: r,
          onEdit: () => _openEditor(existing: r),
          onDelete: () async {
            if (r.restaurantId == null) return;
            final confirmed = await _confirmDeleteRating();
            if (!confirmed) return;
            try {
              await RatingService.excluirAvaliacao(r.restaurantId!);
              await _loadRatings();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceAll('Exception: ', '')),
                ),
              );
            }
          },
        );
      },
    );
  }
}
