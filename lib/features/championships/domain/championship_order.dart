import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';

/// Carrossel de destaque da aba Campeonatos: as competições da temporada
/// [season], as em andamento primeiro (a mais recente na frente) e as
/// encerradas no fim (a encerrada mais recentemente primeiro). Sem nenhuma
/// na temporada, a mais recente de todas (temporada maior); lista vazia = vazia.
List<ChampionshipDTO> featuredChampionships(List<ChampionshipDTO> championships, String season) {
  if (championships.isEmpty) return const [];
  final ofSeason = championships.where((c) => c.season == season).toList();
  if (ofSeason.isEmpty) {
    final sorted = [...championships]..sort((a, b) => b.season.compareTo(a.season));
    return [sorted.first];
  }
  int newest(ChampionshipDTO a, ChampionshipDTO b) => b.championshipId.compareTo(a.championshipId);
  final open = ofSeason.where((c) => c.isOpen).toList()..sort(newest);
  final closed = ofSeason.where((c) => !c.isOpen).toList()
    ..sort((a, b) {
      final ca = a.closedAt;
      final cb = b.closedAt;
      if (ca != null && cb != null && ca != cb) return cb.compareTo(ca);
      if (ca != null && cb == null) return -1;
      if (ca == null && cb != null) return 1;
      return newest(a, b);
    });
  return [...open, ...closed];
}
