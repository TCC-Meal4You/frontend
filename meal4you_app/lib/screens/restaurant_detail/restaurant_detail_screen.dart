import 'package:flutter/material.dart';
import 'package:meal4you_app/models/restaurante_response_dto.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/services/search_meal/search_meal_service.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/widgets/search/meal_card.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/rating_card.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/rating_editor.dart';
import 'package:meal4you_app/services/favorite/meal_favorite_service.dart';
import 'package:meal4you_app/services/favorite/restaurant_favorite_service.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestauranteResponseDTO restaurant;
  const RestaurantDetailScreen({super.key, required this.restaurant});
  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  List<MealResponseDTO> _meals = [];
  List<UserRatingResponseDTO> _ratings = [];
  bool _loadingMeals = false;
  bool _mealsLoaded = false;
  bool _ratingsLoaded = false;
  bool _restaurantFavorito = false;
  Future<List<UserRatingResponseDTO>>? _ratingsFuture;
  String? _currentUserName;
  String? _currentUserEmail;
  int? _currentUserId;
  @override
  void initState() {
    super.initState();
    _restaurantFavorito = widget.restaurant.favorito;
    _loadUserName();
    _loadMeals();
    _primeRatings();
  }

  @override
  void didUpdateWidget(RestaurantDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurant.idRestaurante != widget.restaurant.idRestaurante) {
      _meals = [];
      _ratings = [];
      _loadingMeals = false;
      _mealsLoaded = false;
      _ratingsLoaded = false;
      _ratingsFuture = null;
      _loadMeals();
      _primeRatings();
    }
    if (oldWidget.restaurant.favorito != widget.restaurant.favorito) {
      _restaurantFavorito = widget.restaurant.favorito;
      if (mounted) setState(() {});
    }
  }

  Future<void> _toggleMealFavorite(int mealId) async {
    final index = _meals.indexWhere((m) => m.idRefeicao == mealId);
    if (index == -1) return;
    final meal = _meals[index];
    final id = meal.idRefeicao;
    if (!mounted) return;
    setState(() {
      _meals[index] = meal.copyWith(favorito: !meal.favorito);
    });
    try {
      await MealFavoriteService.alternarFavorito(id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _meals[index] = meal;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao favoritar prato: $e')));
    }
  }

  Future<void> _loadUserName() async {
    try {
      final userData = await UserTokenSaving.getUserData();
      final email = await UserTokenSaving.getUserEmail();
      String? extracted;
      int? extractedId;
      if (userData != null) {
        extracted =
            userData['nome'] ??
            userData['name'] ??
            userData['fullName'] ??
            userData['userName'];
        if (extracted == null && userData['user'] is Map) {
          final u = userData['user'];
          extracted = u['nome'] ?? u['name'] ?? u['fullName'];
        }
        final rawId =
            userData['id'] ??
            userData['idUsuario'] ??
            userData['userId'] ??
            (userData['user'] is Map ? userData['user']['id'] : null);
        if (rawId != null) {
          extractedId = int.tryParse(rawId.toString());
        }
      }
      if (!mounted) return;
      setState(() {
        _currentUserName = extracted;
        _currentUserEmail = email;
        _currentUserId = extractedId;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentUserName = null;
        _currentUserEmail = null;
        _currentUserId = null;
      });
    }
  }

  Future<void> _loadMeals() async {
    if (_mealsLoaded) return;
    if (!mounted) return;
    setState(() => _loadingMeals = true);
    try {
      final response = await SearchMealService.listarRefeicoesPorRestaurante(
        widget.restaurant.idRestaurante,
      );
      if (!mounted) return;
      setState(() {
        _meals = response.refeicoes;
        _loadingMeals = false;
        _mealsLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMeals = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar cardápio: $e')));
    }
  }

  Future<List<UserRatingResponseDTO>> _fetchRatings() async {
    try {
      return await RatingService.listarAvaliacoesPorRestaurante(
        widget.restaurant.idRestaurante,
      );
    } catch (_) {
      final all = await RatingService.verMinhasAvaliacoes();
      return all
          .where((r) => r.restaurantId == widget.restaurant.idRestaurante)
          .toList();
    }
  }

  Future<void> _primeRatings() async {
    if (_ratingsFuture != null) return;
    _ratingsFuture = _fetchRatings();
    try {
      final ratings = await _ratingsFuture!;
      if (!mounted) return;
      setState(() {
        _ratings = ratings;
        _ratingsLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ratings = [];
        _ratingsLoaded = true;
      });
    }
  }

  Future<void> _refreshRatings() async {
    _ratingsLoaded = false;
    _ratingsFuture = _fetchRatings();
    try {
      final ratings = await _ratingsFuture!;
      if (!mounted) return;
      setState(() {
        _ratings = ratings;
        _ratingsLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ratings = [];
        _ratingsLoaded = true;
      });
    }
  }

  Future<void> _openEditor({UserRatingResponseDTO? existing}) async {
    await showDialog(
      context: context,
      builder: (_) => RatingEditor(
        restaurantId: widget.restaurant.idRestaurante,
        restaurantName: widget.restaurant.nome,
        existing: existing,
        onSaved: (saved) {
          if (mounted) {
            _refreshRatings();
          }
        },
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

  void _showRatingsBottomSheet() {
    _ratingsFuture ??= _fetchRatings();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (statefulContext, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _ratingsLoaded
                              ? 'Avaliações (${_ratings.length})'
                              : 'Avaliações (...)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<UserRatingResponseDTO>>(
                      future: _ratingsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final ratings = snapshot.data ?? _ratings;
                        if (ratings.isEmpty) {
                          return const Center(
                            child: Text('Nenhuma avaliação ainda'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: ratings.length,
                          itemBuilder: (context, i) {
                            final r = ratings[i];
                            final isOwner =
                                _currentUserId != null &&
                                r.userId != null &&
                                r.userId == _currentUserId;
                            return RatingCard(
                              rating: r,
                              currentUserName: _currentUserName,
                              currentUserEmail: _currentUserEmail,
                              currentUserId: _currentUserId,
                              showActions: isOwner,
                              onEdit: isOwner
                                  ? () async {
                                      await showDialog(
                                        context: statefulContext,
                                        builder: (_) => RatingEditor(
                                          restaurantId:
                                              widget.restaurant.idRestaurante,
                                          restaurantName:
                                              widget.restaurant.nome,
                                          existing: r,
                                          onSaved: (saved) async {
                                            final latest =
                                                await _fetchRatings();
                                            if (!mounted ||
                                                !sheetContext.mounted) {
                                              return;
                                            }
                                            setState(() {
                                              _ratings = latest;
                                              _ratingsLoaded = true;
                                            });
                                            _ratingsFuture = Future.value(
                                              List<UserRatingResponseDTO>.from(
                                                latest,
                                              ),
                                            );
                                            setModalState(() {});
                                          },
                                        ),
                                      );
                                    }
                                  : null,
                              onDelete: isOwner
                                  ? () async {
                                      final confirmed =
                                          await _confirmDeleteRating();
                                      if (!confirmed) return;
                                      try {
                                        await RatingService.excluirAvaliacao(
                                          idAvaliacao: r.ratingId,
                                          idRestaurante: r.restaurantId,
                                        );
                                        final latest = await _fetchRatings();
                                        if (!mounted || !sheetContext.mounted) {
                                          return;
                                        }
                                        setState(() {
                                          _ratings = latest;
                                          _ratingsLoaded = true;
                                        });
                                        _ratingsFuture = Future.value(
                                          List<UserRatingResponseDTO>.from(
                                            latest,
                                          ),
                                        );
                                        setModalState(() {});
                                      } catch (e) {
                                        if (!sheetContext.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              e.toString().replaceAll(
                                                'Exception: ',
                                                '',
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: TextButton.icon(
              onPressed: () async {
                final existing = _ratings.isNotEmpty ? _ratings.first : null;
                await _openEditor(existing: existing);
              },
              icon: const Icon(
                Icons.rate_review_outlined,
                color: Color.fromARGB(255, 157, 0, 255),
              ),
              label: const Text(
                'Avaliar',
                style: TextStyle(color: Color.fromARGB(255, 157, 0, 255)),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 157, 0, 255),
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              try {
                await RestaurantFavoriteService.alternarFavorito(
                  widget.restaurant.idRestaurante,
                );
                if (!mounted) return;
                setState(() {
                  _restaurantFavorito = !_restaurantFavorito;
                });
                // notifica outros widgets sobre a mudança
                RestaurantFavoriteService.setFavoritoLocal(
                  widget.restaurant.idRestaurante,
                  _restaurantFavorito,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Erro: $e')));
              }
            },
            icon: Icon(
              _restaurantFavorito ? Icons.favorite : Icons.favorite_border,
              color: _restaurantFavorito ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.restaurant.nome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (widget.restaurant.avaliacaoMedia != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.restaurant.avaliacaoMedia!
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.restaurant.tipoComida,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 157, 0, 255),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '0% compatível',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (widget.restaurant.tempoEntrega != null) ...[
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.restaurant.tempoEntrega!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (widget.restaurant.distancia != null) ...[
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.restaurant.distancia!.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildOptionChip('Pescetariano'),
                            _buildOptionChip('Sem Lactose'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await _loadMeals();
                                },
                                icon: const Icon(Icons.restaurant_menu),
                                label: const Text('Cardápio'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green[600],
                                  side: BorderSide(color: Colors.green[600]!),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showRatingsBottomSheet,
                                icon: const Icon(Icons.rate_review_outlined),
                                label: Text(
                                  _ratingsLoaded
                                      ? 'Avaliações (${_ratings.length})'
                                      : 'Avaliações (...)',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 20,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cardápio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_loadingMeals)
                          const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_meals.isEmpty)
                          const SizedBox(
                            height: 100,
                            child: Center(
                              child: Text('Nenhum prato disponível'),
                            ),
                          )
                        else
                          SizedBox(
                            height: _meals.length * 160,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _meals.length,
                              itemBuilder: (context, index) {
                                final meal = _meals[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: MealCard(
                                    meal: meal,
                                    onFavorite: () =>
                                        _toggleMealFavorite(meal.idRefeicao),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            label == 'Pescetariano' ? Icons.set_meal : Icons.no_drinks,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
