import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameboxd/src/features/explore/presentation/explore_screen.dart';
import 'package:gameboxd/src/shared/data/catalogo_jogos.dart';

void main() {
  group('filtrarCatalogo', () {
    test('sem filtro devolve o catálogo inteiro', () {
      expect(filtrarCatalogo().length, catalogoJogos.length);
    });

    test('busca por título ignora maiúsculas', () {
      final r = filtrarCatalogo(busca: 'ELDEN');
      expect(r.single.id, 'elden');
    });

    test('busca por estúdio', () {
      final r = filtrarCatalogo(busca: 'fromsoftware');
      expect(r.map((g) => g.id), containsAll(['elden', 'sekiro']));
    });

    test('filtro de gênero só devolve jogos daquele gênero', () {
      final r = filtrarCatalogo(genero: 'RPG');
      expect(r, isNotEmpty);
      expect(r.every((g) => g.genre == 'RPG'), isTrue);
    });

    test('busca e gênero combinam', () {
      expect(filtrarCatalogo(busca: 'elden', genero: 'RPG').single.id, 'elden');
      expect(filtrarCatalogo(busca: 'elden', genero: 'Puzzle'), isEmpty);
    });
  });

  testWidgets('digitar na busca filtra a grade e mostra estado vazio', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ExploreScreen()));

    await tester.enterText(find.byType(TextField), 'elden');
    await tester.pump();
    expect(find.text('Elden Ring'), findsWidgets);
    expect(find.text('Celeste'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pump();
    expect(find.text('Nenhum jogo encontrado.'), findsOneWidget);
  });

  testWidgets('chip de gênero filtra a grade', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ExploreScreen()));

    // A lista de chips rola na horizontal: rola até o chip aparecer.
    final chip = find.widgetWithText(FilterChip, 'Puzzle');
    await tester.scrollUntilVisible(
      chip,
      200,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(chip);
    await tester.pump();
    expect(find.text('Portal 2'), findsWidgets);
    expect(find.text('Elden Ring'), findsNothing);
  });
}
