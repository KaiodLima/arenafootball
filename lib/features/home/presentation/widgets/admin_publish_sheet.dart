import 'package:flutter/material.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Sheet "Publicar" do admin: todos os cadastros num lugar só (substitui os
/// FABs soltos de anúncio e gol).
class AdminPublishSheet extends StatelessWidget {
  const AdminPublishSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const SafeArea(child: AdminPublishSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      _PublishOption(Icons.article_outlined, l10n.homePublishNews, AppRoutes.registerNewsPage),
      _PublishOption(Icons.sports_soccer_rounded, l10n.homePublishGoal, AppRoutes.goalNotificationPage),
      _PublishOption(Icons.campaign_outlined, l10n.homePublishAd, AppRoutes.publishAdPage),
      _PublishOption(Icons.star_outline_rounded, l10n.homePublishHighlight, AppRoutes.registerHighlightPage),
      _PublishOption(Icons.emoji_events_outlined, l10n.homePublishChampionship, AppRoutes.championshipFormPage),
      _PublishOption(Icons.scoreboard_outlined, l10n.homePublishMatch, AppRoutes.registerMatchPage),
      _PublishOption(Icons.shield_outlined, l10n.homePublishTeam, AppRoutes.registerTeamPage),
      _PublishOption(Icons.person_add_alt_outlined, l10n.homePublishPlayer, AppRoutes.registerPlayerPage),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.homePublishTitle, style: AppTypography.title()),
          const SizedBox(height: AppSizes.s16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSizes.s10,
            crossAxisSpacing: AppSizes.s10,
            childAspectRatio: 2.8,
            children: options.map((option) => _OptionTile(option: option)).toList(),
          ),
        ],
      ),
    );
  }
}

class _PublishOption {
  final IconData icon;
  final String label;
  final String route;

  const _PublishOption(this.icon, this.label, this.route);
}

class _OptionTile extends StatelessWidget {
  final _PublishOption option;

  const _OptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, option.route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
          child: Row(
            children: [
              Container(
                width: AppSizes.s36,
                height: AppSizes.s36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                ),
                child: Icon(option.icon, color: AppColors.primaryDark, size: AppSizes.s20),
              ),
              const SizedBox(width: AppSizes.s10),
              Expanded(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
