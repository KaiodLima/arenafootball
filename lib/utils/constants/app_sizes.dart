/// Escala de espaçamento e dimensões do projeto.
///
/// `sXX` = XX logical pixels. Use sempre estas constantes em padding,
/// margin, gap, tamanho de ícone e fontSize — nunca valor literal.
class AppSizes {
  static const double s1 = 1.0;
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s18 = 18.0;
  static const double s20 = 20.0;
  static const double s22 = 22.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0;
  static const double s30 = 30.0;
  static const double s32 = 32.0;
  static const double s36 = 36.0;
  static const double s40 = 40.0;
  static const double s47 = 47.0;
  static const double s48 = 48.0;
  static const double s50 = 50.0;
  static const double s52 = 52.0;
  static const double s56 = 56.0;
  static const double s60 = 60.0;
  static const double s64 = 64.0;
  static const double s80 = 80.0;
  static const double s100 = 100.0;
  static const double s110 = 110.0;
  static const double s120 = 120.0;
  static const double s150 = 150.0;
  static const double s200 = 200.0;
  static const double s250 = 250.0;

  // ---------------------------------------------------------------------
  // Aliases semânticos
  // ---------------------------------------------------------------------

  /// Gutter lateral padrão das telas.
  static const double screenPadding = s16;

  /// Raio do card das telas de entrada e dos bottom sheets.
  static const double radiusLarge = s28;

  /// Raio dos campos e botões das telas de entrada.
  static const double fieldRadius = s14;

  /// Altura dos botões principais das telas de entrada.
  static const double buttonHeightLarge = s52;

  /// Fração da altura da tela ocupada pelo hero do login.
  static const double heroHeightFactor = 0.38;

  /// Quanto o card das telas de entrada sobe sobre o hero.
  static const double cardOverlap = s24;

  /// Altura padrão de botão.
  static const double buttonHeight = s47;

  /// Raio padrão de botão e campo.
  static const double radius = s8;

  /// Raio da barra de navegação inferior (pílula).
  static const double bottomBarRadius = s30;

  /// Altura da barra de navegação inferior.
  static const double bottomBarHeight = s60;

  /// Altura do carrossel de destaques da home.
  static const double highlightsHeight = s200;

  /// Logo na AppBar.
  static const double logoWidth = s110;
  static const double logoHeight = s40;

  /// Logo grande da tela de login.
  static const double loginLogoHeight = s100;
}
