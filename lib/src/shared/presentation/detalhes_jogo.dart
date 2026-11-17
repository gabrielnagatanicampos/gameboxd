import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../domain/game.dart';
import 'game_cover.dart';

/// Abre uma folha com os detalhes do jogo (usada em Explorar, GOTY e Home).
void mostrarDetalhesJogo(BuildContext context, Game game, {String? destaque}) {
  final theme = Theme.of(context);

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: GameCover(game: game)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (destaque != null) Text(destaque, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(game.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('Estúdio: ${game.developer}'),
                  Text('Gênero: ${game.genre}'),
                  Text('Lançamento: ${game.releaseYear}'),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 20, color: corEstrela),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(game.semNota
                          ? 'Ainda sem avaliações da comunidade'
                          : '${game.rating.toStringAsFixed(1)} na comunidade'),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
