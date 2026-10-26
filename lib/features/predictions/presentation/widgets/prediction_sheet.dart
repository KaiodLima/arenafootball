import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/predictions/presentation/bloc/prediction_cubit.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cubit do palpite de uma partida, já acompanhando o da conta logada.
PredictionCubit createPredictionCubit({required String matchId, required String uid, String? season}) =>
    PredictionCubit(sl(), sl(), sl())..watch(matchId: matchId, uid: uid, season: season);

/// Folha "Seu palpite": escudos, −/+ de cada lado e "Salvar palpite". Sem
/// conta, pede login. Reaproveita o [cubit] da tela de detalhes, se houver.
Future<void> showPredictionSheet(
  BuildContext context, {
  required MatchDTO match,
  String? season,
  String? homeCrest,
  String? awayCrest,
  PredictionCubit? cubit,
}) {
  final user = BlocProvider.of<SessionCubit>(context).state.user;
  final Widget sheet =
      user == null ? const _LoginPrompt() : _PredictionSheet(match: match, homeCrest: homeCrest, awayCrest: awayCrest);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => user == null
        ? sheet
        : cubit != null
            ? BlocProvider<PredictionCubit>.value(value: cubit, child: sheet)
            : BlocProvider<PredictionCubit>(
                create: (_) => createPredictionCubit(matchId: match.id, uid: user.id, season: season),
                child: sheet,
              ),
  );
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s24, 0, AppSizes.s24, AppSizes.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.scoreboard_outlined, size: AppSizes.s40, color: AppColors.primary),
          const SizedBox(height: AppSizes.s12),
          Text(l10n.predictionLoginRequired, textAlign: TextAlign.center, style: AppTypography.body()),
          const SizedBox(height: AppSizes.s16),
          ArenaButton.primary(
            title: l10n.predictionLogin,
            function: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.loginPage);
            },
          ),
        ],
      ),
    );
  }
}

class _PredictionSheet extends StatelessWidget {
  final MatchDTO match;
  final String? homeCrest;
  final String? awayCrest;

  const _PredictionSheet({required this.match, this.homeCrest, this.awayCrest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.read<SessionCubit>().state.user!;
    final cubit = BlocProvider.of<PredictionCubit>(context);
    final open = MatchCardStatus.of(match, DateTime.now()).upcoming;

    return BlocConsumer<PredictionCubit, PredictionState>(
      listenWhen: (a, b) => (b.saved && !a.saved) || (b.errorMessage != a.errorMessage && b.errorMessage != null),
      listener: (context, state) {
        if (state.saved) {
          Navigator.pop(context);
          showSnackBar(context: context, message: l10n.predictionSaved, isSuccess: true);
        } else {
          showSnackBar(context: context, message: state.errorMessage!, isSuccess: false);
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.predictionSheetTitle, textAlign: TextAlign.center, style: AppTypography.title()),
              const SizedBox(height: AppSizes.s4),
              Text(
                open ? l10n.predictionDeadline : l10n.predictionClosed,
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(color: open ? AppColors.textSecondary : AppColors.danger),
              ),
              const SizedBox(height: AppSizes.s20),
              if (state.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.s32),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SideStepper(
                        name: match.homeTeam,
                        crest: homeCrest,
                        goals: state.home,
                        enabled: open,
                        onChanged: cubit.changeHome,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.s80),
                      child: Text('×', style: AppTypography.title(color: AppColors.textSecondary)),
                    ),
                    Expanded(
                      child: _SideStepper(
                        name: match.awayTeam,
                        crest: awayCrest,
                        goals: state.away,
                        enabled: open,
                        onChanged: cubit.changeAway,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSizes.s16),
              Text(
                l10n.predictionRules,
                textAlign: TextAlign.center,
                style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
              ),
              const SizedBox(height: AppSizes.s16),
              ArenaButton.primary(
                title: l10n.predictionSave,
                isLoading: state.saving,
                function:
                    open && !state.loading && state.changed ? () => cubit.save(uid: user.id, name: user.name) : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Escudo, nome e o número de gols com − e +.
class _SideStepper extends StatelessWidget {
  final String name;
  final String? crest;
  final int goals;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _SideStepper({
    required this.name,
    required this.crest,
    required this.goals,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, int delta, bool active) => IconButton.filledTonal(
          onPressed: enabled && active ? () => onChanged(delta) : null,
          icon: Icon(icon),
          color: AppColors.primaryDark,
        );
    return Column(
      children: [
        TeamCrest(imageUrl: crest, size: AppSizes.s52),
        const SizedBox(height: AppSizes.s6),
        SizedBox(
          height: AppSizes.s36,
          child: Text(
            name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label().copyWith(fontSize: AppSizes.s12, height: 1.15),
          ),
        ),
        const SizedBox(height: AppSizes.s8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            button(Icons.remove_rounded, -1, goals > 0),
            SizedBox(
              width: AppSizes.s44,
              child: Text('$goals', textAlign: TextAlign.center, style: AppTypography.display()),
            ),
            button(Icons.add_rounded, 1, true),
          ],
        ),
      ],
    );
  }
}
