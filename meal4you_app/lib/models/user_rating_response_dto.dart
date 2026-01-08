class UserRatingResponseDTO {
  final int ratingId;
  final String userName;
  final double rating;
  final String? comment;
  final DateTime ratingDate;

  UserRatingResponseDTO({
    required this.ratingId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.ratingDate,
  });

  factory UserRatingResponseDTO.fromJson(Map<String, dynamic> json) {
    return UserRatingResponseDTO(
      ratingId: json['idAvaliacao'] ?? 0,
      userName: json['nomeUsuario'] ?? '',
      rating: (json['nota'] ?? 0).toDouble(),
      comment: json['comentario'],
      ratingDate: json['dataAvaliacao'] != null
          ? DateTime.parse(json['dataAvaliacao'])
          : DateTime.now(),
    );
  }
}
