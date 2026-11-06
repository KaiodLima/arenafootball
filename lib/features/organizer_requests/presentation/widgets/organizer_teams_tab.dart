import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_tab.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_teams_cubit.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/team_card.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Aba Times do modo organizador: uma seção por campeonato da conta, com os
/// times inscritos (tocar abre o elenco).
class OrganizerTeamsTab extends StatelessWidget {
  final List<ChampionshipDTO> championships;

  const OrganizerTeamsTab({super.key, required this.championships});

  @override
  Widget build(BuildContext context) {
    final ordered = organizerTableChampionships(championships);
    return BlocProvider<OrganizerTeamsCubit>(
      create: (_) => OrganizerTeamsCubit(sl())..load(ordered),
      child: _OrganizerTeamsList(championships: ordered),
    );
  }
}

class _OrganizerTeamsList extends StatelessWidget {
  final List<ChampionshipDTO> championships;

  const _OrganizerTeamsList({required this.championships});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (championships.isEmpty) {
      return ArenaEmptyState(message: l10n.organizerNoChampionships, icon: Icons.emoji_events_outlined);
    }

    return BlocBuilder<OrganizerTeamsCubit, OrganizerTeamsState>(
      builder: (context, state) {
        if (state.loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (state.error) return ArenaEmptyState.error(message: l10n.teamsLoadError);

        return ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s100),
          children: [
            for (final championship in championships) ...[
              SectionHeader(
                title: championship.title,
                trailing: championship.season.isEmpty
                    ? null
                    : Text(championship.season, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ),
              ..._teams(context, state.teamsByChampionship[championship.id] ?? const [], l10n),
              const SizedBox(height: AppSizes.s16),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _teams(BuildContext context, List<TeamDTO> teams, AppLocalizations l10n) {
    if (teams.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
          child: Text(l10n.organizerTeamsEmpty, style: AppTypography.subtitle()),
        ),
      ];
    }
    return [
      for (final team in teams) TeamCard(team: team, onTap: () => openTeamRoster(context, {'team': team})),
    ];
  }
}
