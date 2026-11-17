import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameboxd/src/shared/domain/game.dart';
import 'package:gameboxd/src/shared/presentation/game_cover.dart';
import 'package:gameboxd/src/shared/presentation/star_rating.dart';

Game jogo(String capa) => Game(
      id: 'x',
      title: 'Jogo X',
      coverUrl: capa,
      releaseYear: 2020,
      developer: 'Dev',
      genre: 'RPG',
      rating: 4,
    );

Widget app(Widget filho) => MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 120, child: filho))));

void main() {
  group('GameCover', () {
    testWidgets('sem URL mostra o placeholder com o título', (tester) async {
      await tester.pumpWidget(app(GameCover(game: jogo(''))));
      expect(find.byIcon(Icons.sports_esports), findsOneWidget);
      expect(find.text('Jogo X'), findsOneWidget);
    });

    testWidgets('asset inexistente cai no placeholder em vez de quebrar', (tester) async {
      await tester.pumpWidget(app(GameCover(game: jogo('assets/covers/nao-existe.jpg'))));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.sports_esports), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('capa real do catálogo usa Image.asset', (tester) async {
      await tester.pumpWidget(app(GameCover(game: jogo('assets/covers/celeste.jpg'))));
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('StarRating', () {
    testWidgets('editável: tocar na 4ª estrela chama onChanged(4)', (tester) async {
      int? escolhida;
      await tester.pumpWidget(app(StarRating(nota: 2, onChanged: (n) => escolhida = n)));

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(3));

      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(1)); // 4ª estrela
      await tester.pump();
      expect(escolhida, 4);
    });

    testWidgets('somente leitura: não tem área de toque', (tester) async {
      await tester.pumpWidget(app(const StarRating(nota: 3)));
      expect(find.byType(InkResponse), findsNothing);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    });

    test('fraseDaNota cobre 0 a 5', () {
      expect(fraseDaNota(0), 'Toque nas estrelas');
      expect(fraseDaNota(1), 'Não curti');
      expect(fraseDaNota(5), 'Obra-prima!');
    });
  });
}
