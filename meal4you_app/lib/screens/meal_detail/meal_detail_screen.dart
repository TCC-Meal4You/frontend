import 'package:flutter/material.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/services/favorite/meal_favorite_service.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/meal_rating_editor.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/meal_rating_card.dart';
import 'package:meal4you_app/models/meal_rating_response_dto.dart';

class MealDetailScreen extends StatefulWidget {
  final MealResponseDTO meal;
  const MealDetailScreen({super.key, required this.meal});
  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late Future<List<MealRatingResponseDTO>> _ratingsFuture;
  List<MealRatingResponseDTO> _ratings = [];
  bool _favorito = false;
  String? _currentUserName;
  int? _currentUserId;
  String? _currentUserEmail;
  @override
  void initState() {
    super.initState();
    _favorito =
        MealFavoriteService.favoritosNotifier.value[widget.meal.idRefeicao] ??
        widget.meal.favorito;
    _ratingsFuture = _fetchRatings();
    MealFavoriteService.favoritosNotifier.addListener(
      _syncFavoriteFromNotifier,
    );
    _loadCurrentUser();
  }

  @override
  void dispose() {
    MealFavoriteService.favoritosNotifier.removeListener(
      _syncFavoriteFromNotifier,
    );
    super.dispose();
  }

  void _syncFavoriteFromNotifier() {
    if (!mounted) return;
    final value =
        MealFavoriteService.favoritosNotifier.value[widget.meal.idRefeicao] ??
        widget.meal.favorito;
    if (value == _favorito) return;
    setState(() => _favorito = value);
  }

