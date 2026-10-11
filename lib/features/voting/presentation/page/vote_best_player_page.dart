import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/page_title_bar.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/voting/domain/usecases/cast_vote_usecase.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_cubit.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_state.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/match_score_header.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/vote_action_bar.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/vote_player_tile.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/vote_success_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/arena_segmented_pill.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Votação de melhor jogador da partida: o placar no topo escuro, um seletor
/// para alternar os elencos, busca e a lista com seleção; a barra fixa
/// embaixo envia o voto. O voto usa o uid do usuário logado: convidado vê os
/// elencos e o convite para entrar. Quem já votou vê o voto atual marcado.
class VoteBestPlayerPage extends StatefulWidget {
  final MatchDTO match;
  final String season;

  const VoteBestPlayerPage({super.key, required this.match, required this.season});

  @override
  State<VoteBestPlayerPage> createState() => _VoteBestPlayerPageState();
}

class _VoteBestPlayerPageState extends State<VoteBestPlayerPage> {
  late final VoteBestPlayerCubit _cubit;

  String get _voterId => BlocProvider.of<SessionCubit>(context).state.user?.id ?? '';

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<VoteBestPlayerCubit>(context);
    _cubit.watch(
      homeTeam: widget.match.homeTeam,
      awayTeam: widget.match.awayTeam,
      season: widget.season,
      voterId: _voterId,
    );
  }

  String _errorText(ErrorVoteBestPlayerState state, AppLocalizations l10n) {
    switch (state.errorCode) {
      case CastVoteUseCase.loginRequiredCode:
        return l10n.votingLoginRequired;
      case CastVoteUseCase.blankVoteCode:
        return l10n.votingBlankVote;
      default:
        return state.errorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isGuest = !context.watch<SessionCubit>().state.isAuthenticated;
    final match = widget.match;
    final title = match.votingTitle.isNotEmpty ? match.votingTitle : l10n.votingTitle;

    return BlocConsumer<VoteBestPlayerCubit, VoteBestPlayerState>(
      listener: (context, state) {
        if (state is SuccessVoteBestPlayerState && state.selected != null) {
          VoteSuccessSheet.show(context, state.selected!);
        }
        if (state is ErrorVoteBestPlayerState) {
          showSnackBar(context: context, message: _errorText(state, l10n), isSuccess: false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: PageTitleBar(title: title, subtitle: l10n.votingMatchSubtitle(match.homeTeam, match.awayTeam)),
          bottomNavigationBar: VoteActionBar(
            state: state,
            isGuest: isGuest,
            onVote: () => _cubit.vote(voterId: _voterId),
            onLogin: () => Navigator.pushNamed(context, AppRoutes.loginPage),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(child: _Header(match: match, state: state, onTeamChanged: _cubit.setShowAway)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s4, AppSizes.s16, AppSizes.s12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: AppSizes.s16, color: AppColors.textSecondary),
                          const SizedBox(width: AppSizes.s6),
                          Expanded(
                            child: Text(
                              l10n.votingHint,
                              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                            ),
                          ),
                        ],
                      ),
                      if (state.currentSquad.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.s12),
                        // A chave zera o campo ao trocar de time (a busca também é zerada).
                        ArenaSearchField(
                          key: ValueKey(state.showAway),
                          hint: l10n.votingSearchHint,
                          onChanged: _cubit.setQuery,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              ..._players(l10n, state, isGuest),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _players(AppLocalizations l10n, VoteBestPlayerState state, bool isGuest) {
    Widget fill(Widget child) => SliverFillRemaining(hasScrollBody: false, child: child);

    if (state is LoadingVoteBestPlayerState && state.homePlayers.isEmpty && state.awayPlayers.isEmpty) {
      return [fill(const Center(child: CircularProgressIndicator(color: AppColors.primary)))];
    }
    if (state.currentSquad.isEmpty) {
      return [fill(ArenaEmptyState(message: l10n.votingEmptySquad, icon: Icons.groups_outlined))];
    }
    final players = state.visiblePlayers;
    if (players.isEmpty) {
      return [fill(ArenaEmptyState(message: l10n.votingNoSearchResults, icon: Icons.search_off_rounded))];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s24),
        sliver: SliverList.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return VotePlayerTile(
              player: player,
              selected: !isGuest && state.isSelected(player),
              isMyVote: state.isMyVote(player),
              onTap: isGuest ? null : () => _cubit.select(player),
            );
          },
        ),
      ),
    ];
  }
}

/// Topo escuro: placar, seletor de elenco e a borda arredondada da folha
/// clara que vem embaixo.
class _Header extends StatelessWidget {
  final MatchDTO match;
  final VoteBestPlayerState state;
  final ValueChanged<bool> onTeamChanged;

  const _Header({required this.match, required this.state, required this.onTeamChanged});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primaryDark,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, AppSizes.s20),
            child: MatchScoreHeader(match: match, homeCrest: state.homeCrest, awayCrest: state.awayCrest),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
            child: ArenaSegmentedPill(
              segments: [
                ArenaSegment(
                  label: match.homeTeam,
                  leading: TeamCrest(imageUrl: state.homeCrest, size: AppSizes.s24),
                ),
                ArenaSegment(
                  label: match.awayTeam,
                  leading: TeamCrest(imageUrl: state.awayCrest, size: AppSizes.s24),
                ),
              ],
              selectedIndex: state.showAway ? 1 : 0,
              onChanged: (index) => onTeamChanged(index == 1),
            ),
          ),
          const SizedBox(height: AppSizes.s20),
          Container(
            height: AppSizes.sheetOverlap,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
            ),
          ),
        ],
      ),
    );
  }
}
