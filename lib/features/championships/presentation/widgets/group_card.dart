import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/standings_table.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_rules.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_table_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Fontes esportivas empacotadas (as mesmas dos cards do feed e das artes).
const _display = 'Anton';
const _condensed = 'BarlowCondensed';

/// Card de um grupo: faixa verde com o selo da letra, "GRUPO A" e o resumo
/// (times ou jogos), a mini-classificação (posição, escudo, nome, J, SG e PTS;
/// o líder em dourado e o time do usuário em destaque) — sem tabela
/// calculada, só os times — e o botão "Ver classificação".
class GroupCard extends StatelessWidget {
  final GroupDTO group;
  final String? Function(String teamName) crestOf;

  /// Tabela automática do grupo (nula = grupo antigo ou ainda sem tabela).
  final GroupTableDTO? table;

  /// Time do coração? Recebe (id, nome) do time no grupo.
  final bool Function(String id, String name)? isFavorite;
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.group,
    required this.crestOf,
    required this.onTap,
    this.table,
    this.isFavorite,
  });

  /// Letra(s) do selo: "A" para "A" ou "Grupo A"; senão, a 1ª letra.
  static String badgeOf(String description) {
    final text = description.trim();
    if (text.isEmpty) return '?';
    final last = text.split(RegExp(r'\s+')).last;
    return (last.length <= 2 ? last : text.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = table?.rows ?? const [];
    final teams = [
      for (var i = 0; i < group.teams.length; i++)
        if (group.teams[i].trim().isNotEmpty) (id: group.teamIdAt(i), name: group.teams[i]),
    ];
    final games = rows.fold<int>(0, (sum, r) => sum + r.games) ~/ 2;
    final summary = rows.isNotEmpty ? l10n.groupsGamesCount(games) : l10n.groupsTeamsCount(teams.length);
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s16),
      child: Material(
        color: AppColors.surface,
        borderRadius: radius,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.greyLight),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  badge: badgeOf(group.description),
                  title: l10n.championshipsGroupTitle(group.description).toUpperCase(),
                  summary: summary.toUpperCase(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s12, AppSizes.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (rows.isNotEmpty) ...[
                        _ColumnsHeader(
                          position: l10n.standingsColPosition,
                          team: l10n.standingsColTeam,
                          games: l10n.standingsColGames,
                          goalDiff: l10n.standingsColGoalDiff,
                          points: l10n.standingsColPoints,
                        ),
                        for (var i = 0; i < rows.length; i++)
                          _TeamRow(
                            position: i + 1,
                            zone: group.rules.zoneOf(i + 1, rows.length),
                            name: rows[i].teamName,
                            crest: rows[i].imageUrl.isNotEmpty ? rows[i].imageUrl : crestOf(rows[i].teamName),
                            isFavorite: isFavorite?.call(rows[i].id, rows[i].teamName) ?? false,
                            yourTeamLabel: l10n.standingsYourTeam,
                            stats: (rows[i].games, rows[i].goalDifference, rows[i].points),
                          ),
                      ] else
                        for (final team in teams)
                          _TeamRow(
                            name: team.name,
                            crest: crestOf(team.name),
                            isFavorite: isFavorite?.call(team.id, team.name) ?? false,
                            yourTeamLabel: l10n.standingsYourTeam,
                          ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s4, AppSizes.s12, AppSizes.s12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s6, AppSizes.s8, AppSizes.s6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppSizes.s20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.groupsSeeStandings,
                            style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s14),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.primaryDark, size: AppSizes.s20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Faixa verde: selo dourado com a letra, "GRUPO A" e o resumo.
class _Header extends StatelessWidget {
  final String badge;
  final String title;
  final String summary;

  const _Header({required this.badge, required this.title, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s8, AppSizes.s10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryStrong],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Linhas de campo bem apagadas.
          Positioned(
            right: AppSizes.s40,
            top: -AppSizes.s24,
            bottom: -AppSizes.s24,
            child: Container(
              width: AppSizes.s72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white.withValues(alpha: 0.08), width: 1.5),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: AppSizes.s40,
                height: AppSizes.s40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: Text(
                  badge,
                  style:
                      const TextStyle(fontFamily: _display, fontSize: AppSizes.s22, color: AppColors.gold, height: 1.1),
                ),
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _condensed,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.s20,
                    letterSpacing: 1.2,
                    color: AppColors.white,
                  ),
                ),
              ),
              Text(
                summary,
                style: TextStyle(
                  fontFamily: _condensed,
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.s14,
                  letterSpacing: 1,
                  color: AppColors.white.withValues(alpha: 0.75),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.white.withValues(alpha: 0.7)),
            ],
          ),
        ],
      ),
    );
  }
}