  Future<void> _loadCurrentUser() async {
    final userData = await UserTokenSaving.getUserData();
    final email = await UserTokenSaving.getUserEmail();
    String? userName;
    int? userId;
    if (userData != null) {
      userName =
          userData['nome'] ??
          userData['name'] ??
          userData['fullName'] ??
          userData['userName'];
      if (userName == null && userData['user'] is Map) {
        final nestedUser = userData['user'];
        userName =
            nestedUser['nome'] ?? nestedUser['name'] ?? nestedUser['fullName'];
      }
      final rawId =
          userData['id'] ?? userData['idUsuario'] ?? userData['userId'];
      if (rawId != null) {
        userId = int.tryParse(rawId.toString());
      } else if (userData['user'] is Map) {
        final nestedId = userData['user']['id'];
        if (nestedId != null) {
          userId = int.tryParse(nestedId.toString());
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _currentUserName = userName;
      _currentUserId = userId;
      _currentUserEmail = email;
    });
  }

  bool _isOwner(MealRatingResponseDTO rating) {
    if (_currentUserId != null && rating.userId != null) {
      return rating.userId == _currentUserId;
    }
    final email = _currentUserEmail?.trim().toLowerCase();
    final ratingEmail = rating.userEmail?.trim().toLowerCase();
    if (email != null &&
        email.isNotEmpty &&
        ratingEmail != null &&
        ratingEmail.isNotEmpty) {
      return email == ratingEmail;
    }
    return false;
  }

  Future<List<MealRatingResponseDTO>> _fetchRatings() async {
    return RatingService.listarAvaliacoesPorRefeicao(widget.meal.idRefeicao);
  }

  Future<void> _refreshRatings() async {
    if (!mounted) return;
    setState(() => _ratingsFuture = _fetchRatings());
    try {
      final ratings = await _ratingsFuture;
      if (!mounted) return;
      setState(() => _ratings = ratings);
    } catch (_) {}
  }

  void _applySavedRating(MealRatingResponseDTO saved) {
    final index = _ratings.indexWhere((rating) {
      if (saved.ratingId > 0 && rating.ratingId == saved.ratingId) {
        return true;
      }
      if (_currentUserId != null && rating.userId == _currentUserId) {
        return true;
      }
      if (_currentUserEmail != null &&
          rating.userEmail != null &&
          rating.userEmail!.trim().isNotEmpty &&
          rating.userEmail!.trim().toLowerCase() ==
              _currentUserEmail!.trim().toLowerCase()) {
        return true;
      }
      return false;
    });

    final updatedRatings = List<MealRatingResponseDTO>.from(_ratings);
    if (index >= 0) {
      updatedRatings[index] = saved;
    } else {
      updatedRatings.insert(0, saved);
    }

    setState(() {
      _ratings = updatedRatings;
      _ratingsFuture = Future.value(
        List<MealRatingResponseDTO>.from(updatedRatings),
      );
    });
  }

  void _removeLocalRating(MealRatingResponseDTO target) {
    final updatedRatings = _ratings.where((rating) {
      if (target.ratingId > 0 && rating.ratingId == target.ratingId) {
        return false;
      }
      if (_currentUserId != null && rating.userId == _currentUserId) {
        return false;
      }
      if (_currentUserEmail != null &&
          rating.userEmail != null &&
          rating.userEmail!.trim().isNotEmpty &&
          rating.userEmail!.trim().toLowerCase() ==
              _currentUserEmail!.trim().toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    setState(() {
      _ratings = updatedRatings;
      _ratingsFuture = Future.value(
        List<MealRatingResponseDTO>.from(updatedRatings),
      );
    });
  }

  void _toggleFavorite() async {
    try {
      await MealFavoriteService.alternarFavorito(widget.meal.idRefeicao);
      if (!mounted) return;
      final newValue = !_favorito;
      MealFavoriteService.setFavoritoLocal(widget.meal.idRefeicao, newValue);
      setState(() => _favorito = newValue);
    } catch (_) {}
  }

  Future<void> _openEditor({MealRatingResponseDTO? existing}) async {
    await showDialog(
      context: context,
      builder: (_) => MealRatingEditor(
        mealId: widget.meal.idRefeicao,
        mealName: widget.meal.nome,
        existing: existing,
        currentUserId: _currentUserId,
        currentUserEmail: _currentUserEmail,
        currentUserName: _currentUserName,
        onSaved: (saved) {
          if (!mounted) return;
          _applySavedRating(saved);
          if (saved.ratingId > 0) {
            _refreshRatings();
          }
        },
      ),
    );
  }

  Future<bool> _confirmDelete() async {
    final should = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir avaliação'),
        content: const Text('Deseja excluir esta avaliação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return should ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return SafeArea(
      child: Scaffold(
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
                onPressed: () async => await _openEditor(),
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
              onPressed: _toggleFavorite,
              icon: Icon(
                _favorito ? Icons.favorite : Icons.favorite_border,
                color: _favorito ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.restaurant_menu,
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
                              meal.nome,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Row(
                            children: [
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meal.tipo,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 157, 0, 255),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: meal.restricoes
                            .map(
                              (r) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      r == 'Pescetariano'
                                          ? Icons.set_meal
                                          : Icons.no_drinks,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      r,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: Colors.grey[200]),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const Text(
                  'Avaliações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<MealRatingResponseDTO>>(
                  future: _ratingsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }
                    final list = snapshot.data ?? _ratings;
                    _ratings = list;
                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Nenhuma avaliação ainda',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: list
                          .map(
                            (r) => MealRatingCard(
                              rating: r,
                              currentUserName: _currentUserName,
                              currentUserEmail: _currentUserEmail,
                              currentUserId: _currentUserId,
                              preferCurrentUserNameIfEmpty: _isOwner(r),
                              showActions: _isOwner(r),
                              onEdit: _isOwner(r)
                                  ? () => _openEditor(existing: r)
                                  : null,
                              onDelete: _isOwner(r)
                                  ? () async {
                                      final confirmed = await _confirmDelete();
                                      if (!confirmed) return;
                                      final backup = r;
                                      _removeLocalRating(r);
                                      setState(() {});
                                      try {
                                        print(
                                          '[MealDetailScreen] iniciando DELETE',
                                        );
                                        await RatingService.excluirAvaliacaoRefeicao(
                                          idAvaliacao: backup.ratingId,
                                          idRefeicao: backup.mealId,
                                        );
                                        print(
                                          '[MealDetailScreen] DELETE completou com sucesso',
                                        );
                                      } catch (e) {
                                        if (mounted) {
                                          final restored =
                                              List<MealRatingResponseDTO>.from(
                                                _ratings,
                                              );
                                          restored.insert(0, backup);
                                          setState(() {
                                            _ratings = restored;
                                            _ratingsFuture = Future.value(
                                              List<MealRatingResponseDTO>.from(
                                                restored,
                                              ),
                                            );
                                          });
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
                                    }
                                  : null,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
