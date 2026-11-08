import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_chips.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/icon_text.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/themes/arena_palette.dart';

/// Topo escuro da home: menu, logo, escudo do time, saudação e chips de região.
class HomeHeader extends StatelessWidget {
  final UserDTO? user;
  final String region;
  final String? favoriteTeamImage;
  final bool showSeason;

  /// Chips de região/temporada (somem nas abas do modo organizador).
  final bool showRegion;
  final VoidCallback onOpenMenu;

  /// Organizador aprovado: o escudo vira o toggle torcedor/organizador.
  final bool showModeToggle;
  final bool organizerMode;
  final VoidCallback? onToggleMode;

  /// Âncoras do tour da home.
  final GlobalKey? menuKey;
  final GlobalKey? regionKey;
  final GlobalKey? seasonKey;

  const HomeHeader({
    super.key,
    required this.user,
    required this.region,
    required this.favoriteTeamImage,
    required this.showSeason,
    this.showRegion = true,
    required this.onOpenMenu,
    this.showModeToggle = false,
    this.organizerMode = false,
    this.onToggleMode,
    this.menuKey,
    this.regionKey,
    this.seasonKey,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firstName = user?.name.trim().split(' ').first ?? '';
    final greeting = firstName.isEmpty ? l10n.homeGreetingGuest : l10n.homeGreeting(firstName);

    return ArenaHeroBackground(
      watermarkFactor: 1.1,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSizes.s8, bottom: AppSizes.s20 + AppSizes.sheetOverlap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                child: Row(
                  children: [
                    KeyedSubtree(
                      key: menuKey,
                      child: _CircleButton(
                        tooltip: l10n.homeOpenMenu,
                        onTap: onOpenMenu,
                        child: const Icon(Icons.menu_rounded, color: AppColors.white),
                      ),
                    ),
                    Expanded(
                      child: Center(child: Image.asset(AppImages.logo, height: AppSizes.s36)),
                    ),
                    if (showModeToggle)
                      OrganizerModeToggle(organizerMode: organizerMode, onTap: onToggleMode)
                    else
                      _CircleButton(
                        tooltip: l10n.homeOpenMenu,
                        onTap: onOpenMenu,
                        child: favoriteTeamImage == null
                            ? const Icon(Icons.person_outline_rounded, color: AppColors.white)
                            : ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: favoriteTeamImage!,
                                  width: AppSizes.s30,
                                  height: AppSizes.s30,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.s20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconText(
                      greeting,
                      icon: Icons.waving_hand_rounded,
                      iconColor: AppColors.gold,
                      style: AppTypography.title(color: AppColors.white),
                    ),
                    const SizedBox(height: AppSizes.s2),
                    Text(organizerMode ? l10n.organizerModeSubtitle : l10n.homeSubtitle(region),
                        style: AppTypography.subtitle(color: AppColors.whiteSoft)),
                  ],
                ),
              ),
              if (showRegion) ...[
                const SizedBox(height: AppSizes.s16),
                RegionChips(showSeason: showSeason, regionKey: regionKey, seasonKey: seasonKey),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleButton({required this.child, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: AppSizes.s44, height: AppSizes.s44, child: Center(child: child)),
        ),
      ),
    );
  }
}

/// Pílula com os dois modos da home do organizador: ❤ torcedor e 🏆
/// organizador; o ativo fica destacado. Tocar troca.
class OrganizerModeToggle extends StatelessWidget {
  final bool organizerMode;
  final VoidCallback? onTap;

  const OrganizerModeToggle({super.key, required this.organizerMode, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget side(IconData icon, bool selected) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: AppSizes.s36,
          height: AppSizes.s36,
          decoration: BoxDecoration(
            color: selected ? AppColors.white : AppColors.transparent,
            shape: BoxShape.circle,
          ),
          child:
              Icon(icon, size: AppSizes.s20, color: selected ? ArenaPalette.of(context).primary : AppColors.whiteSoft),
        );

    return Tooltip(
      message: '${l10n.organizerModeToggle} (${organizerMode ? l10n.organizerModeOrganizer : l10n.organizerModeFan})',
      child: Semantics(
        button: true,
        toggled: organizerMode,
        label: l10n.organizerModeToggle,
        child: Material(
          color: AppColors.white.withValues(alpha: 0.12),
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.s4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  side(Icons.favorite_rounded, !organizerMode),
                  side(Icons.emoji_events_rounded, organizerMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
