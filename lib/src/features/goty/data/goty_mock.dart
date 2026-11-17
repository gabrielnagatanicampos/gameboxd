import '../../../shared/data/catalogo_jogos.dart';
import '../../../shared/domain/game.dart';
import '../domain/goty_edition.dart';

// Vencedores (2014 a 2025) vêm do catálogo único e conferem com o The Game Awards.
// Notas são ilustrativas.

GotyEdition _past(int year, String idDoVencedor) => GotyEdition(
      year: year,
      winnerGame: jogoDoCatalogo(idDoVencedor),
      nomineesList: const [],
      isVotingOpen: false,
    );

final List<GotyEdition> mockPastEditions = [
  _past(2025, 'cx33'),
  _past(2024, 'astro'),
  _past(2023, 'bg3'),
  _past(2022, 'elden'),
  _past(2021, 'ittakestwo'),
  _past(2020, 'tlou2'),
  _past(2019, 'sekiro'),
  _past(2018, 'gow'),
  _past(2017, 'botw'),
  _past(2016, 'ow'),
  _past(2015, 'w3'),
  _past(2014, 'dai'),
];

List<Game> _ids(List<String> ids) => ids.map(jogoDoCatalogo).toList();

/// Votação da comunidade GameBoxd; indicados reais do catálogo, votos iniciais ilustrativos.
final GotyEdition mockCurrentEdition = _montarAtual();

GotyEdition _montarAtual() {
  final porCategoria = <String, List<Game>>{
    'goty': _ids(['cx33', 'bg3', 'rdr2', 'elden', 'hades']),
    'direction': _ids(['botw', 'gow', 'rdr2', 'sekiro', 'astro']),
    'narrative': _ids(['rdr2', 'tlou2', 'disco', 'w3', 'silenthill2']),
    'music': _ids(['cx33', 'undertale', 'celeste', 'cyberpunk', 'p5r']),
    'indie': _ids(['hollow', 'celeste', 'hades', 'stardew', 'undertale']),
  };
  final uniao = <String, Game>{
    for (final lista in porCategoria.values)
      for (final g in lista) g.id: g,
  };
  return GotyEdition(
    year: 2026,
    isVotingOpen: true,
    nomineesList: uniao.values.toList(),
    categoryNominees: porCategoria,
  );
}
