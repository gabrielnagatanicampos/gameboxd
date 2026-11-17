import 'package:flutter_test/flutter_test.dart';
import 'package:gameboxd/src/features/zerados/domain/jogo.dart';

void main() {
  const celeste = Jogo(id: 'c', titulo: 'Celeste');

  test('jogo começa não zerado e sem avaliação', () {
    expect(celeste.zerado, isFalse);
    expect(celeste.avaliado, isFalse);
    expect(celeste.nota, 0);
    expect(celeste.comentario, '');
  });

  test('marcarZerado marca como zerado', () {
    expect(celeste.marcarZerado().zerado, isTrue);
  });

  test('alternar inverte o estado sem alterar o original', () {
    expect(celeste.alternar().zerado, isTrue);
    expect(celeste.alternar().alternar().zerado, isFalse);
    expect(celeste.zerado, isFalse);
  });

  test('avaliar guarda nota e comentário (sem espaços nas pontas)', () {
    final avaliado = celeste.marcarZerado().avaliar(5, '  Obra-prima!  ');
    expect(avaliado.nota, 5);
    expect(avaliado.avaliado, isTrue);
    expect(avaliado.comentario, 'Obra-prima!');
  });

  test('só jogo zerado pode ser avaliado', () {
    expect(() => celeste.avaliar(4, ''), throwsStateError);
  });

  test('nota fora de 0 a 5 é recusada', () {
    final zerado = celeste.marcarZerado();
    expect(() => zerado.avaliar(6, ''), throwsArgumentError);
    expect(() => zerado.avaliar(-1, ''), throwsArgumentError);
  });

  test('avaliar(0, "") limpa a avaliação', () {
    final limpo = celeste.marcarZerado().avaliar(3, 'ok').avaliar(0, '');
    expect(limpo.avaliado, isFalse);
    expect(limpo.comentario, '');
  });

  test('desmarcar zerado mantém a avaliação guardada', () {
    final jogo = celeste.marcarZerado().avaliar(4, 'Amei').alternar();
    expect(jogo.zerado, isFalse);
    expect(jogo.nota, 4);
    expect(jogo.comentario, 'Amei');
  });

  test('toJson e fromJson preservam todos os campos', () {
    final original = const Jogo(id: 'x', titulo: 'Hades', gameId: 'hades', zerado: true)
        .avaliar(5, 'Viciante');
    final copia = Jogo.fromJson(original.toJson());
    expect(copia.id, 'x');
    expect(copia.titulo, 'Hades');
    expect(copia.gameId, 'hades');
    expect(copia.zerado, isTrue);
    expect(copia.nota, 5);
    expect(copia.comentario, 'Viciante');
  });
}
