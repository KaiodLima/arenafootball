import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/championship_art_logo.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Logos das artes" do campeonato: até 2 logos (as artes dos jogos mostram
/// em destaque, lado a lado). Toque troca; ✕ tira; "+" acrescenta.
class ChampionshipArtLogosField extends StatelessWidget {
  final List<ChampionshipArtLogo> logos;

  /// Escolher a logo da posição (depois da última = acrescentar).
  final ValueChanged<int> onPick;
  final ValueChanged<int> onRemove;

  const ChampionshipArtLogosField({super.key, required this.logos, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.championshipArtLogosHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
        const SizedBox(height: AppSizes.s10),
        Row(
          children: [
            for (var i = 0; i < logos.length; i++) ...[
              _LogoTile(
                key: ValueKey('championship-art-logo-$i'),
                logo: logos[i],
                onTap: () => onPick(i),
                onRemove: () => onRemove(i),
                removeKey: ValueKey('championship-art-logo-remove-$i'),
              ),
              const SizedBox(width: AppSizes.s12),
            ],
            if (logos.length < ChampionshipDTO.maxArtLogos)
              _AddTile(
                key: const ValueKey('championship-art-logo-add'),
                label: l10n.championshipArtLogoAdd,
                onTap: () => onPick(logos.length),
              ),
          ],
        ),
      ],
    );
  }
}

const double _tileSize = AppSizes.s100;

class _LogoTile extends StatelessWidget {
  final ChampionshipArtLogo logo;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final Key removeKey;

  const _LogoTile(
      {super.key, required this.logo, required this.onTap, required this.onRemove, required this.removeKey});

  @override
  Widget build(BuildContext context) {
    final image = logo.file != null
        ? Image.file(logo.file!, fit: BoxFit.contain)
        : CachedNetworkImage(
            imageUrl: logo.url,
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
          );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: _tileSize,
            height: _tileSize,
            padding: const EdgeInsets.all(AppSizes.s10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.s12),
              border: Border.all(color: AppColors.greyLight),
            ),
            child: image,
          ),
        ),
        Positioned(
          right: -AppSizes.s8,
          top: -AppSizes.s8,
          child: GestureDetector(
            key: removeKey,
            onTap: onRemove,
            child: Container(
              width: AppSizes.s24,
              height: AppSizes.s24,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              child: const Icon(Icons.close_rounded, color: AppColors.white, size: AppSizes.s16),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddTile({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.s12),
      child: Container(
        width: _tileSize,
        height: _tileSize,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppSizes.s12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryDark),
            const SizedBox(height: AppSizes.s4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
            ),
          ],
        ),
      ),
    );
  }
}
