import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameboxd/src/features/zerados/domain/colecao_jogos.dart';
import 'package:gameboxd/src/features/zerados/domain/jogo.dart';
import 'package:gameboxd/src/features/zerados/presentation/zerados_providers.dart';
import 'package:gameboxd/src/shared/data/armazenamento_memoria.dart';

void main() {
  setUp(armazenamentoMemoria.clear);

  group('ColecaoJogos', () {
    test('lista vazia tem progresso 0 e meta não batida', () {
      const c = ColecaoJogos();
      expect(c.progresso, 0);
      expect(c.percentual, 0);
      expect(c.metaBatida, isFalse);
      expect(c.mensagemProgresso, '0 de 0 zerados');
      expect(c.avaliados, 0);
      expect(c.mediaNotas, 0);
      expect(c.melhorAvaliado, isNull);
      expect(c.mensagemMedia, 'Sem avaliações ainda');
    });

    test('getters calculam progresso', () {
      const c = ColecaoJogos([
        Jogo(id: 'a', titulo: 'A', zerado: true),
        Jogo(id: 'b', titulo: 'B'),
        Jogo(id: 'c', titulo: 'C', zerado: true),
        Jogo(id: 'd', titulo: 'D'),
      ]);
      expect(c.totalZerados, 2);
      expect(c.progresso, 0.5);
      expect(c.percentual, 50);
      expect(c.mensagemProgresso, '2 de 4 zerados');
      expect(c.metaBatida, isFalse);
    });

    test('todos zerados bate a meta', () {
      const c = ColecaoJogos([Jogo(id: 'a', titulo: 'A', zerado: true)]);
      expect(c.metaBatida, isTrue);
    });

    test('média, avaliados e melhor jogo ignoram jogos sem nota', () {
      final c = ColecaoJogos([
        const Jogo(id: 'a', titulo: 'A', zerado: true).avaliar(5, 'Top'),
        const Jogo(id: 'b', titulo: 'B', zerado: true).avaliar(4, ''),
        const Jogo(id: 'c', titulo: 'C', zerado: true),
        const Jogo(id: 'd', titulo: 'D'),
      ]);
      expect(c.avaliados, 2);
      expect(c.mediaNotas, 4.5);
      expect(c.melhorAvaliado?.id, 'a');
      expect(c.mensagemMedia, '4,5 · 2 avaliações');
    });

    test('mensagemMedia usa o singular com 1 avaliação', () {
      final c = ColecaoJogos([
        const Jogo(id: 'a', titulo: 'A', zerado: true).avaliar(3, ''),
      ]);
      expect(c.mensagemMedia, '3,0 · 1 avaliação');
    });

    test('filtrar separa zerados e faltam', () {
      const c = ColecaoJogos([
        Jogo(id: 'a', titulo: 'A', zerado: true),
        Jogo(id: 'b', titulo: 'B'),
      ]);
      expect(c.filtrar(FiltroZerados.todos).length, 2);
      expect(c.filtrar(FiltroZerados.zerados).single.id, 'a');
      expect(c.filtrar(FiltroZerados.faltam).single.id, 'b');
    });
  });

  group('ZeradosNotifier', () {
    late ProviderContainer container;
    late ZeradosNotifier n;

    ProviderContainer novo() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    setUp(() {
      container = novo();
      n = container.read(zeradosProvider.notifier);
    });

    test('adiciona (com trim), ignora vazio e bloqueia duplicado', () {
      final inicial = container.read(zeradosProvider).total;

      expect(n.adicionar('   '), ResultadoAdicao.vazio);
      expect(n.adicionar('  Meu Jogo '), ResultadoAdicao.adicionado);
      expect(n.adicionar('meu jogo'), ResultadoAdicao.duplicado);

      final lista = container.read(zeradosProvider);
      expect(lista.total, inicial + 1);
      expect(lista.jogos.last.titulo, 'Meu Jogo');
    });

    test('título do catálogo ganha a capa (gameId) e o nome oficial', () {
      expect(n.adicionar('hades'), ResultadoAdicao.adicionado);
      final jogo = container.read(zeradosProvider).jogos.last;
      expect(jogo.titulo, 'Hades');
      expect(jogo.gameId, 'hades');
    });

    test('alterna e remove por id, sem depender do índice', () {
      n.alternar('elden');
      expect(container.read(zeradosProvider).jogos.firstWhere((j) => j.id == 'elden').zerado,
          isTrue);

      final inicial = container.read(zeradosProvider).total;
      expect(n.remover('id-inexistente'), isNull);
      expect(n.remover('celeste'), isNotNull);
      expect(container.read(zeradosProvider).total, inicial - 1);
    });

    test('restaurar devolve o jogo à posição original', () {
      final removido = n.remover('hollow')!;
      expect(container.read(zeradosProvider).jogos.any((j) => j.id == 'hollow'), isFalse);

      n.restaurar(removido.$1, removido.$2);
      final ids = container.read(zeradosProvider).jogos.map((j) => j.id).toList();
      expect(ids.indexOf('hollow'), removido.$2);

      n.restaurar(removido.$1, removido.$2); // repetido não duplica
      expect(container.read(zeradosProvider).jogos.where((j) => j.id == 'hollow').length, 1);
    });

    test('só avalia jogo zerado e com nota de 0 a 5', () {
      expect(n.avaliar('elden', 5, 'x'), isFalse); // não zerado
      expect(n.avaliar('w3', 6, 'x'), isFalse); // nota inválida
      expect(n.avaliar('nao-existe', 3, ''), isFalse);

      expect(n.avaliar('w3', 5, '  Melhor jogo  '), isTrue);
      final w3 = container.read(zeradosProvider).jogos.firstWhere((j) => j.id == 'w3');
      expect(w3.nota, 5);
      expect(w3.comentario, 'Melhor jogo');
    });

    test('avaliação é mantida ao desmarcar e limpa com nota 0', () {
      n.avaliar('w3', 4, 'Amei');
      n.alternar('w3'); // desmarca
      var w3 = container.read(zeradosProvider).jogos.firstWhere((j) => j.id == 'w3');
      expect(w3.zerado, isFalse);
      expect(w3.nota, 4);

      n.alternar('w3'); // zera de novo
      n.avaliar('w3', 0, '');
      w3 = container.read(zeradosProvider).jogos.firstWhere((j) => j.id == 'w3');
      expect(w3.avaliado, isFalse);
    });

    test('persiste: um novo container lê a lista e as avaliações salvas', () {
      n.adicionar('Jogo Salvo');
      n.avaliar('w3', 5, 'Guardado');

      final outro = novo();
      final lista = outro.read(zeradosProvider);
      expect(lista.jogos.any((j) => j.titulo == 'Jogo Salvo'), isTrue);
      final w3 = lista.jogos.firstWhere((j) => j.id == 'w3');
      expect(w3.nota, 5);
      expect(w3.comentario, 'Guardado');
    });

    test('dado salvo corrompido volta para a lista padrão', () {
      armazenamentoMemoria['gameboxd.zerados'] = '{isso não é json';
      final outro = novo();
      expect(outro.read(zeradosProvider).total, 4);
    });
  });
}
