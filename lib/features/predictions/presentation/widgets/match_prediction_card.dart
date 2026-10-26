import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/presentation/bloc/prediction_cubit.dart';
import 'package:arena_soccer/features/predictions/presentation/widgets/prediction_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Seção "Palpite" dos detalhes da partida: antes do jogo, o palpite da conta
/// com o botão de palpitar/alterar; durante, travado; depois, os pontos ganhos
/// e quantas pessoas palpitaram.
class MatchPredictionCard extends StatelessWidget {
  final MatchDTO match;
  final String? season;
  final String? homeCrest;
  final String? awayCrest;

  const MatchPredictionCard({super.key, required this.match, this.season, this.homeCrest, this.awayCrest});

  @override
  Widget build(BuildContext context) {
    final uid = context.select<SessionCubit, String>((cubit) => cubit.state.user?.id ?? '');
    return BlocProvider<PredictionCubit>(
      key: ValueKey('${match.id}_$uid'),
      create: (_) {
        final cubit = createPredictionCubit(matchId: match.id, uid: uid, season: season);
        if (!MatchCardStatus.of(match, DateTime.now()).upcoming) cubit.loadCount();
        return cubit;
      },
      child: _PredictionBody(match: match, season: season, homeCrest: homeCrest, awayCrest: awayCrest),
    );
  }
}

class _PredictionBody extends StatelessWidget {
  final MatchDTO match;
  final String? season;
  final String? homeCrest;
  final String? awayCrest;

  const _PredictionBody({required this.match, this.season, this.homeCrest, this.awayCrest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loggedIn = context.select<SessionCubit, bool>((cubit) => cubit.state.isAuthenticated);
    final status = MatchCardStatus.of(match, DateTime.now());
    final cubit = BlocProvider.of<PredictionCubit>(context);
    void openSheet() => showPredictionSheet(
          context,
          match: match,
          season: season,
          homeCrest: homeCrest,
          awayCrest: awayCrest,
          cubit: loggedIn ? cubit : null,
        );

    return BlocBuilder<PredictionCubit, PredictionState>(
      builder: (context, state) {
        final prediction = state.prediction;
        return ArenaCard(
          padding: const EdgeInsets.all(AppSizes.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.s12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.s6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppSizes.s10),
                      ),
                      child: const Icon(Icons.scoreboard_outlined, size: AppSizes.s18, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: AppSizes.s10),
                    Expanded(
                      child: Text(l10n.predictionSectionTitle,
                          style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                    ),
                    if (prediction?.scored == true) _PointsBadge(prediction: prediction!),
                  ],
                ),
              ),
              if (loggedIn && state.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.s12),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else ...[
                if (prediction != null) _Score(prediction: prediction),
                Text(
                  _message(l10n, status, prediction, loggedIn),
                  textAlign: TextAlign.center,
                  style: AppTypography.subtitle(),
                ),
                if (status.upcoming) ...[
                  const SizedBox(height: AppSizes.s12),
                  if (prediction == null)
                    ArenaButton.primary(title: l10n.predictionAction, function: openSheet)
                  else
                    ArenaButton.outlined(title: l10n.predictionEdit, function: openSheet),
                ],
                if (state.count != null) ...[
                  const SizedBox(height: AppSizes.s8),
                  Text(
                    l10n.predictionCount(state.count!),
                    textAlign: TextAlign.center,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  String _message(AppLocalizations l10n, MatchCardStatus status, PredictionDTO? prediction, bool loggedIn) {
    if (!loggedIn) return status.upcoming ? l10n.predictionLoginRequired : l10n.predictionLocked;
    if (status.upcoming) return prediction == null ? l10n.predictionNone : l10n.predictionDeadline;
    if (prediction == null) return l10n.predictionMissed;
    if (!prediction.scored) return status.finished ? l10n.predictionPending : l10n.predictionLocked;
    if (prediction.valid == false) return l10n.predictionLate;
    if (prediction.exact) return l10n.predictionExact;
    return (prediction.points ?? 0) > 0 ? l10n.predictionRules : l10n.predictionMiss;
  }
}

/// O placar palpitado em destaque.
class _Score extends StatelessWidget {
  final PredictionDTO prediction;

  const _Score({required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s6),
      child: Text(
        '${prediction.home} × ${prediction.away}',
        textAlign: TextAlign.center,
        style: AppTypography.display(color: AppColors.primaryDark),
      ),
    );
  }
}

/// "+7 pts" (dourado no placar exato, cinza quando não pontuou).
class _PointsBadge extends StatelessWidget {
  final PredictionDTO prediction;

  const _PointsBadge({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final points = prediction.points ?? 0;
    final color = prediction.exact
        ? AppColors.gold
        : points > 0
            ? AppColors.primary
            : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.s20)),
      child: Text(
        l10n.predictionPoints(points),
        style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
      ),
    );
  }
}
