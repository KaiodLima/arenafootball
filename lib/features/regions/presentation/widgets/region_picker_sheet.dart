import 'package:flutter/material.dart';
import 'package:arena_soccer/features/regions/domain/region_choices.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Folha "Escolha a região": busca (com muitas regiões), as recentes em
/// chips e a lista em ordem alfabética com a atual marcada. Devolve a
/// escolhida (nula = fechou sem escolher).
Future<String?> showRegionPicker(
  BuildContext context, {
  required List<String> regions,
  required String selected,
  List<String> recent = const [],
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
    ),
    builder: (_) => _RegionPicker(regions: regions, selected: selected, recent: recent),
  );
}

class _RegionPicker extends StatefulWidget {
  /// Com mais regiões que isto, aparece a busca.
  static const int searchFrom = 7;

  final List<String> regions;
  final String selected;
  final List<String> recent;

  const _RegionPicker({required this.regions, required this.selected, required this.recent});

  @override
  State<_RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends State<_RegionPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final searching = _query.trim().isNotEmpty;
    final list = RegionChoices.search(widget.regions, _query);
    final recent = searching
        ? const <String>[]
        : RegionChoices.recentToShow(widget.recent, selected: widget.selected, regions: widget.regions);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppSizes.s10),
                  width: AppSizes.s40,
                  height: AppSizes.s4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSizes.s2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s16, AppSizes.s20, AppSizes.s8),
                child: Text(l10n.regionPickerTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s20)),
              ),
              if (widget.regions.length >= _RegionPicker.searchFrom)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s4, AppSizes.s20, AppSizes.s8),
                  child: ArenaTextField(
                    hintText: l10n.regionPickerSearch,
                    icon: const Icon(Icons.search_rounded),
                    onChaged: (value) => setState(() => _query = value),
                  ),
                ),
              if (recent.isNotEmpty) ...[
                _SectionLabel(l10n.regionPickerRecent),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
                  child: Wrap(
                    spacing: AppSizes.s8,
                    runSpacing: AppSizes.s8,
                    children: [
                      for (final region in recent)
                        ArenaChoiceChip(
                          label: region,
                          icon: Icons.history_rounded,
                          selected: false,
                          onTap: () => Navigator.pop(context, region),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.s8),
              ],
              _SectionLabel(l10n.regionPickerAll),
              Flexible(
                child: list.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSizes.s24),
                        child: Text(
                          l10n.regionPickerEmpty,
                          textAlign: TextAlign.center,
                          style: AppTypography.subtitle(),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: AppSizes.s8),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final region = list[i];
                          final selected = region == widget.selected;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
                            leading: Icon(
                              selected ? Icons.location_on_rounded : Icons.location_on_outlined,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            title: Text(
                              region,
                              style: AppTypography.body(color: selected ? AppColors.primary : AppColors.textPrimary)
                                  .copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
                            ),
                            trailing:
                                selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                            onTap: () => Navigator.pop(context, region),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s8, AppSizes.s20, AppSizes.s6),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12, letterSpacing: 0.6),
      ),
    );
  }
}
