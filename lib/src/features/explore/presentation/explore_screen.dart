import 'package:flutter/material.dart';

import '../../../shared/data/catalogo_jogos.dart';
import '../../../shared/domain/game.dart';
import '../../../shared/presentation/detalhes_jogo.dart';
import '../../../shared/presentation/game_cover.dart';

/// Busca por título ou estúdio e filtro por gênero, sobre o catálogo de jogos.
List<Game> filtrarCatalogo({String busca = '', String? genero}) {
  final b = busca.trim().toLowerCase();
  return catalogoJogos.where((g) {
    final generoOk = genero == null || g.genre == genero;
    final buscaOk = b.isEmpty ||
        g.title.toLowerCase().contains(b) ||
        g.developer.toLowerCase().contains(b);
    return generoOk && buscaOk;
  }).toList();
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _busca = TextEditingController();
  String? _genero;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final jogos = filtrarCatalogo(busca: _busca.text, genero: _genero);

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _busca,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por jogo ou estúdio',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busca.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_busca.clear),
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todos'),
                    selected: _genero == null,
                    onSelected: (_) => setState(() => _genero = null),
                  ),
                ),
                for (final g in generosDoCatalogo())
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(g),
                      selected: _genero == g,
                      onSelected: (v) => setState(() => _genero = v ? g : null),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: jogos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: tema.colorScheme.outline),
                        const SizedBox(height: 8),
                        Text('Nenhum jogo encontrado.', style: tema.textTheme.titleMedium),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 170,
                      childAspectRatio: 0.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: jogos.length,
                    itemBuilder: (_, i) {
                      final g = jogos[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => mostrarDetalhesJogo(context, g, destaque: g.genre),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GameCover(game: g),
                            const SizedBox(height: 6),
                            Text(g.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: tema.textTheme.labelLarge),
                            Text('${g.releaseYear} · ${g.genre}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tema.textTheme.bodySmall),
                          ],
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
