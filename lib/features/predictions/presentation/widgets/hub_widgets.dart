import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_hub.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Fonte de destaque da central do bolão (a mesma das artes).
const String hubDisplayFont = 'Anton';

TextStyle hubDisplay(double size, Color color) =>
    TextStyle(fontFamily: hubDisplayFont, fontSize: size, color: color, height: 1.05, letterSpacing: 0.3);

/// Cor de um time (principal; sem cor, o verde do app).
Color hubTeamColor(TeamDTO? team) => TeamPalette.orDefault(team?.primaryColor ?? '', team?.secondaryColor ?? '').ring;

/// "sáb 22/11 · 15:00".
String hubMatchWhen(MatchDTO match) => [match.date, match.time].where((p) => p.trim().isNotEmpty).join(' · ');

/// Cabeçalho "Seu bolão": posição, pontos/exatos/palpites, quem persegue (ou
/// líder) e o "Como pontua". Sem conta: o convite para entrar.
class HubHero extends StatelessWidget {
  final String region;
  final bool loggedIn;
  final PredictionRankingEntry? mine;
  final int? position;
  final ({String name, int gap})? chase;
  final bool leader;
  final VoidCallback onSignIn;

  const HubHero({
    super.key,
    required this.region,
    required this.loggedIn,
    required this.mine,
    required this.position,
    required this.chase,
    required this.leader,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mine = this.mine;
    final ranked = loggedIn && mine != null && position != null;
    return ArenaHeroBackground(
      watermarkFactor: 0.75,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s16, AppSizes.s20, AppSizes.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.predictionHubHeroTitle,
              style: AppTypography.label(color: AppColors.gold).copyWith(
                fontSize: AppSizes.s12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppSizes.s6),
            if (ranked) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$positionº', style: hubDisplay(AppSizes.s56, AppColors.white)),
                  const SizedBox(width: AppSizes.s8),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.s8),
                      child: Text(
                        l10n.predictionHubPlace(region),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(color: AppColors.whiteSoft),
                      ),
                    ),
                  ),
                  // As fichas encolhem juntas em telas estreitas.
                  Flexible(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HeroStat(value: '${mine.points}', label: l10n.predictionHubStatPoints, highlight: true),
                          const SizedBox(width: AppSizes.s6),
                          _HeroStat(value: '${mine.exact}', label: l10n.predictionHubStatExact),
                          const SizedBox(width: AppSizes.s6),
                          _HeroStat(value: '${mine.count}', label: l10n.predictionHubStatPicks),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.s10),
              if (leader)
                _HeroNote(icon: Icons.emoji_events_rounded, text: l10n.predictionHubLeader, gold: true)
              else if (chase != null)
                _ChaseBar(mine: mine.points, chase: chase!),
            ] else ...[
              Text(
                loggedIn ? l10n.predictionHubNoPoints : l10n.predictionHubGuest,
                style: hubDisplay(AppSizes.s22, AppColors.white),
              ),
              if (!loggedIn) ...[
                const SizedBox(height: AppSizes.s10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: onSignIn,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.black,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(l10n.predictionHubSignIn),
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSizes.s14),
            const HubHowItScores(),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _HeroStat({required this.value, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: AppSizes.s48),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s6),
      decoration: BoxDecoration(
        color: highlight ? AppColors.gold : AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.s12),
      ),
      child: Column(
        children: [
          Text(value, style: hubDisplay(AppSizes.s20, highlight ? AppColors.black : AppColors.white)),
          Text(
            label,
            style: AppTypography.label(color: highlight ? AppColors.black : AppColors.whiteSoft)
                .copyWith(fontSize: AppSizes.s10),
          ),
        ],
      ),
    );
  }
}

class _HeroNote extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool gold;

  const _HeroNote({required this.icon, required this.text, this.gold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s8),
      decoration: BoxDecoration(
        color: gold ? AppColors.gold.withValues(alpha: 0.18) : AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.s12),
        border: Border.all(color: gold ? AppColors.gold : AppColors.transparent),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: AppSizes.s18),
          const SizedBox(width: AppSizes.s8),
          Expanded(child: Text(text, style: AppTypography.label(color: AppColors.white))),
        ],
      ),
    );
  }
}

/// "Faltam 5 pts para passar Ana" com a barra até os pontos dela.
class _ChaseBar extends StatelessWidget {
  final int mine;
  final ({String name, int gap}) chase;

