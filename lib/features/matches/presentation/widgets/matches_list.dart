import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_state.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/edit_score_dialog.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Lista de partidas do [MatchesCubit] do contexto (usada pela aba de
/// tabelas, com as partidas do dia, e pela tela "todos os jogos").
class MatchesList extends StatelessWidget {
  /// Temporada da lista: as telas de votação leem os jogadores dela.
  final String season;

  /// Conteúdo antes dos cards (ex.: atalhos e título da seção na aba de tabelas).
  final Widget? header;

  const MatchesList({super.key, required this.season, this.header});

  void _openVoting(BuildContext context, MatchDTO match) {
    Navigator.pushNamed(
      context,
      match.isVotingOpen ? AppRoutes.voteBestPlayerPage : AppRoutes.electedPlayerPage,
      arguments: {'match': match, 'season': season},
    );
  }

  Future<void> _editScore(BuildContext context, MatchDTO match) async {
    final cubit = BlocProvider.of<MatchesCubit>(context);
    final score = await showEditScoreDialog(context);
    if (score != null) await cubit.updateScore(match, homeGoals: score.homeGoals, awayGoals: score.awayGoals);
  }

  Future<void> _confirmDelete(BuildContext context, MatchDTO match) async {
    final cubit = BlocProvider.of<MatchesCubit>(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(
          l10n.matchesDeleteConfirm,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: AppSizes.s20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ArenaButton.outlined(
                  title: l10n.commonCancel,
                  function: () => Navigator.pop(dialogContext, false),
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: ArenaButton.primary(
                  title: l10n.commonDelete,
                  function: () => Navigator.pop(dialogContext, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.delete(match);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = context.watch<SessionCubit>().state.isAdmin;

    return BlocConsumer<MatchesCubit, MatchesState>(
      listener: (context, state) {
        // Com a lista vazia o erro já aparece na tela; aqui só o de ação.
        if (state is ErrorMatchesState && state.matches.isNotEmpty) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final Widget? placeholder;
        if (state is LoadingMatchesState && state.matches.isEmpty) {
          placeholder = const Padding(
            padding: EdgeInsets.only(top: AppSizes.s48),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        } else if (state is ErrorMatchesState && state.matches.isEmpty) {
          placeholder = ArenaEmptyState.error(message: l10n.matchesLoadError);
        } else if (state.matches.isEmpty) {
          placeholder = ArenaEmptyState(message: l10n.matchesEmpty, icon: Icons.sports_soccer_outlined);
        } else {
          placeholder = null;
        }

        return ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s100),
          children: [
            if (header != null) header!,
            if (placeholder != null)
              placeholder
            else
              for (final match in state.matches)
                MatchCard(
                  match: match,
                  isAdmin: isAdmin,
                  onVotingTap: () => _openVoting(context, match),
                  onToggleVoting: () => BlocProvider.of<MatchesCubit>(context).toggleVoting(match),
                  onEditScore: () => _editScore(context, match),
                  onDelete: () => _confirmDelete(context, match),
                ),
          ],
        );
      },
    );
  }
}
