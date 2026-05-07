import 'package:flutter/material.dart';
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/widgets/ratings_and_comments/stars_rating.dart';
import 'package:meal4you_app/utils/formatter/date_formatter.dart';


String _avatarLabel(
  UserRatingResponseDTO rating, {
  String? currentUserName,
  String? currentUserEmail,
  int? currentUserId,
}) {
  final name = rating.userName.trim();
  if (name.isNotEmpty) return name;

  final email = rating.userEmail?.trim() ?? '';
  if (currentUserEmail != null &&
      email.isNotEmpty &&
      email == currentUserEmail) {
    if (currentUserName != null && currentUserName.trim().isNotEmpty)
      return currentUserName;
  }

  if (currentUserId != null &&
      rating.userId != null &&
      rating.userId == currentUserId) {
    if (currentUserName != null && currentUserName.trim().isNotEmpty)
      return currentUserName;
  }

  if (email.isNotEmpty) return email;

  final userId = rating.userId;
  if (userId != null && userId > 0) return 'Usuário #$userId';

  if (currentUserName != null && currentUserName.trim().isNotEmpty)
    return currentUserName;

  return 'Usuário';
}

String _avatarInitialFromRating(
  UserRatingResponseDTO rating, {
  String? currentUserName,
  String? currentUserEmail,
  int? currentUserId,
}) {
  final name = rating.userName.trim();
  if (name.isNotEmpty) return name.characters.first.toUpperCase();

  final email = rating.userEmail?.trim() ?? '';
  if (currentUserEmail != null &&
      email.isNotEmpty &&
      email == currentUserEmail) {
    if (currentUserName != null && currentUserName.trim().isNotEmpty) {
      return currentUserName.trim().characters.first.toUpperCase();
    }
  }

  if (currentUserId != null &&
      rating.userId != null &&
      rating.userId == currentUserId) {
    if (currentUserName != null && currentUserName.trim().isNotEmpty) {
      return currentUserName.trim().characters.first.toUpperCase();
    }
  }

  if (email.isNotEmpty) {
    final local = email.split('@').first;
    if (local.isNotEmpty) return local.characters.first.toUpperCase();
  }

  if (currentUserName != null && currentUserName.trim().isNotEmpty) {
    return currentUserName.trim().characters.first.toUpperCase();
  }

  return 'U';
}

class RatingCard extends StatelessWidget {
  final UserRatingResponseDTO rating;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final String? currentUserName;
  final String? currentUserEmail;
  final int? currentUserId;

  const RatingCard({
    super.key,
    required this.rating,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.currentUserName,
    this.currentUserEmail,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🔍 RatingCard debug - userName="${rating.userName}", userEmail="${rating.userEmail}", userId=${rating.userId}, currentUserName=$currentUserName, currentUserEmail=$currentUserEmail, currentUserId=$currentUserId',
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF0FE687),
                child: Text(
                  _avatarInitialFromRating(
                    rating,
                    currentUserName: currentUserName,
                    currentUserEmail: currentUserEmail,
                    currentUserId: currentUserId,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _avatarLabel(
                        rating,
                        currentUserName: currentUserName,
                        currentUserEmail: currentUserEmail,
                        currentUserId: currentUserId,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatExactDateOrDateOnly(
                        rating.ratingDate,
                        hasTime: rating.hasTime,
                      ),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              StarsRating(rating: rating.rating),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(rating.comment!, style: const TextStyle(fontSize: 14)),
          ],
          if (showActions && (onEdit != null || onDelete != null)) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                  ),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
