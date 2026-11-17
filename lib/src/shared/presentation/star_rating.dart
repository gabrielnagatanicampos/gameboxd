import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Frase carinhosa para cada nota (0 = ainda sem nota).
String fraseDaNota(int nota) => switch (nota) {
      1 => 'Não curti',
      2 => 'Podia ser melhor',
      3 => 'Gostei',
      4 => 'Amei!',
      5 => 'Obra-prima!',
      _ => 'Toque nas estrelas',
    };

/// Cinco estrelinhas arredondadas. Sem [onChanged] é só leitura (pequena, para listas);
/// com [onChanged] é editável e a estrela tocada dá um "pulinho".
class StarRating extends StatefulWidget {
  const StarRating({
    super.key,
    required this.nota,
    this.onChanged,
    this.size = 20,
  });

  /// De 0 (sem nota) a 5.
  final int nota;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int _ultima = 0; // estrela (1 a 5) que acabou de ser tocada
  int _pulso = 0; // muda a cada toque para reiniciar a animação

  void _tocar(int n) {
    setState(() {
      _ultima = n;
      _pulso++;
    });
    widget.onChanged?.call(n);
  }

  @override
  Widget build(BuildContext context) {
    final vazia = Theme.of(context).colorScheme.outlineVariant;
    final editavel = widget.onChanged != null;

    return Semantics(
      label: '${widget.nota} de 5 estrelas',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++) _estrela(i, vazia, editavel),
        ],
      ),
    );
  }

  Widget _estrela(int i, Color vazia, bool editavel) {
    final cheia = i <= widget.nota;
    Widget icone = Icon(
      cheia ? Icons.star_rounded : Icons.star_outline_rounded,
      size: widget.size,
      color: cheia ? corEstrela : vazia,
    );

    if (cheia && i == _ultima) {
      icone = TweenAnimationBuilder<double>(
        key: ValueKey(_pulso),
        tween: Tween(begin: 1.4, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (_, escala, filho) => Transform.scale(scale: escala, child: filho),
        child: icone,
      );
    }

    if (!editavel) return icone;

    return Semantics(
      button: true,
      label: 'Dar $i ${i == 1 ? 'estrela' : 'estrelas'}',
      child: InkResponse(
        onTap: () => _tocar(i),
        radius: widget.size * .8,
        child: Padding(padding: const EdgeInsets.all(2), child: icone),
      ),
    );
  }
}
