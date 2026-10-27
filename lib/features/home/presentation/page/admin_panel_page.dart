import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/components/shortcut_tile.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel do admin: os cadastros e as configurações em grupos de atalhos (no
/// drawer ficam só as solicitações e este painel).
class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = context.watch<SessionCubit>().state.user?.isAdmin ?? false;
    void open(String route) => Navigator.pushNamed(context, route);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.adminPanelTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      body: !isAdmin
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s32),
              children: [
                _Group(title: l10n.adminPanelContent, tiles: [
                  ShortcutTile(
                    title: l10n.drawerRegisterNews,
                    icon: Icons.article_outlined,
                    onTap: () => open(AppRoutes.registerNewsPage),
                  ),
                  ShortcutTile(
                    title: l10n.drawerRegisterHighlight,
                    icon: Icons.star_outline_rounded,
                    onTap: () => open(AppRoutes.manageHighlightsPage),
                  ),
                  ShortcutTile(
                    title: l10n.achievementsManageTitle,
                    icon: Icons.military_tech_outlined,
                    onTap: () => open(AppRoutes.manageAchievementsPage),
                  ),
                  ShortcutTile(
                    title: l10n.pushPanelTitle,
                    icon: Icons.notifications_active_outlined,
                    onTap: () => open(AppRoutes.notificationsPanelPage),
                  ),
                ]),
                _Group(title: l10n.adminPanelCompetition, tiles: [
                  ShortcutTile(
                    title: l10n.championshipsManageTitle,
                    icon: Icons.emoji_events_outlined,
                    onTap: () => open(AppRoutes.manageChampionshipsPage),
                  ),
                  ShortcutTile(
                    title: l10n.drawerRegisterMatch,
                    icon: Icons.scoreboard_outlined,
                    onTap: () => open(AppRoutes.registerMatchPage),
                  ),
                  ShortcutTile(
                    title: l10n.drawerRegisterTeam,
                    icon: Icons.shield_outlined,
                    onTap: () => open(AppRoutes.registerTeamPage),
                  ),
                  ShortcutTile(
                    title: l10n.drawerRegisterPlayer,
                    icon: Icons.person_add_alt_outlined,
                    onTap: () => open(AppRoutes.registerPlayerPage),
                  ),
                ]),
                _Group(title: l10n.adminPanelSettings, tiles: [
                  ShortcutTile(
                    title: l10n.regionsManageTitle,
                    icon: Icons.place_outlined,
                    onTap: () => open(AppRoutes.manageRegionsPage),
                  ),
                  ShortcutTile(
                    title: l10n.seasonsPanelTitle,
                    icon: Icons.date_range_rounded,
                    onTap: () => open(AppRoutes.seasonsPanelPage),
                  ),
                  ShortcutTile(
                    title: l10n.votingRulesTitle,
                    icon: Icons.how_to_vote_outlined,
                    onTap: () => open(AppRoutes.votingRulesPage),
                  ),
                  ShortcutTile(
                    title: l10n.recompressTitle,
                    icon: Icons.compress_rounded,
                    onTap: () => open(AppRoutes.recompressImagesPage),
                  ),
                ]),
              ],
            ),
    );
  }
}

/// Grupo do painel: título e um card com os atalhos, [_perRow] por linha
/// (a última linha completa com espaço vazio para os atalhos não esticarem).
class _Group extends StatelessWidget {
  static const int _perRow = 3;

  final String title;
  final List<ShortcutTile> tiles;

  const _Group({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += _perRow) {
      final row = tiles.sublist(i, (i + _perRow).clamp(0, tiles.length));
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...row,
          for (var j = row.length; j < _perRow; j++) const Expanded(child: SizedBox.shrink()),
        ],
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        ArenaCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s12),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSizes.s12),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
