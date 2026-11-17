class Review {
  Review({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  }) : assert(rating >= 1 && rating <= 5, 'A nota deve estar entre 1 e 5');

  final String id;
  final String gameId;
  final String userId;

  /// Nota em estrelas, de 1 a 5.
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'] as int;
    // O assert do construtor só vale em debug; aqui validamos sempre.
    if (rating < 1 || rating > 5) {
      throw FormatException('A nota deve estar entre 1 e 5', rating);
    }
    return Review(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      userId: json['userId'] as String,
      rating: rating,
      comment: (json['comment'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameId': gameId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };
}
