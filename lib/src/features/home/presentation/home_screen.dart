import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/data/catalogo_jogos.dart';
import '../../../shared/presentation/detalhes_jogo.dart';
import '../../../shared/presentation/game_cover.dart';
import '../../../shared/presentation/star_rating.dart';
import '../../goty/presentation/goty_providers.dart';
import '../../zerados/presentation/zerados_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final colecao = ref.watch(zeradosProvider);
    final melhor = colecao.melhorAvaliado;
    final ultima = ref.watch(pastEditionsProvider).first;
    final vencedor = ultima.winnerGame;
    // Lançamentos (sem nota ainda) vêm primeiro; depois os mais bem avaliados.
    final lancamentos = catalogoJogos.where((g) => g.semNota).toList();
    final melhores = (catalogoJogos.where((g) => !g.semNota).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating)))
        .take(8 - lancamentos.length);
    final destaques = [...lancamentos, ...melhores];

    return Scaffold(
      appBar: AppBar(title: const Text('GameBoxd')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Progresso de jogos zerados.
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seu progresso', style: tema.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(colecao.mensagemProgresso, style: tema.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: colecao.progresso,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/zerados'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Ver meus zerados'),
                  ),
                ],
              ),
            ),
          ),
          // Melhor jogo avaliado.
          Card(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: melhor == null
                  ? Row(children: [
                      Icon(Icons.star_rounded, color: tema.colorScheme.outline),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Zere e avalie um jogo para ele aparecer aqui como seu favorito.'),
                      ),
                    ])
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 64, child: GameCover(game: gameDoJogo(melhor))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Seu melhor jogo', style: tema.textTheme.labelLarge),
                              Text(melhor.titulo, style: tema.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              StarRating(nota: melhor.nota, size: 22),
                              if (melhor.comentario.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(melhor.comentario,
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // Vencedor do GOTY mais recente.
          if (vencedor != null) ...[
            const _Titulo('Vencedor do GOTY mais recente'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.go('/goty'),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    SizedBox(width: 64, child: GameCover(game: vencedor)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jogo do Ano ${ultima.year}', style: tema.textTheme.labelLarge),
                          Text(vencedor.title, style: tema.textTheme.titleMedium),
                          Text(vencedor.developer, style: tema.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
            ),
          ],
          // Em destaque.
          const _Titulo('Em destaque'),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: destaques.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final g = destaques[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => mostrarDetalhesJogo(context, g, destaque: g.genre),
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GameCover(game: g),
                        const SizedBox(height: 6),
                        Text(g.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.labelLarge),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/explore'),
              icon: const Icon(Icons.search),
              label: const Text('Explorar todos os jogos'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Text(texto, style: Theme.of(context).textTheme.titleLarge),
      );
}
