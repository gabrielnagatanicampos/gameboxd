import 'package:flutter_test/flutter_test.dart';
import 'package:gameboxd/src/shared/data/catalogo_jogos.dart';

void main() {
  test('ids do catálogo são únicos', () {
    final ids = catalogoJogos.map((g) => g.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('GTA VI é um lançamento sem nota inventada', () {
    final gta6 = buscarJogoPorId('gta6')!;
    expect(gta6.title, 'Grand Theft Auto VI');
    expect(gta6.releaseYear, 2026);
    expect(gta6.semNota, isTrue);
    expect(gta6.rating, 0);
  });

  test('só lançamentos ficam sem nota; os demais têm nota entre 0 e 5', () {
    for (final g in catalogoJogos.where((g) => !g.semNota)) {
      expect(g.rating, inInclusiveRange(1, 5), reason: g.title);
    }
  });

  test('buscas por título e por id acham o mesmo jogo', () {
    expect(buscarJogoPorTitulo('  red dead redemption 2 ')?.id, 'rdr2');
    expect(buscarJogoPorId('rdr2')?.title, 'Red Dead Redemption 2');
    expect(buscarJogoPorId('nao-existe'), isNull);
  });
}
