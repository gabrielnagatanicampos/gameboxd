import 'jogo.dart';

/// Filtro da lista de Zerados.
enum FiltroZerados {
  todos('Todos'),
  zerados('Zerados'),
  faltam('Faltam');

  const FiltroZerados(this.rotulo);
  final String rotulo;
}

/// Lista de jogos com as estatísticas de progresso e de avaliações.
class ColecaoJogos {
  const ColecaoJogos([this.jogos = const []]);

  final List<Jogo> jogos;

  int get total => jogos.length;

  int get totalZerados => jogos.where((j) => j.zerado).length;

  /// Fração de 0 a 1 (lista vazia = 0).
  double get progresso => total == 0 ? 0 : totalZerados / total;

  int get percentual => (progresso * 100).round();

  /// Meta batida: há jogos e todos estão zerados.
  bool get metaBatida => total > 0 && totalZerados == total;

  String get mensagemProgresso => '$totalZerados de $total zerados';

  /// Quantos jogos têm nota.
  int get avaliados => jogos.where((j) => j.avaliado).length;

  /// Média das notas dos jogos avaliados (0 se não há nenhuma).
  double get mediaNotas => avaliados == 0
      ? 0
      : jogos.where((j) => j.avaliado).fold<int>(0, (soma, j) => soma + j.nota) /
          avaliados;

  /// Jogo com a maior nota (em empate, o primeiro da lista). Nulo sem avaliações.
  Jogo? get melhorAvaliado {
    Jogo? melhor;
    for (final j in jogos) {
      if (j.avaliado && (melhor == null || j.nota > melhor.nota)) melhor = j;
    }
    return melhor;
  }

  /// Ex.: "4,5 · 2 avaliações".
  String get mensagemMedia {
    if (avaliados == 0) return 'Sem avaliações ainda';
    final media = mediaNotas.toStringAsFixed(1).replaceAll('.', ',');
    return '$media · $avaliados ${avaliados == 1 ? 'avaliação' : 'avaliações'}';
  }

  List<Jogo> filtrar(FiltroZerados filtro) => switch (filtro) {
        FiltroZerados.todos => jogos,
        FiltroZerados.zerados => jogos.where((j) => j.zerado).toList(),
        FiltroZerados.faltam => jogos.where((j) => !j.zerado).toList(),
      };
}
