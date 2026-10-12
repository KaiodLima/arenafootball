import 'package:flutter/material.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/utils/components/team_choice_selector.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Grade de escudos com seleção múltipla (toque marca/desmarca). Não rola
/// sozinha: fica dentro do scroll do formulário.
class TeamMultiSelectGrid extends StatelessWidget {
  final List<TeamDTO> teams;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const TeamMultiSelectGrid({super.key, required this.teams, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSizes.s10,
        crossAxisSpacing: AppSizes.s10,
        childAspectRatio: 0.82,
      ),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return TeamChoiceCard(
          team: team,
          selected: selected.contains(team.name),
          onTap: () => onToggle(team.name),
        );
      },
    );
  }
}
