import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gameboxd/src/features/goty/data/goty_mock.dart';
import 'package:gameboxd/src/features/goty/domain/goty_edition.dart';
import 'package:gameboxd/src/features/goty/presentation/goty_providers.dart';
import 'package:gameboxd/src/shared/data/armazenamento_memoria.dart';

void main() {
  setUp(armazenamentoMemoria.clear);

  ProviderContainer novo({List<Override> overrides = const []}) {
    final c = ProviderContainer(overrides: overrides);
    addTearDown(c.dispose);
    return c;
  }

  test('voto válido soma 1 ao indicado e é registrado', () {
    final c = novo();
    final antes = c.read(votingProvider).tally['goty']!['rdr2']!;

    expect(c.read(votingProvider.notifier).vote('goty', 'rdr2'), isTrue);

    final estado = c.read(votingProvider);
    expect(estado.myVotes['goty'], 'rdr2');
    expect(estado.tally['goty']!['rdr2'], antes + 1);
  });

  test('só 1 voto por categoria, mas categorias diferentes são independentes', () {
    final c = novo();
    final n = c.read(votingProvider.notifier);

    expect(n.vote('goty', 'rdr2'), isTrue);
    expect(n.vote('goty', 'bg3'), isFalse); // já votou nessa categoria
    expect(c.read(votingProvider).myVotes['goty'], 'rdr2');

    expect(n.vote('direction', 'rdr2'), isTrue);
    expect(c.read(votingProvider).myVotes.length, 2);
  });

  test('indicado ou categoria inexistente é recusado', () {
    final c = novo();
    final n = c.read(votingProvider.notifier);
    final total = c.read(votingProvider).totalFor('goty');

    expect(n.vote('goty', 'nao-existe'), isFalse);
    expect(n.vote('categoria-falsa', 'rdr2'), isFalse);
    expect(c.read(votingProvider).myVotes, isEmpty);
    expect(c.read(votingProvider).totalFor('goty'), total);
  });

  test('votação encerrada não aceita votos', () {
    final encerrada = GotyEdition(
      year: 2020,
      isVotingOpen: false,
      nomineesList: mockCurrentEdition.nomineesList,
    );
    final c = novo(overrides: [currentEditionProvider.overrideWithValue(encerrada)]);

    expect(c.read(votingProvider.notifier).vote('goty', 'rdr2'), isFalse);
    expect(c.read(votingProvider).myVotes, isEmpty);
  });

  test('o voto é guardado e reaparece em um novo container', () {
    final c1 = novo();
    c1.read(votingProvider.notifier).vote('narrative', 'tlou2');
    final somaDepois = c1.read(votingProvider).totalFor('narrative');

    final c2 = novo();
    final estado = c2.read(votingProvider);
    expect(estado.myVotes['narrative'], 'tlou2');
    expect(estado.totalFor('narrative'), somaDepois);
  });

  test('voto salvo para um indicado que não existe mais é ignorado', () {
    armazenamentoMemoria['gameboxd.votos'] = '{"goty":"fantasma"}';
    final c = novo();
    expect(c.read(votingProvider).myVotes, isEmpty);
  });

  test('cada categoria tem sua própria lista de indicados', () {
    final e = mockCurrentEdition;
    ids(String c) => e.nomineesFor(c).map((g) => g.id).toList();
    expect(ids('narrative'), isNot(ids('direction')));
    expect(ids('music'), isNot(ids('indie')));
    expect(ids('goty'), isNot(ids('narrative')));
    for (final c in gotyCategories) {
      expect(e.nomineesFor(c.id), hasLength(5));
    }
  });

  test('indicado de outra categoria é recusado', () {
    final c = novo();
    final n = c.read(votingProvider.notifier);
    expect(n.vote('narrative', 'cx33'), isFalse);
    expect(n.vote('music', 'tlou2'), isFalse);
    expect(n.vote('music', 'cyberpunk'), isTrue);
    expect(c.read(votingProvider).myVotes, {'music': 'cyberpunk'});
  });

  test('placar inicial de narrative difere de direction', () {
    final t = novo().read(votingProvider).tally;
    expect(t['narrative']!.values.toList(), isNot(t['direction']!.values.toList()));
    expect(t['narrative']!.keys, isNot(t['direction']!.keys));
  });
}
