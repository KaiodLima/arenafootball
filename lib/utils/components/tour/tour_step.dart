import 'package:flutter/material.dart';

/// Formato do recorte em volta do alvo.
enum TourShape { roundedRect, circle }

/// Um passo do tour: o elemento real da tela ([target]) fica em destaque e o
/// cartão explica em poucas palavras.
class TourStep {
  final GlobalKey target;
  final IconData icon;
  final String title;
  final String body;
  final TourShape shape;

  /// Folga em volta do alvo.
  final double padding;

  const TourStep({
    required this.target,
    required this.icon,
    required this.title,
    required this.body,
    this.shape = TourShape.roundedRect,
    this.padding = 8,
  });
}
