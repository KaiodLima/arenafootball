import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Municipal · Floresta" / "Intermunicipal · Floresta".
String championshipScopeLine(AppLocalizations l10n, ChampionshipDTO championship) => [
      championship.isIntermunicipal ? l10n.championshipScopeIntermunicipal : l10n.championshipScopeMunicipal,
      if (championship.region.isNotEmpty) championship.region,
    ].join(' · ');

/// Miniatura do campeonato: o banner, ou o troféu (amistoso: aperto de mão).
class _ChampionshipThumb extends StatelessWidget {
  final ChampionshipDTO? championship;
  final double size;
  final IconData noneIcon;

  const _ChampionshipThumb(
      {required this.championship, this.size = AppSizes.s44, this.noneIcon = Icons.handshake_outlined});

  @override
  Widget build(BuildContext context) {
    final url = championship?.imageUrl ?? '';
    final icon = Icon(
      championship == null ? noneIcon : Icons.emoji_events_outlined,
      color: AppColors.primaryDark,
      size: size * 0.5,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.s10),
      child: Container(
        width: size,
        height: size,
        color: AppColors.primarySoft,
        alignment: Alignment.center,
        child: url.isEmpty
            ? icon
            : CachedNetworkImage(
                imageUrl: url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => icon,
              ),
      ),
    );
  }
}

/// Campo de escolha do campeonato (como o de time): miniatura + título +
/// abrangência e região; nulo = "Sem campeonato (amistoso)". Abre a lista.
class ChampionshipSelectTile extends StatelessWidget {
  final String label;
  final ChampionshipDTO? championship;
  final VoidCallback onTap;

  /// Texto e ícone quando nenhum está escolhido (padrão: amistoso).
  final String? noneLabel;
  final IconData noneIcon;

  const ChampionshipSelectTile({
    super.key,
    required this.label,
    required this.championship,
    required this.onTap,
    this.noneLabel,
    this.noneIcon = Icons.handshake_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppSizes.fieldRadius);
    final selected = championship;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: const BorderSide(color: AppColors.greyLight)),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s12, AppSizes.s10),
          child: Row(
            children: [
              _ChampionshipThumb(championship: selected, noneIcon: noneIcon),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                    Text(
                      selected?.title ?? noneLabel ?? l10n.matchFormNoChampionship,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
                    ),
                    if (selected != null)
                      Text(
                        championshipScopeLine(l10n, selected),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
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

/// Lista de campeonatos com busca e a opção "Sem campeonato (amistoso)" no
/// topo. Devolve `(id: …)` com o `id_campeonato` escolhido (`null` =
/// amistoso); nulo se fechar sem escolher.
Future<({int? id})?> showChampionshipPickerSheet(
  BuildContext context, {
  required List<ChampionshipDTO> championships,
  int? selectedId,
  String? noneLabel,
  IconData noneIcon = Icons.handshake_outlined,
  bool showNone = true,
}) {
  return showModalBottomSheet<({int? id})>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ChampionshipPicker(
      championships: championships,
      selectedId: selectedId,
      noneLabel: noneLabel,
      noneIcon: noneIcon,
      showNone: showNone,
    ),
  );
}

class _ChampionshipPicker extends StatefulWidget {
  final List<ChampionshipDTO> championships;
  final int? selectedId;
  final String? noneLabel;
  final IconData noneIcon;

  /// Mostra a opção nula (amistoso / todas) no topo.
  final bool showNone;

  const _ChampionshipPicker({
    required this.championships,
    required this.selectedId,
    required this.noneLabel,
    required this.noneIcon,
    required this.showNone,
  });

  @override
  State<_ChampionshipPicker> createState() => _ChampionshipPickerState();
}

class _ChampionshipPickerState extends State<_ChampionshipPicker> {
  String _query = '';

  Widget _tile({required ChampionshipDTO? championship, required bool selected}) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
      leading: _ChampionshipThumb(championship: championship, size: AppSizes.s40, noneIcon: widget.noneIcon),
      title: Text(
        championship?.title ?? widget.noneLabel ?? l10n.matchFormNoChampionship,
        style: AppTypography.body().copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
      ),
      subtitle: championship == null
          ? null
          : Text(championshipScopeLine(l10n, championship),
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      onTap: () => Navigator.pop(context, (id: championship?.championshipId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final term = foldForSearch(_query.trim());
    final list = widget.championships.where((c) => term.isEmpty || foldForSearch(c.title).contains(term)).toList();
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s12),
              child:
                  Text(l10n.matchFormPickChampionship, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
              child: ArenaSearchField(
                  hint: l10n.matchFormChampionshipSearch, onChanged: (v) => setState(() => _query = v)),
            ),
            const SizedBox(height: AppSizes.s8),
            // Amistoso sempre no topo (fora da busca).
            if (widget.showNone) ...[
              _tile(championship: null, selected: widget.selectedId == null),
              const Divider(height: 1),
            ],
            Expanded(
              child: list.isEmpty
                  ? ArenaEmptyState(message: l10n.matchFormChampionshipNoResults, icon: Icons.emoji_events_outlined)
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: AppSizes.s16),
                      itemCount: list.length,
                      itemBuilder: (context, index) =>
                          _tile(championship: list[index], selected: list[index].championshipId == widget.selectedId),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
