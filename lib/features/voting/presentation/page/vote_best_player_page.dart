import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/voting/domain/usecases/cast_vote_usecase.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_cubit.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Votação de melhor jogador da partida: elencos do mandante (esquerda) e do
/// visitante (direita). O voto usa o uid do usuário logado; convidado não vota.
class VoteBestPlayerPage extends StatefulWidget {
  final MatchDTO match;
  final String season;

  const VoteBestPlayerPage({super.key, required this.match, required this.season});

  @override
  State<VoteBestPlayerPage> createState() => _VoteBestPlayerPageState();
}

class _VoteBestPlayerPageState extends State<VoteBestPlayerPage> {
  late final VoteBestPlayerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<VoteBestPlayerCubit>(context);
    _cubit.watch(homeTeam: widget.match.homeTeam, awayTeam: widget.match.awayTeam, season: widget.season);
  }

  void _vote() {
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    _cubit.vote(voterId: user?.id ?? '');
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
    final title = widget.match.votingTitle.isNotEmpty ? widget.match.votingTitle : l10n.votingTitle;

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
      body: BlocConsumer<VoteBestPlayerCubit, VoteBestPlayerState>(
        listener: (context, state) {
          if (state is SuccessVoteBestPlayerState) {
            showSnackBar(context: context, message: l10n.votingVoteRegistered(state.selected?.name ?? ''));
          }
          if (state is ErrorVoteBestPlayerState) {
            showSnackBar(context: context, message: _errorText(state, l10n), isSuccess: false);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.s12),
                child: Text(
                  l10n.votingNotice,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: AppSizes.s18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: state is LoadingVoteBestPlayerState
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _PlayersColumn(players: state.homePlayers, state: state)),
                          const SizedBox(width: AppSizes.s8),
                          Expanded(
                            child: _PlayersColumn(players: state.awayPlayers, state: state, alignEnd: true),
                          ),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.s4),
                child: ArenaButton.primary(
                  title: l10n.votingVoteButton,
                  isLoading: state is SubmittingVoteBestPlayerState,
                  function: _vote,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayersColumn extends StatelessWidget {
  final List<PlayerDTO> players;
  final VoteBestPlayerState state;
  final bool alignEnd;

  const _PlayersColumn({required this.players, required this.state, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<VoteBestPlayerCubit>(context);
    final align = alignEnd ? TextAlign.end : TextAlign.start;

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.s8),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Card(
          child: ListTile(
            selected: state.isSelected(player),
            selectedColor: AppColors.white,
            selectedTileColor: AppColors.primary,
            onTap: () => cubit.select(player),
            title: Text(
              player.name,
              textAlign: align,
              style: const TextStyle(fontSize: AppSizes.s18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(player.team, textAlign: align),
          ),
        );
      },
    );
  }
}
