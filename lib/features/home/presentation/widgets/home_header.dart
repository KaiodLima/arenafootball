import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_chips.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Topo escuro da home: menu, logo, escudo do time, saudação e chips de região.
class HomeHeader extends StatelessWidget {
  final UserDTO? user;
  final String region;
  final String? favoriteTeamImage;
  final bool showSeason;
  final VoidCallback onOpenMenu;

  const HomeHeader({
    super.key,
    required this.user,
    required this.region,
    required this.favoriteTeamImage,
    required this.showSeason,
    required this.onOpenMenu,
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
                    _CircleButton(
                      tooltip: l10n.homeOpenMenu,
                      onTap: onOpenMenu,
                      child: const Icon(Icons.menu_rounded, color: AppColors.white),
                    ),
                    Expanded(
                      child: Center(child: Image.asset(AppImages.logo, height: AppSizes.s36)),
                    ),
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
                    Text(greeting, style: AppTypography.title(color: AppColors.white)),
                    const SizedBox(height: AppSizes.s2),
                    Text(l10n.homeSubtitle(region), style: AppTypography.subtitle(color: AppColors.whiteSoft)),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.s16),
              RegionChips(showSeason: showSeason),
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
