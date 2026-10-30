import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Boas-vindas do primeiro login: o escudo do time do coração (ou o logo), o
/// nome, três linhas do que dá para fazer e o convite para o tour rápido.
/// Devolve true se a pessoa quer o tour.
Future<bool> showWelcomeSheet(BuildContext context, {required String name, String? crestUrl}) async {
  final start = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
    ),
    builder: (_) => _WelcomeSheet(name: name, crestUrl: crestUrl),
  );
  return start ?? false;
}

class _WelcomeSheet extends StatelessWidget {
  final String name;
  final String? crestUrl;

  const _WelcomeSheet({required this.name, this.crestUrl});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crest = crestUrl ?? '';
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Faixa verde com o escudo/logo.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.s24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primaryMedium],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
            ),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, s, child) => Transform.scale(scale: s, child: child),
                child: Container(
                  width: AppSizes.s80,
                  height: AppSizes.s80,
                  padding: const EdgeInsets.all(AppSizes.s12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.25), blurRadius: AppSizes.s16)],
                  ),
                  child: crest.isEmpty
                      ? Image.asset(AppImages.logo)
                      : CachedNetworkImage(
                          imageUrl: crest,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => Image.asset(AppImages.logo),
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s20, AppSizes.s20, AppSizes.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tourWelcomeTitle(name), style: AppTypography.title().copyWith(fontSize: AppSizes.s22)),
                const SizedBox(height: AppSizes.s4),
                Text(l10n.tourWelcomeSubtitle, style: AppTypography.subtitle()),
                const SizedBox(height: AppSizes.s20),
                _Feature(icon: Icons.newspaper_rounded, text: l10n.tourWelcomeItemNews),
                _Feature(icon: Icons.how_to_vote_rounded, text: l10n.tourWelcomeItemPlay),
                _Feature(icon: Icons.collections_bookmark_rounded, text: l10n.tourWelcomeItemAlbum),
                const SizedBox(height: AppSizes.s20),
                ArenaButton.primary(title: l10n.tourWelcomeStart, function: () => Navigator.pop(context, true)),
                const SizedBox(height: AppSizes.s4),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.tourWelcomeLater, style: AppTypography.label(color: AppColors.textSecondary)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Feature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s12),
      child: Row(
        children: [
          Container(
            width: AppSizes.s36,
            height: AppSizes.s36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.s10),
            ),
            child: Icon(icon, color: AppColors.primary, size: AppSizes.s20),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(child: Text(text, style: AppTypography.body().copyWith(fontSize: AppSizes.s14))),
        ],
      ),
    );
  }
}
