import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/catalogo_jogos.dart';
import '../../../shared/presentation/game_cover.dart';
import '../../../shared/presentation/star_rating.dart';
import '../domain/colecao_jogos.dart';
import '../domain/jogo.dart';
import 'zerados_providers.dart';

class ZeradosScreen extends ConsumerStatefulWidget {
  const ZeradosScreen({super.key});

  @override
  ConsumerState<ZeradosScreen> createState() => _ZeradosScreenState();
}

class _ZeradosScreenState extends ConsumerState<ZeradosScreen> {
  final _campo = TextEditingController();
  final _foco = FocusNode();
  FiltroZerados _filtro = FiltroZerados.todos;
  String? _erro;

  @override
  void dispose() {
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _aviso(String texto, {SnackBarAction? acao}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto), action: acao));
  }

  void _adicionar() {
    final resultado = ref.read(zeradosProvider.notifier).adicionar(_campo.text);
    switch (resultado) {
      case ResultadoAdicao.adicionado:
        _campo.clear();
        setState(() => _erro = null);
        _aviso('Jogo adicionado!');
      case ResultadoAdicao.vazio:
        setState(() => _erro = 'Digite o nome do jogo');
      case ResultadoAdicao.duplicado:
        setState(() => _erro = 'Esse jogo já está na lista');
    }
    _foco.requestFocus();
  }

  void _remover(Jogo jogo) {
    final notifier = ref.read(zeradosProvider.notifier);
    final removido = notifier.remover(jogo.id);
    if (removido == null) return;
    _aviso(
      '"${jogo.titulo}" removido',
      acao: SnackBarAction(
        label: 'Desfazer',
        onPressed: () => notifier.restaurar(removido.$1, removido.$2),
      ),
    );
  }

  Future<void> _avaliar(Jogo jogo) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AvaliarSheet(
        jogo: jogo,
        onSalvar: (nota, comentario) {
          ref.read(zeradosProvider.notifier).avaliar(jogo.id, nota, comentario);
          _aviso(nota == 0 ? 'Avaliação removida' : 'Avaliação salva!');
        },
      ),
    );
  }

  /// Até 3 jogos do catálogo cujo título contém o texto e que ainda não estão na lista.
  List<String> _sugestoes(ColecaoJogos colecao) {
    final texto = _campo.text.trim().toLowerCase();
    if (texto.length < 2) return const [];
    final existentes = colecao.jogos.map((j) => j.titulo.toLowerCase()).toSet();
    return [
      for (final g in catalogoJogos)
        if (g.title.toLowerCase().contains(texto) &&
            !existentes.contains(g.title.toLowerCase()))
          g.title,
    ].take(3).toList();
  }

  void _usarSugestao(String titulo) {
    _campo.value = TextEditingValue(
      text: titulo,
      selection: TextSelection.collapsed(offset: titulo.length),
    );
    setState(() => _erro = null);
    _foco.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colecao = ref.watch(zeradosProvider);
    final sugestoes = _sugestoes(colecao);
    final notifier = ref.read(zeradosProvider.notifier);
    final tema = Theme.of(context);
    final jogos = colecao.filtrar(_filtro);

    return Scaffold(
      appBar: AppBar(title: const Text('Jogos zerados')),
      body: Column(
        children: [
          _Cabecalho(colecao: colecao),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _campo,
                    focusNode: _foco,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Adicionar jogo',
                      errorText: _erro,
                    ),
                    onChanged: (_) => setState(() => _erro = null),
                    onSubmitted: (_) => _adicionar(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: IconButton.filled(
                    tooltip: 'Adicionar',
                    onPressed: _adicionar,
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          if (sugestoes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final t in sugestoes)
                      ActionChip(label: Text(t), onPressed: () => _usarSugestao(t)),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  for (final f in FiltroZerados.values)
                    ChoiceChip(
                      label: Text(f.rotulo),
                      selected: _filtro == f,
                      onSelected: (_) => setState(() => _filtro = f),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: colecao.jogos.isEmpty
                ? _Vazio(
                    texto: 'Nenhum jogo ainda.\nAdicione o primeiro!',
                    cor: tema.colorScheme.outline,
                  )
                : jogos.isEmpty
                    ? _Vazio(
                        texto: 'Nenhum jogo neste filtro.',
                        cor: tema.colorScheme.outline,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: jogos.length,
                        itemBuilder: (_, i) {
                          final jogo = jogos[i];
                          return Dismissible(
                            key: ValueKey(jogo.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: tema.colorScheme.errorContainer,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: Icon(Icons.delete_outline,
                                  color: tema.colorScheme.onErrorContainer),
                            ),
                            onDismissed: (_) => _remover(jogo),
                            child: _JogoTile(
                              jogo: jogo,
                              onAlternar: () => notifier.alternar(jogo.id),
                              onAvaliar: () => _avaliar(jogo),
                              onRemover: () => _remover(jogo),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.colecao});

  final ColecaoJogos colecao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${colecao.percentual}%',
                  style: tema.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tema.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(colecao.mensagemProgresso, style: tema.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(end: colecao.progresso),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (_, valor, _) => LinearProgressIndicator(
                value: valor,
                minHeight: 10,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            if (colecao.avaliados > 0) ...[
              const SizedBox(height: 10),
              Row(children: [
                StarRating(nota: colecao.mediaNotas.round(), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Média ${colecao.mensagemMedia}',
                    style: tema.textTheme.bodySmall,
                  ),
                ),
              ]),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: colecao.metaBatida
                  ? Container(
                      key: const ValueKey('meta'),
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tema.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events,
                              color: tema.colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Meta batida! Você zerou todos os jogos.',
                              style: tema.textTheme.titleSmall?.copyWith(
                                  color: tema.colorScheme.onPrimaryContainer),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('sem-meta')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio({required this.texto, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_esports_outlined, size: 64, color: cor),
          const SizedBox(height: 8),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _JogoTile extends StatelessWidget {
  const _JogoTile({
    required this.jogo,
    required this.onAlternar,
    required this.onAvaliar,
    required this.onRemover,
  });

  final Jogo jogo;
  final VoidCallback onAlternar;
  final VoidCallback onAvaliar;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cinza = tema.colorScheme.outline;

    Widget subtitulo;
    if (!jogo.zerado) {
      subtitulo = Text('Zere para poder avaliar',
          style: tema.textTheme.bodySmall?.copyWith(color: cinza));
    } else if (!jogo.avaliado) {
      subtitulo = Text('Toque para avaliar',
          style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.primary));
    } else {
      subtitulo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StarRating(nota: jogo.nota, size: 16),
          if (jogo.comentario.isNotEmpty)
            Text(
              jogo.comentario,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.bodySmall,
            ),
        ],
      );
    }

    return ListTile(
      onTap: jogo.zerado ? onAvaliar : null,
      leading: SizedBox(width: 44, child: GameCover(game: gameDoJogo(jogo))),
      title: Text(
        jogo.titulo,
        style: jogo.zerado
            ? TextStyle(decoration: TextDecoration.lineThrough, color: cinza)
            : null,
      ),
      subtitle: subtitulo,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: jogo.zerado, onChanged: (_) => onAlternar()),
          IconButton(
            tooltip: 'Avaliar',
            icon: Icon(jogo.avaliado ? Icons.rate_review : Icons.rate_review_outlined),
            onPressed: jogo.zerado ? onAvaliar : null,
          ),
          IconButton(
            tooltip: 'Remover',
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemover,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Folha "Avaliar": estrelinhas + comentário
// ---------------------------------------------------------------------------

class _AvaliarSheet extends StatefulWidget {
  const _AvaliarSheet({required this.jogo, required this.onSalvar});

  final Jogo jogo;
  final void Function(int nota, String comentario) onSalvar;

  @override
  State<_AvaliarSheet> createState() => _AvaliarSheetState();
}

class _AvaliarSheetState extends State<_AvaliarSheet> {
  late int _nota = widget.jogo.nota;
  late final _comentario = TextEditingController(text: widget.jogo.comentario);

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  void _salvar(int nota, String comentario) {
    widget.onSalvar(nota, comentario);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final teclado = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + teclado),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(width: 56, child: GameCover(game: gameDoJogo(widget.jogo))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Avaliar', style: tema.textTheme.labelLarge),
                      Text(widget.jogo.titulo, style: tema.textTheme.titleLarge),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: StarRating(
                nota: _nota,
                size: 44,
                onChanged: (n) => setState(() => _nota = n),
              ),
            ),
            const SizedBox(height: 4),
            Center(child: Text(fraseDaNota(_nota), style: tema.textTheme.titleMedium)),
            const SizedBox(height: 16),
            TextField(
              controller: _comentario,
              maxLength: 280,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Seu comentário (opcional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.jogo.avaliado)
                  TextButton(
                    onPressed: () => _salvar(0, ''),
                    child: const Text('Limpar avaliação'),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _nota == 0 ? null : () => _salvar(_nota, _comentario.text),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
