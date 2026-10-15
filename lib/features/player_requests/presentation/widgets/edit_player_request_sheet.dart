import 'package:flutter/material.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/players/presentation/widgets/team_select_tile.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Edição do admin antes de responder: nome, time (da mesma região) e
/// posição. Devolve o pedido editado ou `null` se fechar.
Future<PlayerRequestDTO?> showEditPlayerRequestSheet(
  BuildContext context, {
  required PlayerRequestDTO request,
  required List<TeamDTO> teams,
}) {
  return showModalBottomSheet<PlayerRequestDTO>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _EditSheet(request: request, teams: teams),
  );
}

class _EditSheet extends StatefulWidget {
  final PlayerRequestDTO request;
  final List<TeamDTO> teams;

  const _EditSheet({required this.request, required this.teams});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _name = TextEditingController(text: widget.request.name);
  late String _team = widget.request.team;
  late String _teamId = widget.request.teamId;
  late PlayerPosition? _position = widget.request.position;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String? _crestOf(String team) {
    for (final t in widget.teams) {
      if (t.name == team) return t.imageUrl;
    }
    return null;
  }

  Future<void> _pickTeam(AppLocalizations l10n) async {
    final picked = await showTeamPickerSheet(
      context,
      title: l10n.playersTeam,
      teams: widget.teams,
      selected: _team,
      selectedId: _teamId,
    );
    if (picked != null) {
      setState(() {
        _team = picked.name;
        _teamId = picked.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nameValid = _name.text.trim().length >= 3;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.s20,
        0,
        AppSizes.s20,
        AppSizes.s20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.playerRequestEdit, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
            const SizedBox(height: AppSizes.s16),
            TextField(
              controller: _name,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: arenaInputDecoration(
                label: l10n.playerRequestNameLabel,
                icon: Icons.person_outline_rounded,
                errorText: nameValid ? null : l10n.playersNameRequired,
              ),
            ),
            TeamSelectTile(
              label: l10n.playersTeam,
              team: _team,
              crest: _crestOf(_team),
              placeholder: l10n.goalPickTeam,
              onTap: () => _pickTeam(l10n),
            ),
            const SizedBox(height: AppSizes.s16),
            Text(l10n.playerRequestPositionLabel, style: AppTypography.label(color: AppColors.textPrimary)),
            const SizedBox(height: AppSizes.s10),
            Wrap(
              spacing: AppSizes.s8,
              runSpacing: AppSizes.s8,
              children: [
                for (final position in PlayerPosition.values)
                  ArenaChoiceChip(
                    label: playerPositionLabel(l10n, position),
                    selected: position == _position,
                    onTap: () => setState(() => _position = position),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.s24),
            ArenaButton.primary(
              title: l10n.commonSave,
              function: nameValid
                  ? () => Navigator.pop(
                        context,
                        widget.request
                            .copyWith(name: _name.text.trim(), team: _team, teamId: _teamId, position: _position),
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
