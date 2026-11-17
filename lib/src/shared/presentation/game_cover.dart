import 'package:flutter/material.dart';

import '../domain/game.dart';

/// Capa do jogo. `assets/...` usa a imagem embutida, `http(s)` baixa da internet;
/// se não houver imagem (ou ela falhar), mostra um placeholder com o título.
class GameCover extends StatelessWidget {
  const GameCover({super.key, required this.game, this.aspectRatio = 3 / 4});

  final Game game;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _imagem(context),
      ),
    );
  }

  Widget _imagem(BuildContext context) {
    final url = game.coverUrl;
    Widget erro(BuildContext c, Object e, StackTrace? s) => _placeholder(c);

    // Aparece com fade quando termina de carregar.
    Widget fade(BuildContext c, Widget filho, int? frame, bool sincrono) {
      if (sincrono) return filho;
      return AnimatedOpacity(
        opacity: frame == null ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: filho,
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        semanticLabel: 'Capa de ${game.title}',
        frameBuilder: fade,
        errorBuilder: erro,
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        semanticLabel: 'Capa de ${game.title}',
        frameBuilder: fade,
        errorBuilder: erro,
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Sem capa: ${game.title}',
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primaryContainer, scheme.tertiaryContainer],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_esports, color: scheme.onPrimaryContainer.withValues(alpha: .7)),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                game.title,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
