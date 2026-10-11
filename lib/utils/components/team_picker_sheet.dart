import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Lista de times com escudo e busca; devolve o nome escolhido.
Future<String?> showTeamPickerSheet(
  BuildContext context, {
  required String title,
  required List<TeamDTO> teams,
  String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TeamPicker(title: title, teams: teams, selected: selected),
  );
}

class _TeamPicker extends StatefulWidget {
  final String title;
  final List<TeamDTO> teams;
  final String? selected;

  const _TeamPicker({required this.title, required this.teams, required this.selected});

  @override
  State<_TeamPicker> createState() => _TeamPickerState();
}

class _TeamPickerState extends State<_TeamPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final term = foldForSearch(_query.trim());
    final teams = widget.teams.where((t) => term.isEmpty || foldForSearch(t.name).contains(term)).toList();
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
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: AppSizes.s16),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final selected = team.name == widget.selected;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
                          leading: TeamCrest(imageUrl: team.imageUrl, size: AppSizes.s40),
                          title: Text(
                            team.name,
                            style: AppTypography.body().copyWith(
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                          onTap: () => Navigator.pop(context, team.name),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
