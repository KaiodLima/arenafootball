import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/seasons/domain/team_links.dart';
import 'package:arena_soccer/features/seasons/presentation/bloc/team_links_cubit.dart';
import 'package:arena_soccer/features/seasons/presentation/bloc/team_links_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Manutenção do admin: escolhe a temporada, roda "Vincular times por id" e
/// mostra o relatório (o que foi atualizado e os nomes que não deu para
/// vincular).
class TeamLinksSection extends StatefulWidget {
  final List<String> seasons;
  final String current;

  const TeamLinksSection({super.key, required this.seasons, required this.current});

  @override
  State<TeamLinksSection> createState() => _TeamLinksSectionState();
}

class _TeamLinksSectionState extends State<TeamLinksSection> {
  late String _season = widget.current;

  String _label(AppLocalizations l10n, TeamLinkTarget target) => switch (target) {
        TeamLinkTarget.players => l10n.teamLinksPlayers,
        TeamLinkTarget.matches => l10n.teamLinksMatches,
        TeamLinkTarget.groups => l10n.teamLinksGroups,
        TeamLinkTarget.championships => l10n.teamLinksChampionships,
        TeamLinkTarget.playerRequests => l10n.teamLinksPlayerRequests,
        TeamLinkTarget.goalCards => l10n.teamLinksGoalCards,
        TeamLinkTarget.users => l10n.teamLinksUsers,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<TeamLinksCubit, TeamLinksState>(
      listenWhen: (previous, current) => current.errorMessage != null && previous.errorMessage != current.errorMessage,
      listener: (context, state) => showSnackBar(context: context, message: state.errorMessage!, isSuccess: false),
      builder: (context, state) {
        final report = state.report;
        return Container(
          padding: const EdgeInsets.all(AppSizes.s16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.link_rounded, color: AppColors.primary),
                  const SizedBox(width: AppSizes.s8),
                  Expanded(
                    child: Text(l10n.teamLinksTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.s6),
              Text(l10n.teamLinksInfo, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              const SizedBox(height: AppSizes.s12),
              Wrap(
                spacing: AppSizes.s8,
                runSpacing: AppSizes.s8,
                children: [
                  for (final season in widget.seasons.reversed)
                    ArenaChoiceChip(
                      label: season,
                      selected: season == _season,
                      onTap: state.running ? () {} : () => setState(() => _season = season),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.s12),
              ArenaButton.outlined(
                title: l10n.teamLinksRun(_season),
                isLoading: state.running,
                function: state.running ? null : () => BlocProvider.of<TeamLinksCubit>(context).run(_season),
              ),
              if (report != null) ...[
                const Divider(height: AppSizes.s28),
                Text(
                  l10n.teamLinksDone(state.reportSeason ?? '', report.totalUpdated),
                  style: AppTypography.label(color: AppColors.textPrimary),
                ),
                for (final entry in report.updated.entries)
                  _ReportLine(text: '${_label(l10n, entry.key)}: ${entry.value}'),
                if (report.votesCopied > 0) _ReportLine(text: l10n.teamLinksVotes(report.votesCopied)),
                if (report.unmatched.isNotEmpty) _NameList(title: l10n.teamLinksUnmatched, names: report.unmatched),
                if (report.ambiguous.isNotEmpty) _NameList(title: l10n.teamLinksAmbiguous, names: report.ambiguous),
                if (report.skippedVotes.isNotEmpty)
                  _NameList(title: l10n.teamLinksSkippedVotes, names: report.skippedVotes),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ReportLine extends StatelessWidget {
  final String text;

  const _ReportLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s4),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, size: AppSizes.s16, color: AppColors.primary),
          const SizedBox(width: AppSizes.s6),
          Expanded(child: Text(text, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12))),
        ],
      ),
    );
  }
}

/// Lista de nomes de atenção (o admin corrige e roda de novo).
class _NameList extends StatelessWidget {
  final String title;
  final List<String> names;

  const _NameList({required this.title, required this.names});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: AppSizes.s16, color: AppColors.danger),
              const SizedBox(width: AppSizes.s6),
              Expanded(
                child: Text(title,
                    style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s4),
          Text(names.join(' · '), style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
