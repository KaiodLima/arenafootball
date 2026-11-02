import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Lista de times com escudo e busca; devolve o time escolhido. O marcado é
/// o de [selectedId] (ou, sem id, o de nome [selected]). Com times de mais de
/// uma região, a lista vem agrupada por região ([firstRegion] primeiro).
Future<TeamDTO?> showTeamPickerSheet(
  BuildContext context, {
  required String title,
  required List<TeamDTO> teams,
  String? selected,
  String selectedId = '',
  String firstRegion = '',
}) {
  return showModalBottomSheet<TeamDTO>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TeamPicker(
      title: title,
      teams: teams,
      selected: selected,
      selectedId: selectedId,
      firstRegion: firstRegion,
    ),
  );
}

/// Times agrupados por região: [firstRegion] primeiro, as demais em ordem
/// alfabética (sem acento) e os sem região ('') no fim; times em ordem
/// alfabética dentro do grupo.
List<({String region, List<TeamDTO> teams})> groupTeamsByRegion(List<TeamDTO> teams, {String firstRegion = ''}) {
  int byName(String a, String b) => foldForSearch(a).compareTo(foldForSearch(b));
  final groups = <String, List<TeamDTO>>{};
  for (final team in teams) {
    groups.putIfAbsent(team.region.trim(), () => []).add(team);
  }
  final first = firstRegion.trim();
  final regions = groups.keys.toList()
    ..sort((a, b) {
      if (a == b) return 0;
      // Sem região: sempre no fim.
      if (a.isEmpty) return 1;
      if (b.isEmpty) return -1;
      if (a == first) return -1;
      if (b == first) return 1;
      return byName(a, b);
    });
  return [
    for (final region in regions) (region: region, teams: groups[region]!..sort((a, b) => byName(a.name, b.name))),
  ];
}

class _TeamPicker extends StatefulWidget {
  final String title;
  final List<TeamDTO> teams;
  final String? selected;
  final String selectedId;
  final String firstRegion;

  const _TeamPicker({
    required this.title,
    required this.teams,
    required this.selected,
    this.selectedId = '',
    this.firstRegion = '',
  });

  @override
  State<_TeamPicker> createState() => _TeamPickerState();
}

class _TeamPickerState extends State<_TeamPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final term = foldForSearch(_query.trim());
    // Times de mais de uma região (amistoso, intermunicipal): agrupados por
    // região, que também entra na busca.
    final showRegion = widget.teams.map((t) => t.region.trim()).where((r) => r.isNotEmpty).toSet().length > 1;
    final teams = widget.teams
        .where((t) =>
            term.isEmpty ||
            foldForSearch(t.name).contains(term) ||
            (showRegion && foldForSearch(t.region).contains(term)))
        .toList();
    final groups = groupTeamsByRegion(teams, firstRegion: widget.firstRegion);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s12),
              child: Text(widget.title, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
              child: ArenaSearchField(hint: l10n.goalSearchTeam, onChanged: (v) => setState(() => _query = v)),
            ),
            const SizedBox(height: AppSizes.s8),
            Expanded(
              child: teams.isEmpty
                  ? ArenaEmptyState(message: l10n.goalNoTeams, icon: Icons.shield_outlined)
                  : CustomScrollView(
                      slivers: [
                        for (final group in groups)
                          SliverMainAxisGroup(
                            slivers: [
                              if (showRegion)
                                PinnedHeaderSliver(
                                  child: _RegionHeader(
                                    region: group.region.isEmpty ? l10n.teamPickerOtherRegion : group.region,
                                    count: group.teams.length,
                                  ),
                                ),
                              SliverList.builder(
                                itemCount: group.teams.length,
                                itemBuilder: (context, index) => _teamTile(context, group.teams[index]),
                              ),
                            ],
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.s16)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamTile(BuildContext context, TeamDTO team) {
    final selected = sameTeam(idA: team.id, nameA: team.name, idB: widget.selectedId, nameB: widget.selected ?? '');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
      leading: TeamCrest(imageUrl: team.imageUrl, size: AppSizes.s40),
      title: Text(
        team.name,
        style: AppTypography.body().copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
      ),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      onTap: () => Navigator.pop(context, team),
    );
  }
}

/// Cabeçalho fixo do grupo: 📍 região · quantidade.
class _RegionHeader extends StatelessWidget {
  final String region;
  final int count;

  const _RegionHeader({required this.region, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySoft,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20, vertical: AppSizes.s8),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: AppColors.primaryDark, size: AppSizes.s16),
          const SizedBox(width: AppSizes.s6),
          Expanded(
            child: Text(
              region,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s14),
            ),
          ),
          Text('$count', style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
