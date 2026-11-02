import 'package:flutter/material.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_picker_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Campo de escolha da região nos formulários (como o de campeonato): uma
/// linha só, qualquer que seja o número de regiões. O toque abre a folha
/// `showRegionPicker` (busca, recentes, lista alfabética); [onChanged] só
/// dispara quando a região muda. Com [allLabel], dá para escolher "Todas
/// as regiões" (região '').
class RegionSelectTile extends StatelessWidget {
  final String label;
  final String region;
  final List<String> regions;
  final List<String> recent;
  final ValueChanged<String> onChanged;
  final String? allLabel;

  const RegionSelectTile({
    super.key,
    required this.label,
    required this.region,
    required this.regions,
    required this.onChanged,
    this.recent = const [],
    this.allLabel,
  });

  Future<void> _pick(BuildContext context) async {
    final chosen = await showRegionPicker(
      context,
      regions: regions.isEmpty && region.isNotEmpty ? [region] : regions,
      selected: region,
      recent: recent,
      allLabel: allLabel,
    );
    if (chosen != null && chosen != region) onChanged(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.fieldRadius);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: const BorderSide(color: AppColors.greyLight)),
      child: InkWell(
        borderRadius: radius,
        onTap: () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s12, AppSizes.s10),
          child: Row(
            children: [
              Container(
                width: AppSizes.s40,
                height: AppSizes.s40,
                decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                child: Icon(
                  region.isEmpty && allLabel != null ? Icons.public_rounded : Icons.location_on_rounded,
                  color: AppColors.primaryDark,
                  size: AppSizes.s20,
                ),
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                    Text(
                      region.isEmpty ? (allLabel ?? '') : region,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
