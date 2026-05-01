class UserRatingResponseDTO {
  final int ratingId;
  final int? restaurantId;
  final String userName;
  final double rating;
  final String? comment;
  final DateTime ratingDate;

  UserRatingResponseDTO({
    required this.ratingId,
    this.restaurantId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.ratingDate,
  });

  factory UserRatingResponseDTO.fromJson(Map<String, dynamic> json) {
    DateTime parseRatingDate(dynamic value) {
      if (value == null) return DateTime.now();
      final raw = value.toString().trim();
      if (raw.isEmpty) return DateTime.now();

      // Accept ISO dates first.
      final iso = DateTime.tryParse(raw);
      if (iso != null) return iso;

      // Backend may return dd/MM/yyyy.
      final parts = raw.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }

      return DateTime.now();
    }

    return UserRatingResponseDTO(
      ratingId: json['idAvaliacao'] ?? 0,
      restaurantId: json['idRestaurante'] ?? json['id_restaurante'],
      userName: json['nomeUsuario'] ?? '',
      rating: (json['nota'] ?? 0).toDouble(),
      comment: json['comentario'],
      ratingDate: parseRatingDate(json['dataAvaliacao']),
    );
  }
}
