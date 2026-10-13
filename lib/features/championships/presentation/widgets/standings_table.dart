import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Tabela de classificação: Pos · escudo + time · P · J · V · E · D · SG.
/// Os [qualifiedCount] primeiros ganham o filete verde; o time do usuário fica
/// em destaque; tocar numa linha expande com gols feitos/sofridos e
/// aproveitamento.
class StandingsTable extends StatefulWidget {
  final List<StandingDTO> standings;
  final int qualifiedCount;

  /// Time do coração do usuário logado (nome normalizado).
  /// Linha do time do coração (destacada).
  final bool Function(StandingDTO standing)? isFavorite;

  const StandingsTable({super.key, required this.standings, required this.qualifiedCount, this.isFavorite});

  @override
  State<StandingsTable> createState() => _StandingsTableState();
}

class _StandingsTableState extends State<StandingsTable> {
  String? _expandedId;

  static const double _statWidth = AppSizes.s30;
  static const double _positionWidth = AppSizes.s28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headerStyle = AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12);

    return ArenaCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s10, AppSizes.s12, AppSizes.s10),
            child: Row(
              children: [
                SizedBox(width: _positionWidth, child: Text(l10n.standingsColPosition, style: headerStyle)),
                Expanded(child: Text(l10n.standingsColTeam, style: headerStyle)),
                for (final label in [
                  l10n.championshipsStandingsPoints,
                  l10n.standingsColGames,
                  l10n.championshipsStandingsWins,
                  l10n.championshipsStandingsDraws,
                  l10n.championshipsStandingsLosses,
                  l10n.championshipsStandingsGoalDifference,
                ])
                  SizedBox(width: _statWidth, child: Text(label, textAlign: TextAlign.center, style: headerStyle)),
              ],
            ),
          ),
          for (var i = 0; i < widget.standings.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.greyLight),
            _Row(
              position: i + 1,
              standing: widget.standings[i],
              qualified: i < widget.qualifiedCount,
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

class _Row extends StatelessWidget {
  final int position;
  final StandingDTO standing;
  final bool qualified;
  final bool isFavorite;
  final bool expanded;
  final double statWidth;
  final double positionWidth;
  final VoidCallback onTap;

  const _Row({
    required this.position,
    required this.standing,
    required this.qualified,
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
    final statStyle = AppTypography.body().copyWith(fontSize: AppSizes.s14);

    Widget stat(String value, {bool bold = false}) => SizedBox(
          width: statWidth,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: bold ? statStyle.copyWith(fontWeight: FontWeight.w800) : statStyle,
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
              Container(width: AppSizes.s4, color: qualified ? AppColors.primary : AppColors.transparent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s12, AppSizes.s10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: positionWidth,
                            child: Text(
                              '$position',
                              style: AppTypography.label(
                                color: qualified ? AppColors.primaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
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
                          stat('${standing.points}', bold: true),
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
                                    _Detail(label: l10n.standingsGoalsFor, value: '${standing.goalsFor}'),
                                    const SizedBox(width: AppSizes.s8),
                                    _Detail(label: l10n.standingsGoalsAgainst, value: '${standing.goalsAgainst}'),
                                    const SizedBox(width: AppSizes.s8),
                                    _Detail(
                                      label: l10n.standingsPerformance,
                                      value: '${(standing.performance * 100).round()}%',
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

  const _Detail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s10, horizontal: AppSizes.s6),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.s12)),
        child: Column(
          children: [
            Text(value, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
            const SizedBox(height: AppSizes.s2),
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
