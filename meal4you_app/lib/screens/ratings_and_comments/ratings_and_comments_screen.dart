import 'package:flutter/material.dart';
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/rating_card.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/rating_editor.dart';

class RatingsAndCommentsScreen extends StatefulWidget {
  final int? restaurantId;
  const RatingsAndCommentsScreen({super.key, this.restaurantId});
  @override
  State<RatingsAndCommentsScreen> createState() =>
      _RatingsAndCommentsScreenState();
}

class _RatingsAndCommentsScreenState extends State<RatingsAndCommentsScreen> {
  List<UserRatingResponseDTO> _ratings = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAdmUser = false;
  bool _loadingUserRole = true;
  String? _currentUserName;
  String? _currentUserEmail;
  int? _currentUserId;
  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadRatings();
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

  Future<void> _loadRatings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final ratings = await RatingService.verMinhasAvaliacoes();
      if (!mounted) return;
      setState(() {
        _ratings = ratings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
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
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_ratings.length} ${_ratings.length == 1 ? 'avaliação' : 'avaliações'}',
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
                        existing: existing, // may be null
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
            : _ratings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma avaliação ainda',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadRatings,
                color: const Color(0xFF0FE687),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ratings.length,
                  itemBuilder: (context, index) {
                    final rating = _ratings[index];
                    return RatingCard(
                      rating: rating,
                      showActions: !_loadingUserRole && !_isAdmUser,
                      currentUserName: _currentUserName,
                      currentUserEmail: _currentUserEmail,
                      currentUserId: _currentUserId,
                      onEdit: _loadingUserRole || _isAdmUser
                          ? null
                          : () async {
                              await showDialog(
                                context: context,
                                builder: (_) => RatingEditor(
                                  restaurantId: rating.restaurantId ?? 0,
                                  restaurantName:
                                      rating.restaurantName ?? 'Restaurante',
                                  existing: rating,
                                  onSaved: (saved) => _loadRatings(),
                                ),
                              );
                            },
                      onDelete: _loadingUserRole || _isAdmUser
                          ? null
                          : () async {
                              if (rating.restaurantId == null) return;
                              final confirmed = await _confirmDeleteRating();
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
                    );
                  },
                ),
              ),
      ),
    );
  }
}
