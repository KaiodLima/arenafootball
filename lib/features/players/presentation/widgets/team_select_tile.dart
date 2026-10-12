import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Campo de escolha de time: escudo + nome + ▾ (abre a lista de times).
class TeamSelectTile extends StatelessWidget {
  final String label;
  final String? team;
  final String? crest;
  final String placeholder;
  final String? errorText;
  final VoidCallback onTap;

  const TeamSelectTile({
    super.key,
    required this.label,
    required this.team,
    required this.crest,
    required this.placeholder,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.fieldRadius);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: hasError ? AppColors.danger : AppColors.greyLight),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s12, AppSizes.s10),
              child: Row(
                children: [
                  TeamCrest(imageUrl: crest, size: AppSizes.s44),
                  const SizedBox(width: AppSizes.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                        Text(
                          team ?? placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(color: team == null ? AppColors.primary : AppColors.textPrimary)
                              .copyWith(fontSize: AppSizes.s16),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.s12, top: AppSizes.s6),
            child:
                Text(errorText!, style: AppTypography.label(color: AppColors.danger).copyWith(fontSize: AppSizes.s12)),
          ),
      ],
    );
  }
}
