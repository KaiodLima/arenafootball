import 'package:flutter/material.dart';

/// Paleta do app. Use sempre estes tokens, nunca `Colors.x` ou
/// `Color.fromARGB` direto nos widgets.
class AppColors {
  /// Verde principal (botões, barra inferior, destaques).
  static const Color primary = Color(0xFF4CAF50);

  /// Verde escuro do fundo das telas e da AppBar.
  static const Color primaryDark = Color.fromARGB(255, 27, 67, 28);

  /// Verde intermediário (cards e realces sobre o fundo escuro).
  static const Color primaryMedium = Color.fromARGB(255, 45, 94, 45);

  /// Verde forte (placar, ícones de ação).
  static const Color primaryStrong = Color.fromARGB(255, 4, 110, 7);

  /// Verde translúcido dos cards de time sobre o fundo escuro.
  static const Color primaryTranslucent = Color.fromRGBO(0, 255, 0, 0.25);

  /// Cores da marca do Google (logo do botão "Entrar com Google").
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleGreen = Color(0xFF34A853);

  static const Color white = Colors.white;
  static const Color whiteMuted = Colors.white24;
  static const Color whiteSoft = Colors.white70;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color grey = Color.fromARGB(255, 134, 143, 134);
  static const Color greyLight = Color(0xFFE0E0E0);

  /// Cinza-azulado das linhas alternadas da lista "todos os jogos"
  /// (`Colors.blueGrey[200]`).
  static const Color blueGreyLight = Color(0xFFB0BEC5);

  /// Fundo claro das áreas de conteúdo (folha da home, listas).
  static const Color background = Color(0xFFF3F6F3);

  /// Verde a 12%: indicador da barra inferior, cápsulas de ícone, item ativo.
  static const Color primarySoft = Color(0x1F4CAF50);

  /// Superfície dos cards e sheets.
  static const Color surface = Colors.white;

  /// Fundo dos campos preenchidos (telas de entrada).
  static const Color inputFill = Color(0xFFF1F5F1);

  /// Texto principal e secundário sobre superfícies claras.
  static const Color textPrimary = Color(0xFF14231A);
  static const Color textSecondary = Color(0xFF6B7A70);

  /// Sombra suave de cards elevados.
  static const Color shadow = Color(0x1F000000);

  static const Color success = primary;
  static const Color danger = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color gold = Color(0xFFFFC107);
  static const Color silver = Color(0xFFC4CCD4);
  static const Color bronze = Color(0xFFCD8B4E);
}
