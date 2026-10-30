import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Posição do cartão do tour em relação ao alvo (funções puras).
class TourLayout {
  const TourLayout._();

  /// Alvo na parte de baixo da tela: o cartão vai em cima; senão, embaixo.
  static bool cardAbove(Rect target, Size screen) => target.center.dy > screen.height * 0.55;

  /// Ponta da setinha (x), presa dentro do cartão ([cardLeft]..[cardRight])
  /// com uma margem para não sair do canto arredondado.
  static double arrowX(Rect target, {required double cardLeft, required double cardRight, double margin = 28}) {
    final low = cardLeft + margin;
    final high = math.max(low, cardRight - margin);
    return target.center.dx.clamp(low, high);
  }

  /// Retângulo do recorte: o alvo com a folga, dentro da tela.
  static Rect hole(Rect target, Size screen, double padding) {
    final inflated = target.inflate(padding);
    return Rect.fromLTRB(
      math.max(0, inflated.left),
      math.max(0, inflated.top),
      math.min(screen.width, inflated.right),
      math.min(screen.height, inflated.bottom),
    );
  }

  /// O alvo aparece na tela (pelo menos um pedaço com tamanho).
  static bool isVisible(Rect target, Size screen) =>
      target.width > 0 &&
      target.height > 0 &&
      target.bottom > 0 &&
      target.right > 0 &&
      target.top < screen.height &&
      target.left < screen.width;
}
