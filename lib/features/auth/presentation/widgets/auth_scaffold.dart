import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Tag do logo compartilhada entre splash e login (transição animada).
const String arenaLogoHeroTag = 'arena-logo';

/// Layout das telas de entrada: hero escuro com a marca no topo e o
/// formulário num card branco arredondado que sobe sobre ele.
class AuthScaffold extends StatelessWidget {
  final Widget child;

  /// Hero baixo com título (cadastro) em vez do logo grande (login).
  final bool compact;
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;

  const AuthScaffold({
    super.key,
    required this.child,
    this.compact = false,
    this.title,
    this.subtitle,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.sizeOf(context).height;
            final heroHeight = screenHeight * (compact ? 0.24 : AppSizes.heroHeightFactor);

            return SingleChildScrollView(
              child: Stack(
                children: [
                  SizedBox(
                    height: heroHeight + AppSizes.cardOverlap,
                    width: double.infinity,
                    child: ArenaHeroBackground(
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.cardOverlap),
                          child: compact
                              ? _CompactHeroContent(title: title, subtitle: subtitle, onBack: onBack)
                              : const _BrandHeroContent(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: heroHeight),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - heroHeight),
                      child: _AuthCard(child: child),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeroContent extends StatelessWidget {
  const _BrandHeroContent();

  @override
  Widget build(BuildContext context) {
    // O logo já traz o slogan. Escala para baixo quando falta altura
    // (paisagem, telas pequenas) em vez de estourar o hero.
    return Padding(
      padding: const EdgeInsets.all(AppSizes.s16),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Hero(
            tag: arenaLogoHeroTag,
            child: Image.asset(AppImages.logo, height: AppSizes.s120),
          ),
        ),
      ),
    );
  }
}

class _CompactHeroContent extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;

  const _CompactHeroContent({this.title, this.subtitle, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) Text(title!, style: AppTypography.display(color: AppColors.white)),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.s4),
                  Text(subtitle!, style: AppTypography.subtitle(color: AppColors.whiteSoft)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.s16),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final Widget child;

  const _AuthCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s24, offset: Offset(0, -AppSizes.s4))],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.s24,
        AppSizes.s28,
        AppSizes.s24,
        AppSizes.s24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        // Em tablet o formulário não estica: fica numa coluna de leitura confortável.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, AppSizes.s24 * (1 - value)), child: child),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
