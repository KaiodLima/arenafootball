import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Uma competição na lista: [blockedReason] não nulo = aparece desabilitada
/// com o motivo (ex.: o atleta joga por outro time nela).
class ChampionshipChecklistItem {
  final ChampionshipDTO championship;
  final String? blockedReason;

  const ChampionshipChecklistItem(this.championship, {this.blockedReason});
}

/// Folha com as competições para marcar/desmarcar (time ou atleta). Devolve
/// os `id_campeonato` marcados ao salvar; nulo se fechar sem salvar.
Future<Set<int>?> showChampionshipChecklistSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<ChampionshipChecklistItem> items,
  required Set<int> selected,
}) {
  return showModalBottomSheet<Set<int>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ChecklistSheet(title: title, subtitle: subtitle, items: items, initial: selected),
  );
}

class _ChecklistSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<ChampionshipChecklistItem> items;
  final Set<int> initial;

  const _ChecklistSheet({required this.title, required this.subtitle, required this.items, required this.initial});

  @override
  State<_ChecklistSheet> createState() => _ChecklistSheetState();
}

class _ChecklistSheetState extends State<_ChecklistSheet> {
  late final Set<int> _selected = {...widget.initial};

  bool get _changed => _selected.length != widget.initial.length || !_selected.containsAll(widget.initial);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
              if (widget.subtitle != null) ...[
                const SizedBox(height: AppSizes.s4),
                Text(widget.subtitle!, style: AppTypography.subtitle()),
              ],
              const SizedBox(height: AppSizes.s12),
              if (widget.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.s20),
                  child: Text(l10n.enrollNoChampionships, style: AppTypography.subtitle()),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final item in widget.items)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          value: item.blockedReason == null && _selected.contains(item.championship.championshipId),
                          onChanged: item.blockedReason != null
                              ? null
                              : (checked) => setState(() => checked == true
                                  ? _selected.add(item.championship.championshipId)
                                  : _selected.remove(item.championship.championshipId)),
                          title:
                              Text(item.championship.title, style: AppTypography.label(color: AppColors.textPrimary)),
                          subtitle: Text(
                            item.blockedReason ??
                                [
                                  item.championship.isIntermunicipal
                                      ? l10n.championshipScopeIntermunicipal
                                      : l10n.championshipScopeMunicipal,
                                  item.championship.region,
                                ].join(' · '),
                            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSizes.s12),
              ArenaButton.primary(
                title: l10n.commonSave,
                function: _changed ? () => Navigator.pop(context, _selected) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
