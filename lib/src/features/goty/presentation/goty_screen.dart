import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/game.dart';
import '../../../shared/presentation/detalhes_jogo.dart';
import '../../../shared/presentation/game_cover.dart';
import '../domain/goty_edition.dart';
import 'goty_providers.dart';

class GotyScreen extends ConsumerWidget {
  const GotyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final past = ref
        .watch(pastEditionsProvider)
        .where((e) => e.winnerGame != null)
        .toList();
    final current = ref.watch(currentEditionProvider);

    // Cartão proporcional à tela; altura acompanha o tamanho da fonte (sem overflow).
    final largura = (MediaQuery.sizeOf(context).width / 2.4).clamp(140.0, 190.0);
    final escala = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final altura = largura * 4 / 3 + 16 + 60 * escala;

    return Scaffold(
      appBar: AppBar(title: const Text('GOTY & Votação')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _SectionTitle('Votação da comunidade ${current.year}'),
          VotingCard(edition: current),
          const _SectionTitle('Vencedores anteriores'),
          if (past.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Nenhum vencedor registrado ainda.'),
            )
          else
            SizedBox(
              height: altura,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: past.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _WinnerCard(edition: past[i], width: largura),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      );
}

// ---------------------------------------------------------------------------
// Carrossel de vencedores
// ---------------------------------------------------------------------------

class _WinnerCard extends StatelessWidget {
  const _WinnerCard({required this.edition, required this.width});

  final GotyEdition edition;
  final double width;

  @override
  Widget build(BuildContext context) {
    final game = edition.winnerGame;
    if (game == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => mostrarDetalhesJogo(
        context,
        game,
        destaque: 'Jogo do Ano ${edition.year}',
      ),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                GameCover(game: game),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      '${edition.year}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(game.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall),
            Text(game.developer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de votação
// ---------------------------------------------------------------------------

class VotingCard extends ConsumerStatefulWidget {
  const VotingCard({super.key, required this.edition});

  final GotyEdition edition;

  @override
  ConsumerState<VotingCard> createState() => _VotingCardState();
}

class _VotingCardState extends ConsumerState<VotingCard> {
  String _categoryId = gotyCategories.first.id;
  String? _selectedGameId;

  void _confirm() {
    final id = _selectedGameId;
    if (id == null) return;
    final ok = ref.read(votingProvider.notifier).vote(_categoryId, id);
    setState(() => _selectedGameId = null);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok
            ? 'Voto confirmado! Veja o resultado parcial.'
            : 'Não foi possível registrar o voto.'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final voting = ref.watch(votingProvider);
    final myVote = voting.myVotes[_categoryId];
    final hasVoted = myVote != null;
    final category = gotyCategories.firstWhere((c) => c.id == _categoryId);
    final votes = voting.tally[_categoryId] ?? const <String, int>{};

    final nominees = [...widget.edition.nomineesFor(_categoryId)];
    if (hasVoted) {
      // Mais votados primeiro; em empate, ordem alfabética (estável).
      nominees.sort((a, b) {
        final porVotos = (votes[b.id] ?? 0).compareTo(votes[a.id] ?? 0);
        return porVotos != 0 ? porVotos : a.title.compareTo(b.title);
      });
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.edition.isVotingOpen ? 'Votação aberta' : 'Votação encerrada',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Icon(
                  widget.edition.isVotingOpen ? Icons.how_to_vote : Icons.lock_outline,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final c in gotyCategories)
                  ChoiceChip(
                    label: Text(c.name),
                    selected: c.id == _categoryId,
                    avatar: voting.myVotes.containsKey(c.id)
                        ? const Icon(Icons.check_circle, size: 18)
                        : null,
                    onSelected: (_) => setState(() {
                      _categoryId = c.id;
                      _selectedGameId = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasVoted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Voto confirmado em ${category.name}. Resultado parcial:'),
                  ),
                ]),
              )
            else if (widget.edition.isVotingOpen)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Você tem 1 voto por categoria e não dá para desfazer.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            for (final game in nominees)
              hasVoted
                  ? _ResultRow(
                      game: game,
                      votes: votes[game.id] ?? 0,
                      total: voting.totalFor(_categoryId),
                      isMine: game.id == myVote,
                    )
                  : _NomineeTile(
                      game: game,
                      selected: game.id == _selectedGameId,
                      onTap: () => setState(() => _selectedGameId = game.id),
                    ),
            if (!hasVoted && widget.edition.isVotingOpen) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedGameId == null ? null : _confirm,
                  icon: const Icon(Icons.how_to_vote),
                  label: Text('Confirmar voto em ${category.name}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NomineeTile extends StatelessWidget {
  const _NomineeTile({required this.game, required this.selected, required this.onTap});

  final Game game;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
        color: selected ? scheme.primaryContainer.withValues(alpha: .4) : null,
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: SizedBox(width: 40, child: GameCover(game: game)),
        title: Text(game.title),
        subtitle: Text('${game.developer} · ${game.genre}'),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? scheme.primary : null,
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.game,
    required this.votes,
    required this.total,
    required this.isMine,
  });

  final Game game;
  final int votes;
  final int total;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = total == 0 ? 0.0 : votes / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 36, child: GameCover(game: game)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      game.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isMine ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isMine)
                    Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
                ]),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(pct * 100).round()}% · $votes ${votes == 1 ? 'voto' : 'votos'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
