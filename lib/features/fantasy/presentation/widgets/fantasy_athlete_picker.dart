import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Filtro da folha: atletas da [slot] (vaga fixa = a posição dela; livre =
/// [position] escolhida nas fichas, nula = todas), do time [teamId] (vazio =
/// todos) e com o nome contendo [query] (sem acento). Os mais goleadores
/// primeiro, como vieram.
List<FantasyAthleteDTO> filterFantasyAthletes(
  List<FantasyAthleteDTO> athletes, {
  required FantasySlot slot,
  FantasySlot? position,
  String teamId = '',
  String query = '',
}) {
  final text = foldForSearch(query.trim());
  return [
    for (final a in athletes)
      if (slot.accepts(a.position) &&
          (position == null || a.slot == position) &&
          (teamId.isEmpty || a.teamId == teamId) &&
          (text.isEmpty || foldForSearch(a.name).contains(text)))
        a,
  ];
}

/// Folha "Escolha o …": devolve o id do atleta escolhido para a [slot].
Future<String?> showFantasyAthletePicker(
  BuildContext context, {
  required FantasySlot slot,
  required List<FantasyAthleteDTO> athletes,
  required FantasyLineup lineup,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: _Picker(slot: slot, athletes: athletes, lineup: lineup),
      ),
    ),
  );
}

class _Picker extends StatefulWidget {
  final FantasySlot slot;
  final List<FantasyAthleteDTO> athletes;
  final FantasyLineup lineup;

  const _Picker({required this.slot, required this.athletes, required this.lineup});

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  String _query = '';
  FantasySlot? _position;
  TeamDTO? _team;

  List<TeamDTO> get _teams {
    final byId = <String, TeamDTO>{};
    for (final a in widget.athletes) {
      if (widget.slot.accepts(a.position)) {
        byId.putIfAbsent(a.teamId, () => TeamDTO(id: a.teamId, name: a.team, region: ''));
      }
    }
    return byId.values.toList()..sort((a, b) => foldForSearch(a.name).compareTo(foldForSearch(b.name)));
  }

  Future<void> _pickTeam() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showTeamPickerSheet(
      context,
      title: l10n.fantasyFilterTeam,
      teams: _teams,
      selectedId: _team?.id ?? '',
    );
    if (picked != null && mounted) setState(() => _team = picked.id == _team?.id ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = filterFantasyAthletes(
      widget.athletes,
      slot: widget.slot,
      position: _position,
      teamId: _team?.id ?? '',
      query: _query,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
          child: Text(
            fantasyPickTitle(l10n, widget.slot),
            style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
          ),
        ),
        const SizedBox(height: AppSizes.s12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
          child: ArenaSearchField(hint: l10n.fantasySearchAthlete, onChanged: (v) => setState(() => _query = v)),
        ),
        const SizedBox(height: AppSizes.s8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
          child: Wrap(
            spacing: AppSizes.s6,
            runSpacing: AppSizes.s6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Posição só na vaga livre (as outras já são de uma posição).
              if (widget.slot == FantasySlot.flex)
                for (final position in [null, ...FantasySlot.values.where((s) => s != FantasySlot.flex)])
                  ArenaChoiceChip(
                    key: ValueKey('fantasy-filter-${position?.key ?? 'all'}'),
                    label: position == null ? l10n.fantasyFilterAll : fantasySlotLabel(l10n, position),
                    selected: _position == position,
                    onTap: () => setState(() => _position = position),
                  ),
              ActionChip(
                key: const ValueKey('fantasy-filter-team'),
                avatar: const Icon(Icons.shield_outlined, size: AppSizes.s18),
                label: Text(_team?.name ?? l10n.fantasyFilterAllTeams),
                onPressed: _pickTeam,
              ),
              if (_team != null)
                IconButton(
                  tooltip: l10n.fantasyFilterAllTeams,
                  icon: const Icon(Icons.close_rounded, size: AppSizes.s18),
                  onPressed: () => setState(() => _team = null),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s4),
        Expanded(
          child: list.isEmpty
              ? ArenaEmptyState(message: l10n.fantasyNoAthletes, icon: Icons.person_search_rounded)
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSizes.s16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: AppSizes.s72),
                  itemBuilder: (context, index) {
                    final a = list[index];
                    final current = widget.lineup.idAt(widget.slot) == a.id;
                    final elsewhere = !current && widget.lineup.contains(a.id);
                    return ListTile(
                      key: ValueKey('fantasy-athlete-${a.id}'),
                      onTap: () => Navigator.pop(context, a.id),
                      leading: CircleAvatar(
                        radius: AppSizes.s24,
                        backgroundColor: AppColors.inputFill,
                        backgroundImage: a.photoUrl.isEmpty ? null : CachedNetworkImageProvider(a.photoUrl),
                        child: a.photoUrl.isEmpty
                            ? const Icon(Icons.person_rounded, color: AppColors.textSecondary)
                            : null,
                      ),
                      title: Text(a.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(color: AppColors.textPrimary)),
                      subtitle: Text(
                        '${fantasyPositionLabel(l10n, a.position)} · ${a.team}'
                        '${elsewhere ? ' · ${l10n.fantasyInLineup}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                      trailing: current
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : Text(
                              l10n.fantasyAthleteStats(a.goals, a.assists),
                              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
