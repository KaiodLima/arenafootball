import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/home/presentation/home_mode.dart';
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

  /// Organizador aprovado ou admin: o escudo vira o toggle de modos.
  final bool showModeToggle;
  final bool organizerMode;
  final VoidCallback? onToggleMode;

  /// Modo atual e se o 3º modo (jogador, só admin) aparece no toggle.
  final HomeMode mode;
  final bool showPlayerMode;

  /// Admin no modo jogador: faixa com "Sair".
  final VoidCallback? onExitPlayerMode;

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
    this.mode = HomeMode.standard,
    this.showPlayerMode = false,
    this.onExitPlayerMode,
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
                      HomeModeToggle(mode: mode, showPlayer: showPlayerMode, onTap: onToggleMode)
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
                    if (mode == HomeMode.player)
                      _PlayerModeBanner(onExit: onExitPlayerMode)
                    else
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

/// Faixa do modo jogador do admin: aviso e "Sair".
class _PlayerModeBanner extends StatelessWidget {
  final VoidCallback? onExit;

  const _PlayerModeBanner({this.onExit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.s4),
      padding: const EdgeInsets.fromLTRB(AppSizes.s10, AppSizes.s4, AppSizes.s4, AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_soccer_rounded, size: AppSizes.s16, color: AppColors.white),
          const SizedBox(width: AppSizes.s6),
          Flexible(
            child: Text(
              l10n.homeModePlayerBanner,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subtitle(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
            ),
          ),
          if (onExit != null) ...[
            const SizedBox(width: AppSizes.s6),
            Material(
              color: AppColors.white,
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: onExit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                  child: Text(
                    l10n.homeModePlayerExit,
                    style:
                        AppTypography.label(color: ArenaPalette.of(context).primary).copyWith(fontSize: AppSizes.s12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pílula com os modos da home: ❤ torcedor/admin, 🏆 organizador e, para o
/// admin, ⚽ jogador; o ativo fica destacado. Tocar passa para o próximo.
class HomeModeToggle extends StatelessWidget {
  final HomeMode mode;

  /// Mostra o 3º modo (jogador), só para a conta admin.
  final bool showPlayer;
  final VoidCallback? onTap;

  const HomeModeToggle({super.key, required this.mode, this.showPlayer = false, this.onTap});

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
    final label = switch (mode) {
      HomeMode.standard => showPlayer ? l10n.homeModeAdmin : l10n.organizerModeFan,
      HomeMode.organizer => l10n.organizerModeOrganizer,
      HomeMode.player => l10n.homeModePlayer,
    };

    return Tooltip(
      message: '${l10n.organizerModeToggle} ($label)',
      child: Semantics(
        button: true,
        label: '${l10n.organizerModeToggle}: $label',
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
                  side(Icons.favorite_rounded, mode == HomeMode.standard),
                  side(Icons.emoji_events_rounded, mode == HomeMode.organizer),
                  if (showPlayer) side(Icons.sports_soccer_rounded, mode == HomeMode.player),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
