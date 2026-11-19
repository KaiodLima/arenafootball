/// Conteúdo de teste do admin (partida `teste: true` e os cards dela): só a
/// conta admin vê. Configurado pelo `SessionCubit` a cada mudança de sessão
/// (padrão do `SeasonCollection.configure`); os data sources e o feed filtram
/// por aqui, sem precisar receber a sessão.
abstract final class TestContent {
  static bool _visible = false;

  /// A conta da sessão é admin (de verdade: também no modo jogador).
  static bool get visible => _visible;

  static void configure({required bool visible}) => _visible = visible;

  /// O item [isTest] aparece para a sessão atual.
  static bool allows(bool isTest) => !isTest || _visible;
}