  const _ChaseBar({required this.mine, required this.chase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final target = mine + chase.gap;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s8, AppSizes.s12, AppSizes.s10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.s12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: AppColors.gold, size: AppSizes.s18),
              const SizedBox(width: AppSizes.s6),
              Expanded(
                child: Text(
                  l10n.predictionHubChase(chase.gap, chase.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.s6),
            child: LinearProgressIndicator(
              value: target == 0 ? 0 : (mine / target).clamp(0.0, 1.0),
              minHeight: AppSizes.s6,
              backgroundColor: AppColors.white.withValues(alpha: 0.15),
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Como pontua": 10 · 7 · 5 em fichas.
class HubHowItScores extends StatelessWidget {
  const HubHowItScores({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget chip(String points, String label, IconData icon) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.s8, horizontal: AppSizes.s6),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppSizes.s12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppSizes.s16, color: AppColors.gold),
                const SizedBox(width: AppSizes.s4),
                Text(points, style: hubDisplay(AppSizes.s20, AppColors.gold)),
                const SizedBox(width: AppSizes.s4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s10, height: 1.1),
                  ),
                ),
              ],
            ),
          ),
        );
    return Row(
      children: [
        chip('10', l10n.predictionHubExact, Icons.gps_fixed_rounded),
        const SizedBox(width: AppSizes.s6),
        chip('7', l10n.predictionHubWinnerDiff, Icons.check_circle_rounded),
        const SizedBox(width: AppSizes.s6),
        chip('5', l10n.predictionHubWinner, Icons.thumb_up_alt_rounded),
      ],
    );
  }
}

/// Título de seção da central ("PRÓXIMOS JOGOS").
class HubSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const HubSectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s16, AppSizes.s4, AppSizes.s8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AppTypography.label(color: AppColors.textSecondary)
                  .copyWith(fontSize: AppSizes.s12, letterSpacing: 1.1),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// O jogo mais próximo: metades nas cores dos times, escudos grandes, "VS",
/// data/horário, "Fecha em…" e o palpite (ou o botão de palpitar).
class HubFeaturedMatch extends StatelessWidget {
  final MatchDTO match;
  final TeamDirectory teams;
  final PredictionDTO? prediction;
  final DateTime now;
  final VoidCallback onPredict;

  const HubFeaturedMatch({
    super.key,
    required this.match,
    required this.teams,
    required this.prediction,
    required this.now,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final home = teams.resolve(id: match.homeTeamId, name: match.homeTeam);
    final away = teams.resolve(id: match.awayTeamId, name: match.awayTeam);
    final kickoff = PredictionHub.kickoffOf(match, now);
    final closes = kickoff == null ? '' : PredictionHub.closesIn(kickoff, now);
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    Widget side(TeamDTO? team, String name) => Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s4),
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                child: TeamCrest(imageUrl: team?.imageUrl, size: AppSizes.s56),
              ),
              const SizedBox(height: AppSizes.s8),
              Text(
                name.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: hubDisplay(AppSizes.s16, AppColors.white),
              ),
            ],
          ),
        );

    return Container(
      key: ValueKey('hub-featured-${match.id}'),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withValues(alpha: 0.18), blurRadius: AppSizes.s12, offset: const Offset(0, 6))
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: ColoredBox(color: Color.lerp(hubTeamColor(home), AppColors.black, 0.25)!)),
                  Expanded(child: ColoredBox(color: Color.lerp(hubTeamColor(away), AppColors.black, 0.35)!)),
                ],
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.black.withValues(alpha: 0.05), AppColors.black.withValues(alpha: 0.55)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.s16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hubMatchWhen(match),
                          style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                        ),
                      ),
                      if (closes.isNotEmpty) _ClosesPill(text: l10n.predictionHubClosesIn(closes)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.s12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      side(home, match.homeTeam),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.s20),
                        child: Text('VS', style: hubDisplay(AppSizes.s28, AppColors.gold)),
                      ),
                      side(away, match.awayTeam),
                    ],
                  ),
                  const SizedBox(height: AppSizes.s14),
                  _PickAction(prediction: prediction, onPredict: onPredict, large: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Os outros próximos jogos, em linha: escudos, nomes, quando, "Fecha em" e o palpite.
class HubMatchTile extends StatelessWidget {
  final MatchDTO match;
  final TeamDirectory teams;
  final PredictionDTO? prediction;
  final DateTime now;
  final VoidCallback onPredict;

  const HubMatchTile({
    super.key,
    required this.match,
    required this.teams,
    required this.prediction,
    required this.now,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final home = teams.resolve(id: match.homeTeamId, name: match.homeTeam);
    final away = teams.resolve(id: match.awayTeamId, name: match.awayTeam);
    final kickoff = PredictionHub.kickoffOf(match, now);
    final closes = kickoff == null ? '' : PredictionHub.closesIn(kickoff, now);

    Widget line(TeamDTO? team, String name) => Row(
          children: [
            Container(width: AppSizes.s4, height: AppSizes.s20, color: hubTeamColor(team)),
            const SizedBox(width: AppSizes.s6),
            TeamCrest(imageUrl: team?.imageUrl, size: AppSizes.s22),
            const SizedBox(width: AppSizes.s6),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary),
              ),
            ),
          ],
        );

    return Container(
      key: ValueKey('hub-match-${match.id}'),
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                line(home, match.homeTeam),
                const SizedBox(height: AppSizes.s6),
                line(away, match.awayTeam),
                const SizedBox(height: AppSizes.s6),
                Text(
                  [hubMatchWhen(match), if (closes.isNotEmpty) l10n.predictionHubClosesIn(closes)].join('  ·  '),
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s10),
          _PickAction(prediction: prediction, onPredict: onPredict),
        ],
      ),
    );
  }
}

