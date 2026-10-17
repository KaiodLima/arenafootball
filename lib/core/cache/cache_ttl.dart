/// Validade de cada dado no cache local. Dentro dela o app mostra o cache e
/// não lê o Firestore; vencido, mostra o cache e revalida.
abstract final class CacheTtl {
  static const Duration regions = Duration(hours: 24);
  static const Duration seasonsConfig = Duration(hours: 24);
  static const Duration teams = Duration(minutes: 30);
  static const Duration championships = Duration(minutes: 30);
  static const Duration groups = Duration(minutes: 30);
  static const Duration standings = Duration(minutes: 30);
  static const Duration highlights = Duration(minutes: 15);
  static const Duration ranking = Duration(minutes: 10);

  /// Ranking de torcidas (o servidor recalcula de hora em hora).
  static const Duration fanRanking = Duration(minutes: 30);
  static const Duration globalResults = Duration(minutes: 5);

  /// Apuração de votação encerrada (lida só depois de fechar).
  static const Duration votes = Duration(minutes: 1);

  /// Sempre revalida (o cache só abre o app sem rede).
  static const Duration alwaysRevalidate = Duration.zero;
}
