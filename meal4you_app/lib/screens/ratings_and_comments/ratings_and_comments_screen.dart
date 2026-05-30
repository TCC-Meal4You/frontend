import 'package:flutter/material.dart';
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/models/meal_rating_response_dto.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';
import 'package:meal4you_app/services/search_restaurant/search_restaurant_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/services/user/user_data_service.dart';
import 'package:meal4you_app/services/search_meal/search_meal_service.dart';
import 'package:meal4you_app/services/meal/meal_service.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/rating_card.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/rating_editor.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/meal_rating_card.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/meal_rating_editor.dart';

class RatingsAndCommentsScreen extends StatefulWidget {
  final int? restaurantId;
  const RatingsAndCommentsScreen({super.key, this.restaurantId});
  @override
  State<RatingsAndCommentsScreen> createState() =>
      _RatingsAndCommentsScreenState();
}

class _RatingsAndCommentsScreenState extends State<RatingsAndCommentsScreen> {
  List<UserRatingResponseDTO> _ratings = [];
  List<MealRatingResponseDTO> _mealRatings = [];
  bool _isLoading = true;
  bool _loadingMealRatings = false;
  bool _loadingRestaurantNames = false;
  bool _loadingMealNames = false;
  String? _errorMessage;
  bool _isAdmUser = false;
  bool _loadingUserRole = true;
  int? _resolvedRestaurantId;
  String? _currentUserName;
  String? _currentUserEmail;
  int? _currentUserId;
  final Map<int, String> _userNames = {};
  final Map<int, String> _restaurantNames = {};
  final Map<int, String> _mealNames = {};
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadUserRole();
    _resolvedRestaurantId = await _resolveRestaurantId();
    await _loadRatings();
  }

  Future<void> _loadUserRole() async {
    try {
      final userData = await UserTokenSaving.getUserData();
      final email = await UserTokenSaving.getUserEmail();
      final isAdm =
          userData?['userType'] == 'adm' || userData?['isAdm'] == true;
      String? extractedName;
      int? extractedId;
      if (userData != null) {
        extractedName =
            userData['nome'] ??
            userData['name'] ??
            userData['fullName'] ??
            userData['userName'];
        if (extractedName == null && userData['user'] is Map) {
          final u = userData['user'];
          extractedName = u['nome'] ?? u['name'] ?? u['fullName'];
        }
        final rawId =
            userData['id'] ?? userData['idUsuario'] ?? userData['userId'];
        if (rawId != null) {
          extractedId = int.tryParse(rawId.toString());
        } else if (userData['user'] is Map) {
          final u = userData['user'];
          final nestedId = u['id'];
          if (nestedId != null) {
            extractedId = int.tryParse(nestedId.toString());
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _isAdmUser = isAdm;
        _loadingUserRole = false;
        _currentUserName = extractedName;
        _currentUserEmail = email;
        _currentUserId = extractedId;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isAdmUser = false;
        _loadingUserRole = false;
        _currentUserName = null;
        _currentUserEmail = null;
        _currentUserId = null;
      });
    }
  }

  Future<int?> _resolveRestaurantId() async {
    if (widget.restaurantId != null) {
      return widget.restaurantId;
    }
    final restaurantData =
        await UserTokenSaving.getRestaurantDataForCurrentUser();
    if (restaurantData == null) {
      return null;
    }
    final rawId =
        restaurantData['idRestaurante'] ??
        restaurantData['id'] ??
        restaurantData['id_restaurante'];
    if (rawId == null) {
      return null;
    }
    return int.tryParse(rawId.toString());
  }

  Future<void> _loadRatings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingMealRatings = false;
      _errorMessage = null;
    });
    try {
      final useRestaurantRatings = _isAdmUser || widget.restaurantId != null;
      final targetRestaurantId = _resolvedRestaurantId;
      if (useRestaurantRatings && targetRestaurantId == null) {
        throw Exception(
          'Nenhum restaurante vinculado foi encontrado para listar as avaliações.',
        );
      }
      if (useRestaurantRatings) {
        final restaurantRatings =
            await RatingService.listarAvaliacoesPorRestaurante(
              targetRestaurantId!,
            );

        if (!mounted) return;
        setState(() {
          _ratings = restaurantRatings;
          _mealRatings = [];
          _isLoading = false;
          _loadingMealRatings = true;
          _loadingRestaurantNames = true;
          _loadingMealNames = false;
        });

        _loadUserNamesForRatings();
        _loadMealRatingsForRestaurant(targetRestaurantId);
      } else {
        final results = await Future.wait<dynamic>([
          RatingService.verMinhasAvaliacoes(),
          RatingService.verMinhasAvaliacoesDRefeicao(),
        ]);
        if (!mounted) return;
        setState(() {
          _ratings = results[0] as List<UserRatingResponseDTO>;
          _mealRatings = results[1] as List<MealRatingResponseDTO>;
          _isLoading = false;
          _loadingMealRatings = false;
          _loadingRestaurantNames = true;
          _loadingMealNames = true;
        });

        _loadRestaurantNamesForRatings();
        _loadMealNamesForRatings();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
        _loadingMealRatings = false;
      });
    }
  }

  Future<void> _loadRestaurantNamesForRatings() async {
    final missingIds = _ratings
        .where(
          (rating) =>
              rating.restaurantId != null &&
              rating.restaurantId! > 0 &&
              (rating.restaurantName == null ||
                  rating.restaurantName!.trim().isEmpty),
        )
        .map((rating) => rating.restaurantId!)
        .toSet();

    if (missingIds.isEmpty) {
      return;
    }

    try {
      final names = <int, String>{};
      var page = 1;
      var totalPages = 1;

      while (page <= totalPages && names.length < missingIds.length) {
        final response = await SearchRestaurantService.listarRestaurantes(page);
        totalPages = response.totalPaginas <= 0 ? 1 : response.totalPaginas;

        for (final restaurant in response.restaurantes) {
          if (missingIds.contains(restaurant.idRestaurante)) {
            names[restaurant.idRestaurante] = restaurant.nome;
          }
        }

        page += 1;
      }

      if (!mounted) return;
      setState(() {
        _restaurantNames.addAll(names);
        _loadingRestaurantNames = false;
      });
    } catch (_) {}
  }

  Future<void> _loadMealNamesForRatings() async {
    final missingIds = _mealRatings
        .where(
          (rating) =>
              rating.mealId != null &&
              rating.mealId! > 0 &&
              (rating.mealName == null || rating.mealName!.trim().isEmpty),
        )
        .map((rating) => rating.mealId!)
        .toSet();

    if (missingIds.isEmpty) {
      return;
    }

    try {
      final names = <int, String>{};
      var page = 1;
      var totalPages = 1;

      while (page <= totalPages && names.length < missingIds.length) {
        final response = await SearchMealService.listarRefeicoes(page);
        totalPages = response.totalPaginas <= 0 ? 1 : response.totalPaginas;

        for (final meal in response.refeicoes) {
          if (missingIds.contains(meal.idRefeicao)) {
            names[meal.idRefeicao] = meal.nome;
          }
        }

        page += 1;
      }

      if (!mounted) return;
      setState(() {
        _mealNames.addAll(names);
        _loadingMealNames = false;
      });
    } catch (_) {}
  }

  Future<void> _loadMealRatingsForRestaurant(int idRestaurante) async {
    try {
      final ratings = await _listarAvaliacoesDeRefeicoesDoRestaurante(
        idRestaurante,
      );
      if (!mounted) return;
      setState(() {
        _mealRatings = ratings;
        _loadingMealRatings = false;
      });
    } catch (e) {
      debugPrint(
        '[RatingsScreen] error loading meal ratings for restaurant $idRestaurante: $e',
      );
      if (!mounted) return;
      setState(() {
        _mealRatings = [];
        _loadingMealRatings = false;
      });
    }
  }

  Future<List<MealRatingResponseDTO>> _listarAvaliacoesDeRefeicoesDoRestaurante(
    int idRestaurante,
  ) async {
    try {
      final byRestaurant =
          await RatingService.listarAvaliacoesDeRefeicoesPorRestaurante(
            idRestaurante: idRestaurante,
            idsRefeicoes: const {},
          );

      if (byRestaurant.isNotEmpty) {
        return byRestaurant;
      }

      final mealIds = <int>{};

      try {
        final minhasRefeicoes = await MealService.listarMinhasRefeicoes();
        for (final meal in minhasRefeicoes) {
          if (meal.idRefeicao != 0) {
            mealIds.add(meal.idRefeicao);
          }
        }
      } catch (e) {
        debugPrint('[RatingsScreen] listarMinhasRefeicoes falhou: $e');
      }

      if (mealIds.isEmpty) {
        try {
          final pag = await SearchMealService.listarRefeicoesPorRestaurante(
            idRestaurante,
          );
          for (final meal in pag.refeicoes) {
            if (meal.idRefeicao != 0) {
              mealIds.add(meal.idRefeicao);
            }
          }
        } catch (e) {
          debugPrint(
            '[RatingsScreen] listarRefeicoesPorRestaurante falhou: $e',
          );
        }
      }

      debugPrint(
        '[RatingsScreen] found ${mealIds.length} meals for restaurant $idRestaurante: $mealIds',
      );

      final results = await Future.wait(
        mealIds.map((mealId) async {
          debugPrint('[RatingsScreen] fetching ratings for meal $mealId');
          try {
            final ratings = await RatingService.listarAvaliacoesPorRefeicao(
              mealId,
            );
            debugPrint(
              '[RatingsScreen] meal $mealId => ${ratings.length} ratings',
            );
            return ratings;
          } catch (err) {
            debugPrint(
              '[RatingsScreen] failed to fetch ratings for meal $mealId: $err',
            );
            return <MealRatingResponseDTO>[];
          }
        }),
      );

      final unique = <String, MealRatingResponseDTO>{};
      for (final ratings in results) {
        for (final rating in ratings) {
          final key =
              '${rating.ratingId}-${rating.mealId}-${rating.userId}-${rating.comment}';
          unique[key] = rating;
        }
      }

      return unique.values.toList();
    } catch (e) {
      debugPrint(
        '[RatingsScreen] error listing meals for restaurant $idRestaurante: $e',
      );
      return [];
    }
  }

  void _loadUserNamesForRatings() {
    for (final rating in _ratings) {
      if (rating.userId != null && rating.userId! > 0) {
        if (!_userNames.containsKey(rating.userId)) {
          final uid = rating.userId!;
          UserDataService.getUserNameById(uid)
              .then((name) {
                if (!mounted) return;
                final fallback = (name != null && name.trim().isNotEmpty)
                    ? name.trim()
                    : (rating.userName.trim().isNotEmpty
                          ? rating.userName.trim()
                          : (rating.userEmail != null &&
                                    rating.userEmail!.trim().isNotEmpty
                                ? rating.userEmail!.trim()
                                : 'Usuário #$uid'));
                setState(() {
                  _userNames[uid] = fallback;
                });
              })
              .catchError((_) {
                if (!mounted) return;
                final uid = rating.userId!;
                final fallback = rating.userName.trim().isNotEmpty
                    ? rating.userName.trim()
                    : (rating.userEmail != null &&
                              rating.userEmail!.trim().isNotEmpty
                          ? rating.userEmail!.trim()
                          : 'Usuário #$uid');
                setState(() {
                  _userNames[uid] = fallback;
                });
              });
        }
      }
    }
  }

  bool _isMealRatingOwner(MealRatingResponseDTO rating) {
    if (_currentUserId != null && rating.userId != null) {
      return rating.userId == _currentUserId;
    }
    final currentEmail = _currentUserEmail?.trim().toLowerCase();
    final ratingEmail = rating.userEmail?.trim().toLowerCase();
    if (currentEmail != null &&
        currentEmail.isNotEmpty &&
        ratingEmail != null &&
        ratingEmail.isNotEmpty) {
      return currentEmail == ratingEmail;
    }
    return false;
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Avaliações e Comentários',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_ratings.length + _mealRatings.length} ${_ratings.length + _mealRatings.length == 1 ? 'avaliação' : 'avaliações'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.yellow,
          actions: [
            if (widget.restaurantId != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0FE687),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    UserRatingResponseDTO? existing;
                    try {
                      existing = _ratings.firstWhere(
                        (r) => r.restaurantId == widget.restaurantId,
                      );
                    } catch (e) {
                      existing = null;
                    }
                    await showDialog(
                      context: context,
                      builder: (_) => RatingEditor(
                        restaurantId: widget.restaurantId!,
                        restaurantName:
                            existing?.restaurantName ?? 'Restaurante',
                        existing: existing,
                        onSaved: (saved) => _loadRatings(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Escrever Avaliação'),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadRatings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0FE687),
                      ),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              )
            : (_isAdmUser || widget.restaurantId != null)
            ? (_ratings.isEmpty && _mealRatings.isEmpty && !_loadingMealRatings
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma avaliação ainda',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRatings,
                      color: const Color(0xFF0FE687),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Avaliações de Restaurante',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_ratings.isEmpty)
                            Center(
                              child: Text(
                                'Nenhuma avaliação de restaurante',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          else
                            ..._ratings.map(
                              (rating) => RatingCard(
                                rating: rating,
                                showActions: !_loadingUserRole && !_isAdmUser,
                                currentUserName: _currentUserName,
                                currentUserEmail: _currentUserEmail,
                                currentUserId: _currentUserId,
                                overrideRestaurantName:
                                    _restaurantNames[rating.restaurantId],
                                showRestaurantNameLoading:
                                    _loadingRestaurantNames,
                                onEdit: _loadingUserRole || _isAdmUser
                                    ? null
                                    : () async {
                                        await showDialog(
                                          context: context,
                                          builder: (_) => RatingEditor(
                                            restaurantId:
                                                rating.restaurantId ?? 0,
                                            restaurantName:
                                                rating.restaurantName ??
                                                'Restaurante',
                                            existing: rating,
                                            onSaved: (saved) => _loadRatings(),
                                          ),
                                        );
                                      },
                                onDelete: _loadingUserRole || _isAdmUser
                                    ? null
                                    : () async {
                                        if (rating.restaurantId == null) return;
                                        final confirmed =
                                            await _confirmDeleteRating();
                                        if (!confirmed) return;
                                        try {
                                          await RatingService.excluirAvaliacao(
                                            idAvaliacao: rating.ratingId,
                                            idRestaurante: rating.restaurantId,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Avaliação excluída com sucesso',
                                              ),
                                            ),
                                          );
                                          _loadRatings();
                                        } catch (e) {
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
                                      },
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Avaliações de Refeições',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_loadingMealRatings)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(strokeWidth: 2),
                                    SizedBox(height: 8),
                                    Text(
                                      'Carregando aguarde um momento',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF5A5A5A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_mealRatings.isEmpty)
                            Center(
                              child: Text(
                                'Nenhuma avaliação de refeição',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          else
                            ..._mealRatings.map(
                              (rating) => MealRatingCard(
                                rating: rating,
                                currentUserName: _currentUserName,
                                currentUserEmail: _currentUserEmail,
                                currentUserId: _currentUserId,
                                overrideMealName: _mealNames[rating.mealId],
                                showMealNameLoading: _loadingMealNames,
                                showActions:
                                    !_loadingUserRole &&
                                    _isMealRatingOwner(rating),
                                preferCurrentUserNameIfEmpty:
                                    _isMealRatingOwner(rating),
                                onEdit:
                                    !_loadingUserRole &&
                                        _isMealRatingOwner(rating)
                                    ? () async {
                                        await showDialog(
                                          context: context,
                                          builder: (_) => MealRatingEditor(
                                            mealId: rating.mealId ?? 0,
                                            mealName:
                                                rating.mealName ?? 'Refeição',
                                            existing: rating,
                                            currentUserId: _currentUserId,
                                            currentUserEmail: _currentUserEmail,
                                            currentUserName: _currentUserName,
                                            onSaved: (saved) => _loadRatings(),
                                          ),
                                        );
                                      }
                                    : null,
                                onDelete:
                                    !_loadingUserRole &&
                                        _isMealRatingOwner(rating)
                                    ? () async {
                                        final confirmed =
                                            await _confirmDeleteRating();
                                        if (!confirmed) return;
                                        try {
                                          await RatingService.excluirAvaliacaoRefeicao(
                                            idAvaliacao: rating.ratingId,
                                            idRefeicao: rating.mealId,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Avaliação excluída com sucesso',
                                              ),
                                            ),
                                          );
                                          _loadRatings();
                                        } catch (e) {
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
                              ),
                            ),
                        ],
                      ),
                    ))
            : RefreshIndicator(
                onRefresh: _loadRatings,
                color: const Color(0xFF0FE687),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Avaliações de Restaurantes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_ratings.isEmpty)
                      Center(
                        child: Text(
                          'Nenhuma avaliação de restaurante',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    else
                      ..._ratings.map(
                        (rating) => RatingCard(
                          rating: rating,
                          showActions: !_loadingUserRole && !_isAdmUser,
                          currentUserName: _currentUserName,
                          currentUserEmail: _currentUserEmail,
                          currentUserId: _currentUserId,
                          overrideRestaurantName:
                              _restaurantNames[rating.restaurantId],
                          showRestaurantNameLoading: _loadingRestaurantNames,
                          onEdit: _loadingUserRole || _isAdmUser
                              ? null
                              : () async {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => RatingEditor(
                                      restaurantId: rating.restaurantId ?? 0,
                                      restaurantName:
                                          rating.restaurantName ??
                                          'Restaurante',
                                      existing: rating,
                                      onSaved: (saved) => _loadRatings(),
                                    ),
                                  );
                                },
                          onDelete: _loadingUserRole || _isAdmUser
                              ? null
                              : () async {
                                  if (rating.restaurantId == null) return;
                                  final confirmed =
                                      await _confirmDeleteRating();
                                  if (!confirmed) return;
                                  try {
                                    await RatingService.excluirAvaliacao(
                                      idAvaliacao: rating.ratingId,
                                      idRestaurante: rating.restaurantId,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Avaliação excluída com sucesso',
                                        ),
                                      ),
                                    );
                                    _loadRatings();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                                },
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Avaliações de Refeições',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_loadingMealRatings)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(strokeWidth: 2),
                              SizedBox(height: 8),
                              Text(
                                'Estamos verificando suas avaliações. Aguarde um momento',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5A5A5A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_mealRatings.isEmpty)
                      Center(
                        child: Text(
                          'Nenhuma avaliação de refeição',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    else
                      ..._mealRatings.map(
                        (rating) => MealRatingCard(
                          rating: rating,
                          currentUserName: _currentUserName,
                          currentUserEmail: _currentUserEmail,
                          currentUserId: _currentUserId,
                          overrideMealName: _mealNames[rating.mealId],
                          showMealNameLoading: _loadingMealNames,
                          showActions:
                              !_loadingUserRole && _isMealRatingOwner(rating),
                          preferCurrentUserNameIfEmpty: _isMealRatingOwner(
                            rating,
                          ),
                          onEdit:
                              !_loadingUserRole && _isMealRatingOwner(rating)
                              ? () async {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => MealRatingEditor(
                                      mealId: rating.mealId ?? 0,
                                      mealName: rating.mealName ?? 'Refeição',
                                      existing: rating,
                                      currentUserId: _currentUserId,
                                      currentUserEmail: _currentUserEmail,
                                      currentUserName: _currentUserName,
                                      onSaved: (saved) => _loadRatings(),
                                    ),
                                  );
                                }
                              : null,
                          onDelete:
                              !_loadingUserRole && _isMealRatingOwner(rating)
                              ? () async {
                                  final confirmed =
                                      await _confirmDeleteRating();
                                  if (!confirmed) return;
                                  try {
                                    await RatingService.excluirAvaliacaoRefeicao(
                                      idAvaliacao: rating.ratingId,
                                      idRefeicao: rating.mealId,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Avaliação excluída com sucesso',
                                        ),
                                      ),
                                    );
                                    _loadRatings();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
