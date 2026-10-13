import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/matchup_background.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Card do craque da partida para compartilhar: o placar com os escudos, o
/// eleito com o percentual de votos, os números dele na temporada e os mais
/// votados com a porcentagem de cada um. Fundo de confronto com os escudos e
/// as cores dos dois times; o conteúdo fica num painel claro no centro.
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
    final home = TeamPalette.orDefault(result.homePrimaryColor, result.homeSecondaryColor);
    final away = TeamPalette.orDefault(result.awayPrimaryColor, result.awaySecondaryColor);
    // Barra de cada votado na cor do time dele.
    Color teamColor(VoteTally tally) =>
        sameTeam(idA: tally.teamId, nameA: tally.team, idB: match.homeTeamId, nameB: match.homeTeam)
            ? home.accent
            : sameTeam(idA: tally.teamId, nameA: tally.team, idB: match.awayTeamId, nameB: match.awayTeam)
                ? away.accent
                : AppColors.textSecondary;

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
          child: MatchupBackground(
            home: home,
            away: away,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                // Parte do escudo que entra pela borda (+ folga): o topo desvia do
                // escudo do mandante (esquerda) e o rodapé, do visitante (direita).
                final shieldInset = width * 0.21;
                const edge = AppSizes.s12;

                // Nome longo/fonte grande: encolhe tudo junto em vez de estourar.
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: width,
                    // Altura do card no mínimo (os Spacers distribuem a sobra); se o
                    // conteúdo passar disso, cresce e o FittedBox reduz o conjunto.
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(shieldInset, AppSizes.s12, edge, 0),
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
                                            style: AppTypography.label(color: AppColors.primaryDark).copyWith(
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
                                  const SizedBox(height: AppSizes.s8),
                                  _Panel(
                                    child: Column(
                                      children: [
                                        if (info.isNotEmpty) ...[
                                          Text(
                                            info,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10),
                                          ),
                                          const SizedBox(height: AppSizes.s6),
                                        ],
                                        _Scoreboard(
                                          match: match,
                                          homeCrest: result.homeCrest,
                                          awayCrest: result.awayCrest,
                                          homeRing: home.ring,
                                          awayRing: away.ring,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Faixa do meio, entre os dois escudos: largura toda.
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: edge),
                              child: _Elected(
                                elected: elected,
                                percent: (result.shareOf(elected.votes) * 100).round(),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: EdgeInsets.fromLTRB(edge, 0, shieldInset, AppSizes.s12),
                              child: _Panel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            l10n.votingCardTopVotes.toUpperCase(),
                                            style: AppTypography.label(color: AppColors.textSecondary)
                                                .copyWith(fontSize: AppSizes.s10, letterSpacing: 1.2),
                                          ),
                                        ),
                                        Text(
                                          l10n.votingVotes(result.totalVotes),
                                          style: AppTypography.label(color: AppColors.textSecondary)
                                              .copyWith(fontSize: AppSizes.s10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSizes.s6),
                                    for (var i = 0; i < top.length; i++)
                                      _VoteBar(
                                        position: i + 1,
                                        tally: top[i],
                                        share: result.shareOf(top[i].votes),
                                        isWinner: top[i].playerName == elected.playerName,
                                        color: teamColor(top[i]),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

/// Bloco branco translúcido sobre o fundo (o desenho aparece entre os blocos).
class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s10, AppSizes.s8, AppSizes.s10, AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppSizes.s12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.08), blurRadius: 10)],
      ),
      child: child,
    );
  }
}

/// Escudo e nome dos dois times com o placar grande no meio.
class _Scoreboard extends StatelessWidget {
  final MatchDTO match;
  final String homeCrest;
  final String awayCrest;
  final Color homeRing;
  final Color awayRing;

  const _Scoreboard({
    required this.match,
    required this.homeCrest,
    required this.awayCrest,
    required this.homeRing,
    required this.awayRing,
  });

  @override
  Widget build(BuildContext context) {
    Widget side(String name, String crest, Color ring) => Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: ring, width: 2),
                ),
                child: TeamCrest(imageUrl: crest, size: AppSizes.s36),
              ),
              const SizedBox(height: AppSizes.s4),
              Text(
                name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
              ),
            ],
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        side(match.homeTeam, homeCrest, homeRing),
        // Placar de dois dígitos com nomes longos: encolhe em vez de estourar.
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${match.homeGoals}  ×  ${match.awayGoals}',
                maxLines: 1,
                style: AppTypography.display().copyWith(
                  fontSize: AppSizes.s32,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
        side(match.awayTeam, awayCrest, awayRing),
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
        color: Color.alphaBlend(AppColors.gold.withValues(alpha: 0.1), AppColors.white),
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.gold, width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.12), blurRadius: 12)],
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
                    border: Border.all(color: AppColors.white, width: 2),
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
                  style: AppTypography.display().copyWith(fontSize: AppSizes.s20),
                ),
                if (elected.team.isNotEmpty)
                  Text(
                    elected.team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                const SizedBox(height: AppSizes.s6),
                Wrap(
                  spacing: AppSizes.s6,
                  runSpacing: AppSizes.s4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                      decoration:
                          BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppSizes.s20)),
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
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
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
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
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

  /// Cor do time do votado (o eleito fica em dourado).
  final Color color;

  const _VoteBar({
    required this.position,
    required this.tally,
    required this.share,
    required this.isWinner,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bar = isWinner ? AppColors.gold : color;
    final text = isWinner ? AppColors.textPrimary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s6),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.s16,
            child: Text('$position', style: AppTypography.label(color: text).copyWith(fontSize: AppSizes.s12)),
          ),
          Expanded(
            flex: 5,
            child: Text(
              tally.playerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: text).copyWith(fontSize: AppSizes.s12),
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.s4),
              child: Stack(
                children: [
                  Container(height: AppSizes.s8, color: AppColors.greyLight),
                  FractionallySizedBox(
                    widthFactor: share.clamp(0, 1).toDouble(),
                    child: Container(height: AppSizes.s8, color: bar),
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
                style: AppTypography.label(color: text).copyWith(
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
