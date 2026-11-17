import '../../../shared/domain/game.dart';

class GotyEdition {
  const GotyEdition({
    required this.year,
    this.winnerGame,
    required this.nomineesList,
    required this.isVotingOpen,
    this.categoryNominees = const {},
  });

  final int year;

  /// Nulo enquanto a votação da edição ainda está aberta.
  final Game? winnerGame;
  final List<Game> nomineesList;
  final bool isVotingOpen;

  /// Indicados por categoria (categoryId -> jogos). Se faltar, vale [nomineesList].
  final Map<String, List<Game>> categoryNominees;

  List<Game> nomineesFor(String categoryId) =>
      categoryNominees[categoryId] ?? nomineesList;

  factory GotyEdition.fromJson(Map<String, dynamic> json) => GotyEdition(
        year: json['year'] as int,
        winnerGame: json['winnerGame'] == null
            ? null
            : Game.fromJson(json['winnerGame'] as Map<String, dynamic>),
        nomineesList: (json['nomineesList'] as List<dynamic>? ?? [])
            .map((e) => Game.fromJson(e as Map<String, dynamic>))
            .toList(),
        isVotingOpen: (json['isVotingOpen'] as bool?) ?? false,
      );
}

/// Categoria de votação (cada usuário tem 1 voto por categoria).
class VoteCategory {
  const VoteCategory(this.id, this.name);

  final String id;
  final String name;
}

const gotyCategories = [
  VoteCategory('goty', 'Jogo do Ano'),
  VoteCategory('direction', 'Melhor Direção'),
  VoteCategory('narrative', 'Melhor Narrativa'),
  VoteCategory('music', 'Melhor Trilha Sonora'),
  VoteCategory('indie', 'Melhor Indie'),
];
