import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';

/// Partidas de uma mesma liga, na ordem do site.
class LeagueGroup extends Equatable {
  final String league;
  final Uint8List? flag;
  final List<GlobalMatch> matches;

  const LeagueGroup({required this.league, required this.matches, this.flag});

  /// Agrupa mantendo a ordem em que cada liga aparece primeiro.
  static List<LeagueGroup> of(List<GlobalMatch> matches) {
    final byLeague = <String, List<GlobalMatch>>{};
    for (final match in matches) {
      byLeague.putIfAbsent(match.league, () => []).add(match);
    }
    return [
      for (final entry in byLeague.entries)
        LeagueGroup(league: entry.key, flag: entry.value.first.flag, matches: entry.value),
    ];
  }

  @override
  List<Object?> get props => [league, matches];
}
