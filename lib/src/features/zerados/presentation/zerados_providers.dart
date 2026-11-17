import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/armazenamento.dart';
import '../../../shared/data/catalogo_jogos.dart';
import '../../../shared/domain/game.dart';
import '../domain/colecao_jogos.dart';
import '../domain/jogo.dart';

enum ResultadoAdicao { adicionado, vazio, duplicado }

/// Jogo do catálogo correspondente (para a capa) ou um jogo sem capa.
Game gameDoJogo(Jogo j) =>
    (j.gameId == null ? null : buscarJogoPorId(j.gameId!)) ??
    Game(
      id: j.id,
      title: j.titulo,
      coverUrl: '',
      releaseYear: 0,
      developer: '',
      genre: '',
      rating: 0,
    );

class ZeradosNotifier extends Notifier<ColecaoJogos> {
  static const _chave = 'gameboxd.zerados';
  int _sequencia = 0;

  static const _inicial = ColecaoJogos([
    Jogo(id: 'w3', titulo: 'The Witcher 3: Wild Hunt', gameId: 'w3', zerado: true),
    Jogo(id: 'hollow', titulo: 'Hollow Knight', gameId: 'hollow', zerado: true),
    Jogo(id: 'elden', titulo: 'Elden Ring', gameId: 'elden'),
    Jogo(id: 'celeste', titulo: 'Celeste', gameId: 'celeste'),
  ]);

  @override
  ColecaoJogos build() => _carregar() ?? _inicial;

  ColecaoJogos? _carregar() {
    try {
      final bruto = lerArmazenado(_chave);
      if (bruto == null) return null;
      final lista = (jsonDecode(bruto) as List<dynamic>)
          .map((e) => Jogo.fromJson(e as Map<String, dynamic>))
          .toList();
      return ColecaoJogos(lista);
    } catch (_) {
      return null; // dado corrompido: volta ao padrão
    }
  }

  void _definir(ColecaoJogos nova) {
    state = nova;
    gravarArmazenado(_chave, jsonEncode(nova.jogos.map((j) => j.toJson()).toList()));
  }

  String _novoId() => 'j${DateTime.now().microsecondsSinceEpoch}-${_sequencia++}';

  /// Adiciona um jogo ainda não zerado. Se o título existir no catálogo, usa a capa dele.
  ResultadoAdicao adicionar(String titulo) {
    final t = titulo.trim();
    if (t.isEmpty) return ResultadoAdicao.vazio;
    final doCatalogo = buscarJogoPorTitulo(t);
    final nome = doCatalogo?.title ?? t;
    final jaExiste = state.jogos.any((j) => j.titulo.toLowerCase() == nome.toLowerCase());
    if (jaExiste) return ResultadoAdicao.duplicado;
    _definir(ColecaoJogos([
      ...state.jogos,
      Jogo(id: _novoId(), titulo: nome, gameId: doCatalogo?.id),
    ]));
    return ResultadoAdicao.adicionado;
  }

  void alternar(String id) {
    _definir(ColecaoJogos([
      for (final j in state.jogos) j.id == id ? j.alternar() : j,
    ]));
  }

  /// Remove e devolve o jogo com a posição, para permitir "Desfazer". Nulo se não existir.
  (Jogo, int)? remover(String id) {
    final indice = state.jogos.indexWhere((j) => j.id == id);
    if (indice < 0) return null;
    final jogo = state.jogos[indice];
    _definir(ColecaoJogos([...state.jogos]..removeAt(indice)));
    return (jogo, indice);
  }

  /// Desfaz uma remoção, devolvendo o jogo à posição original.
  void restaurar(Jogo jogo, int indice) {
    if (state.jogos.any((j) => j.id == jogo.id)) return;
    final lista = [...state.jogos];
    lista.insert(indice.clamp(0, lista.length), jogo);
    _definir(ColecaoJogos(lista));
  }

  /// Salva nota (1 a 5) e comentário. Use nota 0 para limpar. Só vale para jogo zerado.
  bool avaliar(String id, int nota, String comentario) {
    if (nota < 0 || nota > 5) return false;
    final indice = state.jogos.indexWhere((j) => j.id == id);
    if (indice < 0 || !state.jogos[indice].zerado) return false;
    _definir(ColecaoJogos([
      for (final j in state.jogos) j.id == id ? j.avaliar(nota, comentario) : j,
    ]));
    return true;
  }
}

final zeradosProvider =
    NotifierProvider<ZeradosNotifier, ColecaoJogos>(ZeradosNotifier.new);
