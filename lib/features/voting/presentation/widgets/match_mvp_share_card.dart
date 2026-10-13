import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card do craque da partida para compartilhar: o placar com os escudos, o
/// eleito com o percentual de votos, os números dele na temporada e os mais
/// votados com a porcentagem de cada um. Fundo da marca com detalhes dourados
/// (a votação não é de um time só).
class MatchMvpShareCard extends StatelessWidget {
  final MatchDTO match;

  /// Apuração com eleito (a tela só compartilha quando há votos).
  final VotingResult result;

  static const int _topCount = 3;

  const MatchMvpShareCard({super.key, required this.match, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final elected = result.elected!;
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    final info = [match.date, match.time, match.venue].where((s) => s.trim().isNotEmpty).join('  ·  ');
    final top = result.ranking.take(_topCount).toList();

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: AppColors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: ArenaHeroBackground(
            watermarkFactor: 0.5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(AppSizes.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s18),
                          const SizedBox(width: AppSizes.s6),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l10n.votingCardLabel,
                                maxLines: 1,
                                style: AppTypography.label(color: AppColors.gold).copyWith(
                                  fontSize: AppSizes.s12,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Image.asset('lib/assets/images/ic_logo.png', height: AppSizes.s20),
                        ],
                      ),
                      // Nome longo/fonte grande: encolhe o bloco em vez de estourar.
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: constraints.maxWidth - AppSizes.s32,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (info.isNotEmpty) ...[
                                  const SizedBox(height: AppSizes.s8),
                                  Text(
                                    info,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.subtitle(color: AppColors.whiteMuted)
                                        .copyWith(fontSize: AppSizes.s12),
                                  ),
                                ],
                                const SizedBox(height: AppSizes.s10),
                                _Scoreboard(match: match, homeCrest: result.homeCrest, awayCrest: result.awayCrest),
                                const SizedBox(height: AppSizes.s14),
                                _Elected(
                                  elected: elected,
                                  percent: (result.shareOf(elected.votes) * 100).round(),
                                ),
                                const SizedBox(height: AppSizes.s14),
                                Text(
                                  l10n.votingCardTopVotes.toUpperCase(),
                                  style: AppTypography.label(color: AppColors.whiteMuted)
                                      .copyWith(fontSize: AppSizes.s10, letterSpacing: 1.2),
                                ),
                                const SizedBox(height: AppSizes.s6),
                                for (var i = 0; i < top.length; i++)
                                  _VoteBar(
                                    position: i + 1,
                                    tally: top[i],
                                    share: result.shareOf(top[i].votes),
                                    isWinner: top[i].playerName == elected.playerName,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.s6),
                      Text(
                        l10n.votingVotes(result.totalVotes),
                        textAlign: TextAlign.right,
                        style: AppTypography.label(color: AppColors.whiteMuted).copyWith(fontSize: AppSizes.s12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Escudo e nome dos dois times com o placar grande no meio.
class _Scoreboard extends StatelessWidget {
  final MatchDTO match;
  final String homeCrest;
  final String awayCrest;

  const _Scoreboard({required this.match, required this.homeCrest, required this.awayCrest});

  @override
  Widget build(BuildContext context) {
    Widget side(String name, String crest) => Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s4),
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                child: TeamCrest(imageUrl: crest, size: AppSizes.s36),
              ),
              const SizedBox(height: AppSizes.s4),
              Text(
                name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
              ),
            ],
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        side(match.homeTeam, homeCrest),
        // Placar de dois dígitos com nomes longos: encolhe em vez de estourar.
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${match.homeGoals}  ×  ${match.awayGoals}',
                maxLines: 1,
                style: AppTypography.display(color: AppColors.white).copyWith(
                  fontSize: AppSizes.s32,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
        side(match.awayTeam, awayCrest),
      ],
    );
  }
}

/// Foto com anel dourado e troféu, nome, time, o selo com o percentual de
/// votos e os números da temporada.
class _Elected extends StatelessWidget {
  final ElectedPlayer elected;
  final int percent;

  const _Elected({required this.elected, required this.percent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = PlayerDTO(name: elected.playerName, team: elected.team, imageUrl: elected.playerImageUrl);
    final hasStats = elected.goals > 0 || elected.assists > 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 3),
                ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                  child: PlayerAvatar(player: player, size: AppSizes.s72),
                ),
              ),
              Positioned(
                bottom: -AppSizes.s8,
                child: Container(
                  width: AppSizes.s24,
                  height: AppSizes.s24,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryDark, width: 2),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: AppColors.primaryDark, size: AppSizes.s14),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  elected.playerName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
                ),
                if (elected.team.isNotEmpty)
                  Text(
                    elected.team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle(color: AppColors.whiteMuted).copyWith(fontSize: AppSizes.s12),
                  ),
                const SizedBox(height: AppSizes.s6),
                Wrap(
                  spacing: AppSizes.s6,
                  runSpacing: AppSizes.s4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                      decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppSizes.s20)),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.votingShareOfVotes(percent),
                          maxLines: 1,
                          style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                        ),
                      ),
                    ),
                    Text(
                      l10n.votingVotes(elected.votes),
                      style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
                if (hasStats) ...[
                  const SizedBox(height: AppSizes.s6),
                  Text(
                    '${l10n.votingCardSeasonStats}:  '
                    '${elected.goals} ${l10n.playersSummaryGoals.toLowerCase()}  ·  '
                    '${elected.assists} ${l10n.playersSummaryAssists.toLowerCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle(color: AppColors.whiteMuted).copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Um dos mais votados: posição, nome, barra do percentual e a porcentagem.
class _VoteBar extends StatelessWidget {
  final int position;
  final VoteTally tally;
  final double share;
  final bool isWinner;

  const _VoteBar({required this.position, required this.tally, required this.share, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    final color = isWinner ? AppColors.gold : AppColors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s6),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.s16,
            child: Text('$position', style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s12)),
          ),
          SizedBox(
            width: AppSizes.s100,
            child: Text(
              tally.playerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s12),
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.s4),
              child: Stack(
                children: [
                  Container(height: AppSizes.s8, color: AppColors.white.withValues(alpha: 0.15)),
                  FractionallySizedBox(
                    widthFactor: share.clamp(0, 1).toDouble(),
                    child: Container(height: AppSizes.s8, color: color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          SizedBox(
            width: AppSizes.s40,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${(share * 100).round()}%',
                maxLines: 1,
                style: AppTypography.label(color: color).copyWith(
                  fontSize: AppSizes.s12,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
