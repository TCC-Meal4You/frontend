import 'package:flutter/material.dart';
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/rating_card.dart';

class RatingsAndCommentsScreen extends StatefulWidget {
  const RatingsAndCommentsScreen({super.key});

  @override
  State<RatingsAndCommentsScreen> createState() =>
      _RatingsAndCommentsScreenState();
}

class _RatingsAndCommentsScreenState extends State<RatingsAndCommentsScreen> {
  List<UserRatingResponseDTO> _ratings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ratings = await RatingService.getMyRestaurantRatings();
      setState(() {
        _ratings = ratings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
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
                    return RatingCard(rating: rating);
                  },
                ),
              ),
      ),
    );
  }
}