class _ClosesPill extends StatelessWidget {
  final String text;

  const _ClosesPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(AppSizes.s20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: AppSizes.s14, color: AppColors.gold),
          const SizedBox(width: AppSizes.s4),
          Text(text, style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}

/// Sem palpite: "PALPITAR" dourado; com palpite: o placar e "Alterar".
class _PickAction extends StatelessWidget {
  final PredictionDTO? prediction;
  final VoidCallback onPredict;
  final bool large;

  const _PickAction({required this.prediction, required this.onPredict, this.large = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prediction = this.prediction;
    if (prediction == null) {
      return SizedBox(
        width: large ? double.infinity : null,
        child: FilledButton.icon(
          onPressed: onPredict,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.black,
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: large ? AppSizes.s14 : AppSizes.s10),
          ),
          icon: const Icon(Icons.sports_soccer_rounded, size: AppSizes.s18),
          label:
              Text(l10n.predictionHubPredict, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6)),
        ),
      );
    }
    final pick = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: large ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          l10n.predictionHubYourPick,
          style: AppTypography.label(color: large ? AppColors.whiteSoft : AppColors.textSecondary)
              .copyWith(fontSize: AppSizes.s10),
        ),
        Text(
          '${prediction.home} × ${prediction.away}',
          style: hubDisplay(large ? AppSizes.s28 : AppSizes.s22, large ? AppColors.gold : AppColors.primaryDark),
        ),
      ],
    );
    final change = TextButton(
      onPressed: onPredict,
      style: TextButton.styleFrom(foregroundColor: large ? AppColors.white : AppColors.primary),
      child: Text(l10n.predictionHubChange),
    );
    if (!large) {
      return Column(mainAxisSize: MainAxisSize.min, children: [pick, SizedBox(height: AppSizes.s24, child: change)]);
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s8, AppSizes.s6, AppSizes.s8),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.s14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.gold),
        const SizedBox(width: AppSizes.s10),
        Expanded(child: pick),
        change
      ]),
    );
  }
}

/// Um palpite já jogado: escudos e o placar real, o palpite da conta e os
/// pontos ("+10 Exato"; sem apuração, "Aguardando apuração").
class HubRecentPick extends StatelessWidget {
  final MatchDTO match;
  final TeamDirectory teams;
  final PredictionDTO prediction;
  final VoidCallback onTap;

