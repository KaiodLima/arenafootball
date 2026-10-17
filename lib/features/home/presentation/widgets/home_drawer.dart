import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Menu lateral da home: perfil, navegação, cadastros do admin e sair.
class HomeDrawer extends StatelessWidget {
  final UserDTO? user;
  final String? favoriteTeamImage;

  /// Pedidos "Sou jogador" pendentes (contador do item do admin).
  final int pendingPlayerRequests;

  /// Pedidos "Sou dono de time" pendentes (contador do item do admin).
  final int pendingTeamRequests;

  /// Time em que a conta joga ("Sou jogador" aprovado) e o atleta dela.
  final String? playerTeam;
  final String? playerId;
  final String? playerSeason;

  /// Time do qual a conta é dona/treinadora ("Sou dono de time" aprovado).
  final String? ownedTeam;
  final VoidCallback onChooseTeam;
  final VoidCallback onLogout;

  const HomeDrawer({
    super.key,
    this.user,
    this.favoriteTeamImage,
    this.pendingPlayerRequests = 0,
    this.pendingTeamRequests = 0,
    this.playerTeam,
    this.playerId,
    this.playerSeason,
    this.ownedTeam,
    required this.onChooseTeam,
    required this.onLogout,
  });

  void _open(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = user?.isAdmin ?? false;

    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.85,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppSizes.radiusLarge)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _ProfileHeader(
            user: user,
            favoriteTeamImage: favoriteTeamImage,
            playerTeam: playerTeam,
            ownedTeam: ownedTeam,
            onOpenPlayer: playerId == null
                ? null
                : () {
                    Navigator.pop(context);
                    openAthlete(
                      context,
                      {'playerId': playerId, 'season': playerSeason},
                    );
                  },
            onOpenOwnedTeam: () => _open(context, AppRoutes.teamRequestPage),
            onChooseTeam: () {
              Navigator.pop(context);
              onChooseTeam();
            },
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s16, AppSizes.s12, AppSizes.s16),
              children: [
                _SectionLabel(l10n.drawerNavigation),
                _DrawerItem(
                  icon: Icons.public_rounded,
                  title: l10n.drawerResults,
                  onTap: () => _open(context, AppRoutes.globalResultsPage),
                ),
                if (user != null)
                  _DrawerItem(
                    icon: Icons.badge_outlined,
                    title: l10n.fanCardMenu,
                    onTap: () => _open(context, AppRoutes.fanCardPage),
                  ),
                if (user != null)
                  _DrawerItem(
                    icon: Icons.sports_soccer_rounded,
                    title: playerTeam != null ? l10n.drawerMyPlayerProfile : l10n.playerRequestMenu,
                    onTap: () => _open(context, AppRoutes.playerRequestPage),
                  ),
                if (user != null)
                  _DrawerItem(
                    icon: Icons.shield_rounded,
                    title: ownedTeam != null ? l10n.myTeamTitle : l10n.teamRequestMenu,
                    onTap: () => _open(context, AppRoutes.teamRequestPage),
                  ),
                if (isAdmin) ...[
                  const SizedBox(height: AppSizes.s12),
                  _SectionLabel(l10n.drawerAdmin),
                  _DrawerItem(
                    icon: Icons.how_to_reg_outlined,
                    title: l10n.playerRequestsPanelTitle,
                    badge: pendingPlayerRequests,
                    onTap: () => _open(context, AppRoutes.playerRequestsPanelPage),
                  ),
                  _DrawerItem(
                    icon: Icons.add_moderator_outlined,
                    title: l10n.teamRequestsPanelTitle,
                    badge: pendingTeamRequests,
                    onTap: () => _open(context, AppRoutes.teamRequestsPanelPage),
                  ),
                  _DrawerItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: l10n.adminPanelTitle,
                    onTap: () => _open(context, AppRoutes.adminPanelPage),
                  ),
                ],
              ],
            ),
          ),
          if (user != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s12, 0, AppSizes.s12, AppSizes.s12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      title: l10n.settingsTitle,
                      onTap: () => _open(context, AppRoutes.settingsPage),
                    ),
                    _DrawerItem(
                      icon: Icons.logout_rounded,
                      title: l10n.drawerLogout,
                      color: AppColors.danger,
                      showChevron: false,
                      onTap: () {
                        Navigator.pop(context);
                        onLogout();
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final _headerButtonStyle = FilledButton.styleFrom(
  backgroundColor: AppColors.white,
  foregroundColor: AppColors.primaryDark,
  shape: const StadiumBorder(),
);

class _ProfileHeader extends StatelessWidget {
  final UserDTO? user;
  final String? favoriteTeamImage;
  final String? playerTeam;
  final String? ownedTeam;
  final VoidCallback onChooseTeam;
  final VoidCallback? onOpenPlayer;
  final VoidCallback onOpenOwnedTeam;

  const _ProfileHeader({
    this.user,
    this.favoriteTeamImage,
    this.playerTeam,
    this.ownedTeam,
    required this.onChooseTeam,
    this.onOpenPlayer,
    required this.onOpenOwnedTeam,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isGuest = user == null;

    return ArenaHeroBackground(
      watermarkFactor: 0.9,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              // À direita, espaço para o ✕ não cobrir o nome.
              padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s24, AppSizes.s48, AppSizes.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.s4),
                    decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: AppSizes.s32,
                      backgroundColor: AppColors.background,
                      backgroundImage:
                          favoriteTeamImage == null ? null : CachedNetworkImageProvider(favoriteTeamImage!),
                      child: favoriteTeamImage == null
                          ? const Icon(Icons.person_rounded, color: AppColors.textSecondary, size: AppSizes.s32)
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSizes.s14),
                  Text(
                    isGuest ? l10n.drawerGuest : user!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(color: AppColors.white),
                  ),
                  const SizedBox(height: AppSizes.s8),
                  if (isGuest) ...[
                    Text(l10n.drawerGuestSubtitle, style: AppTypography.subtitle(color: AppColors.whiteSoft)),
                    const SizedBox(height: AppSizes.s14),
                    FilledButton(
                      style: _headerButtonStyle,
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginPage, (_) => false),
                      child: Text(l10n.drawerSignIn),
                    ),
                  ] else ...[
                    // Papéis da conta: dono/treinador, jogador e torcedor.
                    if (ownedTeam != null || playerTeam != null || user!.hasFavoriteTeam)
                      Wrap(
                        spacing: AppSizes.s6,
                        runSpacing: AppSizes.s6,
                        children: [
                          if (ownedTeam != null)
                            _RoleBadge(
                              icon: Icons.shield_rounded,
                              label: l10n.drawerOwnerOf(ownedTeam!),
                              highlighted: true,
                              onTap: onOpenOwnedTeam,
                            ),
                          if (playerTeam != null)
                            _RoleBadge(
                              icon: Icons.sports_soccer_rounded,
                              label: l10n.drawerPlayerOf(playerTeam!),
                              highlighted: true,
                              onTap: onOpenPlayer,
                            ),
                          if (user!.hasFavoriteTeam)
                            _RoleBadge(icon: Icons.favorite_rounded, label: l10n.drawerFanOf(user!.favoriteTeam)),
                        ],
                      ),
                    if (!user!.hasFavoriteTeam) ...[
                      if (ownedTeam != null || playerTeam != null) const SizedBox(height: AppSizes.s10),
                      FilledButton.icon(
                        style: _headerButtonStyle,
                        onPressed: onChooseTeam,
                        icon: const Icon(Icons.shield_outlined, size: AppSizes.s18),
                        label: Text(l10n.drawerChooseTeam),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            Positioned(
              top: AppSizes.s4,
              right: AppSizes.s4,
              child: IconButton(
                tooltip: l10n.drawerClose,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s4, AppSizes.s12, AppSizes.s8),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12, letterSpacing: 1),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showChevron;
  final Color color;

  /// Contador ao lado do título (0 = sem contador).
  final int badge;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showChevron = true,
    this.color = AppColors.primaryDark,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s4),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
            child: Row(
              children: [
                Container(
                  width: AppSizes.s36,
                  height: AppSizes.s36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppSizes.s10),
                  ),
                  child: Icon(icon, color: color, size: AppSizes.s20),
                ),
                const SizedBox(width: AppSizes.s14),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.label(color: color == AppColors.primaryDark ? AppColors.textPrimary : color)
                        .copyWith(fontSize: AppSizes.s16),
                  ),
                ),
                if (badge > 0)
                  Container(
                    margin: const EdgeInsets.only(left: AppSizes.s8),
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(AppSizes.s10),
                    ),
                    child: Text(
                      '$badge',
                      style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                    ),
                  ),
                if (showChevron)
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Selo do cabeçalho (papel da conta). Destacado = verde (jogador, dono).
class _RoleBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback? onTap;

  const _RoleBadge({required this.icon, required this.label, this.highlighted = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.s20);
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: highlighted ? AppColors.primary : AppColors.white.withValues(alpha: 0.15),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppSizes.s14, color: AppColors.white),
                const SizedBox(width: AppSizes.s4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
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
