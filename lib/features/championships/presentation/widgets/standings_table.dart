import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_rules.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

const _display = 'Anton';
const _condensed = 'BarlowCondensed';

/// Tabela de classificação: Pos · escudo + time · P · J · V · E · D · SG.
/// A posição vai num quadradinho (1º dourado, classificados verdes); os
/// faixas das [rules] do grupo (só as ativas) ganham o filete; a coluna P é uma faixa
/// verde-clara; o time do usuário fica em destaque; tocar numa linha expande
/// com gols feitos/sofridos e aproveitamento.
class StandingsTable extends StatefulWidget {
  final List<StandingDTO> standings;

  /// Regras do grupo: classificados, repescagem e eliminados.
  final GroupRules rules;

  /// Linha do time do coração (destacada).
  final bool Function(StandingDTO standing)? isFavorite;

  const StandingsTable({super.key, required this.standings, this.rules = GroupRules.standard, this.isFavorite});

  @override
  State<StandingsTable> createState() => _StandingsTableState();
}

class _StandingsTableState extends State<StandingsTable> {
  String? _expandedId;

  static const double _statWidth = AppSizes.s30;
  static const double _positionWidth = AppSizes.s32;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const headerStyle = TextStyle(
      fontFamily: _condensed,
      fontWeight: FontWeight.w700,
      fontSize: AppSizes.s12,
      letterSpacing: 1.2,
      color: AppColors.textSecondary,
    );
    final labels = [
      l10n.championshipsStandingsPoints,
      l10n.standingsColGames,
      l10n.championshipsStandingsWins,
      l10n.championshipsStandingsDraws,
      l10n.championshipsStandingsLosses,
      l10n.championshipsStandingsGoalDifference,
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s10, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s12, AppSizes.s8),
            child: Row(
              children: [
                SizedBox(width: _positionWidth, child: Text(l10n.standingsColPosition, style: headerStyle)),
                const SizedBox(width: AppSizes.s8),
                Expanded(child: Text(l10n.standingsColTeam.toUpperCase(), style: headerStyle)),
                for (final label in labels)
                  SizedBox(width: _statWidth, child: Text(label, textAlign: TextAlign.center, style: headerStyle)),
              ],
            ),
          ),
          for (var i = 0; i < widget.standings.length; i++) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.greyLight),
            _Row(
              position: i + 1,
              standing: widget.standings[i],
              zone: widget.rules.zoneOf(i + 1, widget.standings.length),
              isFavorite: widget.isFavorite?.call(widget.standings[i]) ?? false,
              expanded: _expandedId == widget.standings[i].id,
              statWidth: _statWidth,
              positionWidth: _positionWidth,
              onTap: () => setState(() {
                final id = widget.standings[i].id;
                _expandedId = _expandedId == id ? null : id;
              }),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cor de cada faixa de regra (classificados, repescagem, eliminados).
Color groupZoneColor(GroupZone zone) => switch (zone) {
      GroupZone.qualified => AppColors.primary,
      GroupZone.playoff => AppColors.warning,
      GroupZone.eliminated => AppColors.danger,
      GroupZone.none => AppColors.background,
    };

/// Cor do quadradinho da posição: 1º dourado; depois, a cor da faixa ativa
/// (classificados, repescagem, eliminados) ou cinza.
Color standingsPositionColor(int position, GroupZone zone) => position == 1 ? AppColors.gold : groupZoneColor(zone);

class _Row extends StatelessWidget {
  final int position;
  final StandingDTO standing;
  final GroupZone zone;
  final bool isFavorite;
  final bool expanded;
  final double statWidth;
  final double positionWidth;
  final VoidCallback onTap;

  const _Row({
    required this.position,
    required this.standing,
    required this.zone,
    required this.isFavorite,
    required this.expanded,
    required this.statWidth,
    required this.positionWidth,
    required this.onTap,
  });

  String get _goalDifference {
    final value = standing.goalDifference;
    return value > 0 ? '+$value' : '$value';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final badge = standingsPositionColor(position, zone);
    final onBadge = position == 1
        ? AppColors.textPrimary
        : zone != GroupZone.none
            ? AppColors.white
            : AppColors.textSecondary;

    Widget stat(String value, {bool points = false}) => Container(
          width: statWidth,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s4),
          decoration: points
              ? BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s6))
              : null,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _condensed,
              fontWeight: points ? FontWeight.w800 : FontWeight.w600,
              fontSize: points ? AppSizes.s18 : AppSizes.s16,
              color: points ? AppColors.primaryDark : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );

    return Material(
      color: isFavorite ? AppColors.primarySoft : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filete da zona de classificação.
              Container(
                width: AppSizes.s4,
                color: zone == GroupZone.none ? AppColors.transparent : groupZoneColor(zone),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s12, AppSizes.s10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: positionWidth,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: AppSizes.s24,
                                height: AppSizes.s24,
                                alignment: Alignment.center,
                                decoration:
                                    BoxDecoration(color: badge, borderRadius: BorderRadius.circular(AppSizes.s6)),
                                child: Text(
                                  '$position',
                                  style: TextStyle(
                                      fontFamily: _display, fontSize: AppSizes.s14, height: 1.2, color: onBadge),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.s8),
                          TeamCrest(imageUrl: standing.imageUrl, size: AppSizes.s28),
                          const SizedBox(width: AppSizes.s8),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    standing.teamName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.body().copyWith(
                                      fontSize: AppSizes.s14,
                                      fontWeight: isFavorite ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isFavorite) ...[
                                  const SizedBox(width: AppSizes.s4),
                                  const Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s16),
                                ],
                              ],
                            ),
                          ),
                          stat('${standing.points}', points: true),
                          stat('${standing.games}'),
                          stat('${standing.wins}'),
                          stat('${standing.draws}'),
                          stat('${standing.losses}'),
                          stat(_goalDifference),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: expanded
                            ? Padding(
                                padding: const EdgeInsets.only(top: AppSizes.s12),
                                child: Row(
                                  children: [
                                    _Detail(
                                      label: l10n.standingsGoalsFor,
                                      value: '${standing.goalsFor}',
                                      color: AppColors.primaryStrong,
                                    ),
                                    const SizedBox(width: AppSizes.s8),
                                    _Detail(
                                      label: l10n.standingsGoalsAgainst,
                                      value: '${standing.goalsAgainst}',
                                      color: AppColors.danger,
                                    ),
                                    const SizedBox(width: AppSizes.s8),
                                    _Detail(
                                      label: l10n.standingsPerformance,
                                      value: '${(standing.performance * 100).round()}%',
                                      color: AppColors.medalGoldDark,
                                      progress: standing.performance,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  /// Barra fina (0–1) embaixo do número; nula = sem barra.
  final double? progress;

  const _Detail({required this.label, required this.value, required this.color, this.progress});

  @override
  Widget build(BuildContext context) {
    final progress = this.progress;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s10, horizontal: AppSizes.s8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.s12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: _display,
                fontSize: AppSizes.s22,
                height: 1.2,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: AppSizes.s4),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.s2),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: AppSizes.s4,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.s4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
            ),
          ],
        ),
      ),
    );
  }
}
