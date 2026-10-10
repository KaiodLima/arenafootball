import 'package:flutter/material.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Menu lateral da home. Os itens de cadastro só aparecem para admin.
class HomeDrawer extends StatelessWidget {
  final UserDTO? user;
  final String? favoriteTeamImage;

  const HomeDrawer({super.key, this.user, this.favoriteTeamImage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = user?.isAdmin ?? false;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  maxRadius: AppSizes.s40,
                  backgroundColor: AppColors.grey,
                  backgroundImage: favoriteTeamImage == null ? null : NetworkImage(favoriteTeamImage!),
                ),
                const SizedBox(width: AppSizes.s16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? l10n.drawerGuest,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s24),
                      ),
                      if (user != null && user!.favoriteTeam.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.s8),
                        Text(
                          l10n.drawerFanOf(user!.favoriteTeam),
                          style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s16),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(icon: Icons.home, title: l10n.drawerHome, onTap: () => Navigator.pop(context)),
          const Divider(),
          _DrawerItem(
            icon: Icons.manage_search_outlined,
            title: l10n.drawerResults,
            route: AppRoutes.globalResultsPage,
          ),
          if (isAdmin) ...[
            _DrawerItem(
              icon: Icons.star_rate_rounded,
              title: l10n.drawerRegisterHighlight,
              route: AppRoutes.registerHighlightPage,
            ),
            _DrawerItem(icon: Icons.person_add, title: l10n.drawerRegisterPlayer, route: AppRoutes.registerPlayerPage),
            _DrawerItem(
              icon: Icons.scoreboard_outlined,
              title: l10n.drawerRegisterMatch,
              route: AppRoutes.registerMatchPage,
            ),
            _DrawerItem(icon: Icons.info, title: l10n.drawerRegisterNews, route: AppRoutes.registerNewsPage),
            _DrawerItem(icon: Icons.shield_outlined, title: l10n.drawerRegisterTeam, route: AppRoutes.registerTeamPage),
          ],
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? route;
  final VoidCallback? onTap;

  const _DrawerItem({required this.icon, required this.title, this.route, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: AppSizes.s32, color: AppColors.primaryDark),
      title: Text(
        title,
        style: const TextStyle(fontSize: AppSizes.s16, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
      ),
      onTap: onTap ?? () => Navigator.pushNamed(context, route!),
    );
  }
}
