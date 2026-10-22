import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/page_title_bar.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/elected_player_cubit.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/elected_player_state.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/elected_player_card.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/voting_no_winner_card.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/match_mvp_share_card.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/match_score_header.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/vote_ranking_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/share_image_frame.dart';
import 'package:arena_soccer/utils/components/share_image_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Craque da partida (votação encerrada): o placar no topo escuro, o cartão
/// do eleito sobreposto a ele e o ranking de todos os votados. Sem votos, o
/// placar continua e embaixo aparece o aviso.
class ElectedPlayerPage extends StatefulWidget {
  final MatchDTO match;
  final String season;

  const ElectedPlayerPage({super.key, required this.match, required this.season});

  @override
  State<ElectedPlayerPage> createState() => _ElectedPlayerPageState();
}

class _ElectedPlayerPageState extends State<ElectedPlayerPage> {
  /// Quanto o cartão do eleito sobe sobre o topo escuro.
  static const double _overlap = AppSizes.s48;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ElectedPlayerCubit>(context).load(match: widget.match, season: widget.season);
  }

  /// Card com o placar, o eleito, o percentual de votos e os mais votados (o
  /// texto vira a legenda).
  void _share(AppLocalizations l10n, VotingResult result, ElectedPlayer elected) {
    final match = widget.match;
    final slug = '${match.homeTeam}_${match.awayTeam}'.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    showShareImageSheet(
      context,
      title: l10n.votingShareTitle,
      fileName: 'craque_$slug',
      preview: ShareImageFrame(date: DateTime.now(), card: MatchMvpShareCard(match: match, result: result)),
      shareText: '${l10n.votingShareText(
        elected.playerName,
        '${match.homeTeam} ${match.homeGoals} x ${match.awayGoals} ${match.awayTeam}',
        l10n.votingVotes(elected.votes),
      )}\n$appLink',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ElectedPlayerCubit, ElectedPlayerState>(
      builder: (context, state) {
        final result = state.result;
        final elected = result?.elected;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: PageTitleBar(
            title: l10n.votingElectedTitle,
            subtitle: l10n.votingMatchSubtitle(widget.match.homeTeam, widget.match.awayTeam),
            actions: [
              if (result != null && elected != null)
                IconButton(
                  tooltip: l10n.newsShare,
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => _share(l10n, result, elected),
                ),
            ],
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: ColoredBox(
                  color: AppColors.primaryDark,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.s16,
                      AppSizes.s8,
                      AppSizes.s16,
                      elected != null ? AppSizes.s24 : AppSizes.s28,
                    ),
                    child: MatchScoreHeader(
                      match: widget.match,
                      homeCrest: result?.homeCrest,
                      awayCrest: result?.awayCrest,
                    ),
                  ),
                ),
              ),
              ..._body(l10n, state),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _body(AppLocalizations l10n, ElectedPlayerState state) {
    Widget fill(Widget child) => SliverFillRemaining(hasScrollBody: false, child: child);

    if (state is LoadingElectedPlayerState) {
      return [fill(const Center(child: CircularProgressIndicator(color: AppColors.primary)))];
    }
    final result = state.result;
    if (state is ErrorElectedPlayerState || result == null) {
      return [fill(ArenaEmptyState.error(message: l10n.votingLoadError))];
    }
    final elected = result.elected;
    if (result.ranking.isEmpty) {
      return [fill(ArenaEmptyState(message: l10n.votingNoVotesYet, icon: Icons.how_to_vote_outlined))];
    }

    return [
      SliverToBoxAdapter(
        child: Stack(
          children: [
            // Faixa escura atrás do topo do cartão, para ele "subir" no placar.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _overlap,
              child: ColoredBox(color: AppColors.primaryDark),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
              // Filho não posicionado do Stack recebe restrição frouxa: força a largura toda.
              child: SizedBox(
                width: double.infinity,
                // Sem eleito (regras não atingidas): o motivo no lugar do cartão.
                child: elected != null
                    ? ElectedPlayerCard(elected: elected, share: result.shareOf(elected.votes))
                    : VotingNoWinnerCard(outcome: result.outcome),
              ),
            ),
          ],
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s24, AppSizes.s16, AppSizes.s32),
        sliver: SliverList.list(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.s4, bottom: AppSizes.s10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(l10n.votingRankingTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                  const SizedBox(width: AppSizes.s8),
                  Text(
                    l10n.votingVotes(result.totalVotes),
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ),
            ),
            VoteRankingCard(result: result),
          ],
        ),
      ),
    ];
  }
}
