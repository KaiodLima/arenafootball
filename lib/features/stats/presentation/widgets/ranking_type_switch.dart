import 'package:flutter/material.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_segmented_pill.dart';

/// Seletor em pílula Gols | Assistências, para fundo escuro.
class RankingTypeSwitch extends StatelessWidget {
  final StatsRankingType selected;
  final ValueChanged<StatsRankingType> onChanged;

  const RankingTypeSwitch({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaSegmentedPill(
      segments: [
        ArenaSegment(label: l10n.matchesTopScorers, icon: Icons.sports_soccer_rounded),
        ArenaSegment(label: l10n.matchesAssists, icon: Icons.assistant_rounded),
      ],
      selectedIndex: StatsRankingType.values.indexOf(selected),
      onChanged: (index) => onChanged(StatsRankingType.values[index]),
    );
  }
}
