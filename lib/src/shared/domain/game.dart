class Game {
  const Game({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.releaseYear,
    required this.developer,
    required this.genre,
    required this.rating,
  });

  final String id;
  final String title;

  /// Caminho em `assets/covers/...`, URL `http(s)` ou vazio (usa placeholder).
  final String coverUrl;
  final int releaseYear;
  final String developer;
  final String genre;

  /// Média das notas da comunidade (0 a 5).
  final double rating;

  /// Jogo ainda sem avaliações (ex.: lançamento): a nota fica em 0.
  bool get semNota => rating == 0;

  Game copyWith({
    String? id,
    String? title,
    String? coverUrl,
    int? releaseYear,
    String? developer,
    String? genre,
    double? rating,
  }) =>
      Game(
        id: id ?? this.id,
        title: title ?? this.title,
        coverUrl: coverUrl ?? this.coverUrl,
        releaseYear: releaseYear ?? this.releaseYear,
        developer: developer ?? this.developer,
        genre: genre ?? this.genre,
        rating: rating ?? this.rating,
      );

  /// Dois jogos são iguais quando têm o mesmo `id`.
  @override
  bool operator ==(Object other) => other is Game && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as String,
        title: json['title'] as String,
        coverUrl: (json['coverUrl'] as String?) ?? '',
        releaseYear: json['releaseYear'] as int,
        developer: json['developer'] as String,
        genre: json['genre'] as String,
        rating: (json['rating'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverUrl': coverUrl,
        'releaseYear': releaseYear,
        'developer': developer,
        'genre': genre,
        'rating': rating,
      };
}
