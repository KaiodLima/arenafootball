import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_ranking_widgets.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "+10" / "−3" / "0" (pontos com sinal).
String fantasySignedPoints(double points) => points > 0 ? '+${fantasyPointsLabel(points)}' : fantasyPointsLabel(points);

/// Folha "Pontuação detalhada" do atleta na rodada: cada regra com os
/// pontos, o total individual, o capitão multiplicado e os motivos (por que
/// não pontuou / observações). Uma leitura (`rodadas/{n}/atletas/{id}`).
/// [load]: só para teste (padrão: o use case do DI).
Future<void> showFantasyAthleteScore(
  BuildContext context, {
  required String fantasyId,
  required int round,
  required String athleteId,
  bool captain = false,
  FantasyAthleteDTO? athlete,
  Future<Either<Failure, FantasyAthleteScoreDTO?>> Function()? load,
}) {
  final future = load?.call() ?? sl<GetFantasyAthleteScoreUseCase>()(fantasyId, round, athleteId);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: FutureBuilder<Either<Failure, FantasyAthleteScoreDTO?>>(
          future: future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.s32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final score = snapshot.data!.fold((_) => null, (s) => s);
            return FantasyScoreView(score: score, captain: captain, athlete: athlete, round: round);
          },
        ),
      ),
    ),
  );
}

/// Conteúdo da folha (separado para teste).
class FantasyScoreView extends StatelessWidget {
  final FantasyAthleteScoreDTO? score;
  final bool captain;
  final FantasyAthleteDTO? athlete;
  final int round;

  const FantasyScoreView({super.key, required this.score, required this.captain, this.athlete, required this.round});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = score;
    final name = (s?.name.isNotEmpty ?? false) ? s!.name : (athlete?.name ?? l10n.fantasyUnknownAthlete);
    final photo = (s?.photoUrl.isNotEmpty ?? false) ? s!.photoUrl : (athlete?.photoUrl ?? '');
    final team = (s?.team.isNotEmpty ?? false) ? s!.team : (athlete?.team ?? '');
    final position = s?.position == null ? '' : fantasyPositionLabelOfKey(l10n, s!.position!);
    Widget row(String label, String value, {Color? color, bool bold = false, Key? key}) => Padding(
          key: key,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.label(color: AppColors.textPrimary)
                      .copyWith(fontSize: AppSizes.s14, fontWeight: bold ? FontWeight.w800 : null),
                ),
              ),
              Text(
                value,
                style: AppTypography.label(color: color ?? AppColors.textPrimary)
                    .copyWith(fontSize: bold ? AppSizes.s18 : AppSizes.s14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20),
      children: [
        Row(
          children: [
            FantasyAvatar(name: name, photoUrl: photo, size: AppSizes.s48),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                  Text(
                    [l10n.fantasyRoundTitle(round), if (position.isNotEmpty) position, if (team.isNotEmpty) team]
                        .join(' · '),
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.s12),
        if (s == null)
          Text(l10n.fantasyAwaitingScore,
              key: const ValueKey('fantasy-score-awaiting'), style: AppTypography.subtitle())
        else ...[
          if (s.minutes > 0)
            Text(
              s.matches.any((m) => m.estimated)
                  ? l10n.fantasyMinutesEstimated(s.minutes)
                  : l10n.fantasyMinutesPlayed(s.minutes),
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
            ),
          const Divider(),
          for (final item in s.groupedItems)
            row(
              item.qty > 1 ? '${fantasyRuleLabel(l10n, item.rule)} (${item.qty}×)' : fantasyRuleLabel(l10n, item.rule),
              fantasySignedPoints(item.points),
              color: item.points > 0
                  ? AppColors.primaryStrong
                  : item.points < 0
                      ? AppColors.danger
                      : AppColors.textSecondary,
              key: ValueKey('fantasy-score-${item.rule}'),
            ),
          const Divider(),
          row(l10n.fantasyScoreTotal, fantasyPointsLabel(s.total),
              bold: true, key: const ValueKey('fantasy-score-total')),
          if (captain) ...[
            row(
              l10n.fantasyScoreCaptain(FantasySettings.captainLabel(s.captain)),
              fantasyPointsLabel(((s.total * s.captain) * 100).round() / 100),
              color: AppColors.medalGoldDark,
              bold: true,
              key: const ValueKey('fantasy-score-captain'),
            ),
          ],
          if (s.reasons.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s12),
            Text(l10n.fantasyScoreNotes, style: AppTypography.title().copyWith(fontSize: AppSizes.s14)),
            const SizedBox(height: AppSizes.s4),
            for (final reason in s.reasons)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.s4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: AppSizes.s16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSizes.s6),
                    Expanded(
                      child: Text(
                        fantasyReasonLabel(l10n, reason, s),
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ],
    );
  }
}
