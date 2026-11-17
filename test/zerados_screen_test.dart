import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameboxd/src/features/zerados/presentation/zerados_screen.dart';
import 'package:gameboxd/src/shared/data/armazenamento_memoria.dart';

Future<void> abrir(WidgetTester tester) async {
  // Tela alta para a lista inteira ser construída.
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const ProviderScope(
    child: MaterialApp(home: ZeradosScreen()),
  ));
}

void main() {
  setUp(armazenamentoMemoria.clear);

  testWidgets('adicionar e marcar jogos atualiza progresso e meta', (tester) async {
    await abrir(tester);

    expect(find.text('2 de 4 zerados'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Meu Jogo');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('Meu Jogo'), findsWidgets);
    expect(find.text('2 de 5 zerados'), findsOneWidget);

    // Marca todos que faltam.
    for (final i in [2, 3, 4]) {
      await tester.tap(find.byType(Checkbox).at(i));
      await tester.pump();
    }
    expect(find.text('5 de 5 zerados'), findsOneWidget);
    expect(find.textContaining('Meta batida'), findsOneWidget);
  });

  testWidgets('lista vazia mostra o estado vazio e progresso 0%', (tester) async {
    await abrir(tester);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();
    }

    expect(find.text('0 de 0 zerados'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.textContaining('Nenhum jogo ainda'), findsOneWidget);
    expect(find.textContaining('Meta batida'), findsNothing);
  });

  testWidgets('jogo repetido ou vazio mostra erro no campo', (tester) async {
    await abrir(tester);

    await tester.enterText(find.byType(TextField), 'celeste');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('Esse jogo já está na lista'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('Digite o nome do jogo'), findsOneWidget);
  });

  testWidgets('remover mostra Desfazer e restaura o jogo', (tester) async {
    await abrir(tester);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1 de 3 zerados'), findsOneWidget);

    await tester.tap(find.text('Desfazer'));
    await tester.pump();
    expect(find.text('2 de 4 zerados'), findsOneWidget);
  });

  testWidgets('filtro Faltam mostra só os jogos não zerados', (tester) async {
    await abrir(tester);

    await tester.tap(find.text('Faltam'));
    await tester.pump();
    expect(find.byType(Checkbox), findsNWidgets(2));
  });

  testWidgets('avaliar jogo zerado com estrelas e comentário', (tester) async {
    await abrir(tester);

    // Jogos ainda não zerados mostram a dica.
    expect(find.text('Zere para poder avaliar'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Avaliar').first);
    await tester.pumpAndSettle();
    expect(find.text('Toque nas estrelas'), findsOneWidget);

    // Quarta estrela = "Amei!".
    await tester.tap(find.byIcon(Icons.star_outline_rounded).at(3));
    await tester.pump();
    expect(find.text('Amei!'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Seu comentário (opcional)'),
      'Muito bom',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Média 4,0 · 1 avaliação'), findsOneWidget);
    expect(find.text('Muito bom'), findsOneWidget);
    // 4 estrelas cheias no item da lista + 4 na média do cabeçalho.
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(8));
  });

  testWidgets('digitar mostra sugestões do catálogo e tocar preenche o campo', (tester) async {
    await abrir(tester);

    await tester.enterText(find.byType(TextField), 'red');
    await tester.pump();

    final chip = find.widgetWithText(ActionChip, 'Red Dead Redemption 2');
    expect(chip, findsOneWidget);

    await tester.tap(chip);
    await tester.pump();
    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.controller!.text, 'Red Dead Redemption 2');
  });
}
