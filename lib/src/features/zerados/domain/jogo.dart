/// Um jogo da coleção do usuário. Imutável: alterar gera uma nova instância.
class Jogo {
  const Jogo({
    required this.id,
    required this.titulo,
    this.zerado = false,
    this.gameId,
    this.nota = 0,
    this.comentario = '',
  });

  /// Identificador estável (não muda quando a lista é filtrada ou reordenada).
  final String id;
  final String titulo;
  final bool zerado;

  /// Id do jogo no catálogo (dá a capa). Nulo se for um jogo digitado pelo usuário.
  final String? gameId;

  /// Estrelas de 1 a 5; 0 = ainda sem avaliação.
  final int nota;
  final String comentario;

  /// Já tem nota?
  bool get avaliado => nota > 0;

  Jogo copiarCom({bool? zerado, int? nota, String? comentario}) => Jogo(
        id: id,
        titulo: titulo,
        gameId: gameId,
        zerado: zerado ?? this.zerado,
        nota: nota ?? this.nota,
        comentario: comentario ?? this.comentario,
      );

  /// Retorna uma cópia marcada como zerada.
  Jogo marcarZerado() => copiarCom(zerado: true);

  /// Retorna uma cópia com o estado invertido. A avaliação é mantida.
  Jogo alternar() => copiarCom(zerado: !zerado);

  /// Retorna uma cópia avaliada. Só jogos zerados podem ser avaliados.
  /// Use `avaliar(0, '')` para limpar a avaliação.
  Jogo avaliar(int nota, String comentario) {
    if (nota < 0 || nota > 5) {
      throw ArgumentError.value(nota, 'nota', 'deve estar entre 0 e 5');
    }
    if (!zerado) {
      throw StateError('Só é possível avaliar jogos zerados');
    }
    return copiarCom(nota: nota, comentario: comentario.trim());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'zerado': zerado,
        'gameId': gameId,
        'nota': nota,
        'comentario': comentario,
      };

  factory Jogo.fromJson(Map<String, dynamic> json) => Jogo(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        zerado: (json['zerado'] as bool?) ?? false,
        gameId: json['gameId'] as String?,
        nota: ((json['nota'] as num?) ?? 0).toInt().clamp(0, 5),
        comentario: (json['comentario'] as String?) ?? '',
      );
}