const _statWidth = AppSizes.s32;

/// Cabeçalho discreto da mini-tabela: # · TIME · J · SG · PTS.
class _ColumnsHeader extends StatelessWidget {
  final String position;
  final String team;
  final String games;
  final String goalDiff;
  final String points;

  const _ColumnsHeader({
    required this.position,
    required this.team,
    required this.games,
    required this.goalDiff,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: _condensed,
      fontWeight: FontWeight.w700,
      fontSize: AppSizes.s12,
      letterSpacing: 1,
      color: AppColors.textSecondary,
    );
    Widget stat(String text) =>
        SizedBox(width: _statWidth, child: Text(text, textAlign: TextAlign.center, style: style));
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s8, 0, AppSizes.s8, AppSizes.s4),
      child: Row(
        children: [
          SizedBox(width: AppSizes.s24, child: Text(position, textAlign: TextAlign.center, style: style)),
          const SizedBox(width: AppSizes.s10),
          Expanded(child: Text(team.toUpperCase(), style: style)),
          stat(games),
          stat(goalDiff),
          stat(points),
        ],
      ),
    );
  }
}

/// Linha do time: posição (o 1º em dourado), escudo, nome e, com tabela,
/// J, SG (com sinal) e PTS em negrito; o time do usuário em destaque com ★.
class _TeamRow extends StatelessWidget {
  final int? position;

  /// Faixa da regra ativa na posição (sem regra = neutra).
  final GroupZone zone;
  final String name;
  final String? crest;
  final bool isFavorite;
  final String yourTeamLabel;
  final (int, int, int)? stats;

  const _TeamRow({
    this.position,
    this.zone = GroupZone.none,
    required this.name,
    required this.crest,
    required this.isFavorite,
    required this.yourTeamLabel,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final position = this.position;
    final stats = this.stats;
    final leader = position == 1;
    TextStyle statStyle({bool bold = false}) => TextStyle(
          fontFamily: _condensed,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          fontSize: bold ? AppSizes.s18 : AppSizes.s16,
          color: AppColors.textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    Widget stat(String text, {bool bold = false}) =>
        SizedBox(width: _statWidth, child: Text(text, textAlign: TextAlign.center, style: statStyle(bold: bold)));

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s4),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s6),
      decoration: BoxDecoration(
        color: isFavorite ? AppColors.primarySoft : AppColors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.s10),
      ),
      child: Row(
        children: [
          if (position != null) ...[
            Container(
              width: AppSizes.s24,
              height: AppSizes.s24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: standingsPositionColor(position, zone),
                borderRadius: BorderRadius.circular(AppSizes.s6),
              ),
              child: Text(
                '$position',
                style: TextStyle(
                  fontFamily: _display,
                  fontSize: AppSizes.s14,
                  height: 1.2,
                  color: leader
                      ? AppColors.textPrimary
                      : zone == GroupZone.none
                          ? AppColors.textSecondary
                          : AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.s10),
          ],
          TeamCrest(imageUrl: crest),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body().copyWith(fontWeight: isFavorite ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
          if (isFavorite)
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.s4),
              child: Tooltip(
                message: yourTeamLabel,
                child: const Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s18),
              ),
            ),
          if (stats != null) ...[
            stat('${stats.$1}'),
            stat(stats.$2 > 0 ? '+${stats.$2}' : '${stats.$2}'),
            stat('${stats.$3}', bold: true),
          ],
        ],
      ),
    );
  }
}
