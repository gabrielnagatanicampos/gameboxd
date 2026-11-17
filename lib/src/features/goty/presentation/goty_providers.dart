import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/armazenamento.dart';
import '../data/goty_mock.dart';
import '../domain/goty_edition.dart';

final pastEditionsProvider = Provider<List<GotyEdition>>((ref) => mockPastEditions);

final currentEditionProvider = Provider<GotyEdition>((ref) => mockCurrentEdition);

class VotingState {
  const VotingState({required this.myVotes, required this.tally});

  /// categoryId -> gameId escolhido pelo usuário.
  final Map<String, String> myVotes;

  /// categoryId -> (gameId -> total de votos).
  final Map<String, Map<String, int>> tally;

  int totalFor(String categoryId) =>
      (tally[categoryId] ?? {}).values.fold(0, (a, b) => a + b);
}

int _semente(String categoryId, String gameId) {
  var soma = 0;
  final texto = '$categoryId:$gameId';
  for (var i = 0; i < texto.length; i++) {
    soma += (i + 1) * texto.codeUnitAt(i);
  }
  return 15 + soma % 40;
}

class VotingNotifier extends Notifier<VotingState> {
  static const _chave = 'gameboxd.votos';

  @override
  VotingState build() {
    final edition = ref.read(currentEditionProvider);
    // Votos iniciais ilustrativos: número determinístico por (categoria, jogo).
    final tally = {
      for (final c in gotyCategories)
        c.id: {
          for (final g in edition.nomineesFor(c.id)) g.id: _semente(c.id, g.id),
        },
    };

    // Votos que o usuário já deu (guardados no navegador), só se ainda forem válidos.
    final meus = <String, String>{};
    for (final e in _carregarVotos().entries) {
      final categoriaOk = gotyCategories.any((c) => c.id == e.key);
      final indicadoOk = categoriaOk && edition.nomineesFor(e.key).any((g) => g.id == e.value);
      if (categoriaOk && indicadoOk) {
        meus[e.key] = e.value;
        tally[e.key]![e.value] = (tally[e.key]![e.value] ?? 0) + 1;
      }
    }
    return VotingState(myVotes: meus, tally: tally);
  }

  Map<String, String> _carregarVotos() {
    try {
      final bruto = lerArmazenado(_chave);
      if (bruto == null) return {};
      return (jsonDecode(bruto) as Map<String, dynamic>).map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }

  /// Registra o voto. Devolve `false` (sem alterar nada) se a votação estiver encerrada,
  /// a categoria ou o indicado não existir, ou se o usuário já votou nessa categoria.
  bool vote(String categoryId, String gameId) {
    final edition = ref.read(currentEditionProvider);
    if (!edition.isVotingOpen) return false;
    if (!gotyCategories.any((c) => c.id == categoryId)) return false;
    if (!edition.nomineesFor(categoryId).any((g) => g.id == gameId)) return false;
    if (state.myVotes.containsKey(categoryId)) return false;

    final tally = {
      for (final e in state.tally.entries) e.key: Map<String, int>.from(e.value),
    };
    final categoria = tally.putIfAbsent(categoryId, () => {});
    categoria[gameId] = (categoria[gameId] ?? 0) + 1;
    final meus = {...state.myVotes, categoryId: gameId};
    state = VotingState(myVotes: meus, tally: tally);
    gravarArmazenado(_chave, jsonEncode(meus));
    return true;
  }
}

final votingProvider =
    NotifierProvider<VotingNotifier, VotingState>(VotingNotifier.new);