  const HubRecentPick(
      {super.key, required this.match, required this.teams, required this.prediction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final home = teams.resolve(id: match.homeTeamId, name: match.homeTeam);
    final away = teams.resolve(id: match.awayTeamId, name: match.awayTeam);
    final points = prediction.scored ? (prediction.points ?? 0) : null;
    final (Color color, String label) = switch (points) {
      null => (AppColors.textSecondary, l10n.predictionHubPending),
      0 => (AppColors.grey, '0'),
      _ when prediction.exact => (AppColors.primary, '+$points ${l10n.predictionHubExactChip}'),
      _ => (AppColors.medalGoldDark, '+$points'),
    };

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.s16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.s8),
          padding: const EdgeInsets.all(AppSizes.s12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.s16),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Row(
            children: [
              TeamCrest(imageUrl: home?.imageUrl, size: AppSizes.s28),
              const SizedBox(width: AppSizes.s6),
              Text('${match.homeGoals} × ${match.awayGoals}', style: hubDisplay(AppSizes.s20, AppColors.textPrimary)),
              const SizedBox(width: AppSizes.s6),
              TeamCrest(imageUrl: away?.imageUrl, size: AppSizes.s28),
              const SizedBox(width: AppSizes.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${match.homeTeam} × ${match.awayTeam}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                    ),
                    Text(
                      l10n.predictionHubYouSaid(prediction.home, prediction.away),
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppSizes.s20)),
                child: Text(
                  label,
                  style:
                      AppTypography.label(color: color).copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inicial do nome num círculo colorido (a cor vem do nome).
class HubInitial extends StatelessWidget {
  static const _palette = [
    AppColors.primary,
    AppColors.teamBlue,
    AppColors.teamOrange,
    AppColors.teamPink,
    AppColors.teamNavy,
    AppColors.medalGoldDark,
  ];

  final String name;
  final double size;
  final Color? ring;

  const HubInitial({super.key, required this.name, required this.size, this.ring});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
    final color = _palette[trimmed.codeUnits.fold(0, (sum, c) => sum + c) % _palette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: ring == null ? null : Border.all(color: ring!, width: size * 0.07),
      ),
      child: Text(initial, style: hubDisplay(size * 0.45, AppColors.white)),
    );
  }
}

/// Pódio dos palpiteiros: fundo da marca, 2º · 1º · 3º com medalha, coroa no
/// 1º, pontos em Anton e os exatos.
class HubPodium extends StatelessWidget {
  final List<PredictionRankingEntry> entries;
  final int Function(int index) positionAt;
  final String uid;

  const HubPodium({super.key, required this.entries, required this.positionAt, required this.uid});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final order = [if (entries.length > 1) 1, 0, if (entries.length > 2) 2];
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: ArenaHeroBackground(
        watermarkFactor: 0.7,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s16, AppSizes.s8, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final index in order)
                Expanded(
                  child: Builder(builder: (context) {
                    final entry = entries[index];
                    final position = positionAt(index);
                    final first = index == 0;
                    final medal =
                        switch (position) { 1 => AppColors.gold, 2 => AppColors.silver, _ => AppColors.bronze };
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (first)
                            const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: AppSizes.s32),
                          HubInitial(name: entry.name, size: first ? AppSizes.s64 : AppSizes.s52, ring: medal),
                          const SizedBox(height: AppSizes.s6),
                          Text(
                            entry.name,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(color: entry.uid == uid ? AppColors.gold : AppColors.white)
                                .copyWith(fontSize: AppSizes.s12),
                          ),
                          Text('${entry.points}', style: hubDisplay(first ? AppSizes.s28 : AppSizes.s22, medal)),
                          Text(
                            l10n.predictionRankingStats(entry.exact, entry.count),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s10),
                          ),
                          const SizedBox(height: AppSizes.s8),
                          Container(
                            height: switch (position) { 1 => AppSizes.s64, 2 => AppSizes.s44, _ => AppSizes.s32 },
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [medal, Color.lerp(medal, AppColors.black, 0.4)!],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.s10)),
                            ),
                            child: Text('$positionº',
                                style: hubDisplay(AppSizes.s22, AppColors.black.withValues(alpha: 0.7))),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha do 4º em diante: posição, inicial, nome com a barra de
/// aproveitamento e os pontos; a da conta destacada.
class HubRankingRow extends StatelessWidget {
  final PredictionRankingEntry entry;
  final int position;
  final bool mine;

  const HubRankingRow({super.key, required this.entry, required this.position, required this.mine});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rate = PredictionHub.hitRate(entry);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
      decoration: BoxDecoration(
        color: mine ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: mine ? AppColors.primary : AppColors.greyLight),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.s32,
            child: Text('$positionº', style: hubDisplay(AppSizes.s18, AppColors.textSecondary)),
          ),
          HubInitial(name: entry.name, size: AppSizes.s36),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSizes.s4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.s4),
                  child: LinearProgressIndicator(
                    value: rate,
                    minHeight: AppSizes.s4,
                    backgroundColor: AppColors.greyLight,
                    color: mine ? AppColors.primary : AppColors.medalGoldDark,
                  ),
                ),
                const SizedBox(height: AppSizes.s2),
                Text(
                  '${l10n.predictionRankingStats(entry.exact, entry.count)} · ${l10n.predictionHubHitRate((rate * 100).round())}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          Column(
            children: [
              Text('${entry.points}', style: hubDisplay(AppSizes.s22, AppColors.primaryDark)),
              Text('pts', style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10)),
            ],
          ),
        ],
      ),
    );
  }
}
