import 'dart:io';

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/team_color_selector.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

typedef TeamDetailsSave = Future<void> Function({
  required String description,
  required String primaryColor,
  required String secondaryColor,
  File? crest,
  String? region,
});

/// Edição do time: escudo, descrição e cores (dono e admin) e, com
/// [regions], a região (só o admin). O nome não muda aqui; [note] explica.
class TeamDetailsForm extends StatefulWidget {
  /// Nulo enquanto carrega (Salvar desabilitado).
  final TeamDTO? team;
  final bool saving;
  final TeamDetailsSave onSave;

  /// Regiões para escolher; nulo = sem seletor de região.
  final List<String>? regions;

  /// Aviso no rodapé (ex.: como trocar o nome).
  final String? note;

  const TeamDetailsForm({
    super.key,
    required this.team,
    required this.saving,
    required this.onSave,
    this.regions,
    this.note,
  });

  @override
  State<TeamDetailsForm> createState() => _TeamDetailsFormState();
}

class _TeamDetailsFormState extends State<TeamDetailsForm> {
  late final _description = TextEditingController(text: widget.team?.description);
  File? _crest;

  /// Nulos = ainda não mexeu (vale o do time).
  String? _primary;
  String? _secondary;
  String? _region;

  @override
  void didUpdateWidget(covariant TeamDetailsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Descrição chegou depois (time carregado) e o campo ainda está vazio.
    final description = widget.team?.description ?? '';
    if (_description.text.isEmpty && description.isNotEmpty) _description.text = description;
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _save(TeamDTO team) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await widget.onSave(
      description: _description.text,
      primaryColor: _primary ?? team.primaryColor,
      secondaryColor: _secondary ?? team.secondaryColor,
      crest: _crest,
      region: widget.regions == null ? null : (_region ?? team.region),
    );
    if (mounted) setState(() => _crest = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final team = widget.team;
    final regions = widget.regions;
    final selectedRegion = _region ?? team?.region ?? '';

    return ListView(
      padding: const EdgeInsets.all(AppSizes.s16),
      children: [
        Center(
          child: CirclePhotoPicker(
            file: _crest,
            currentUrl: team?.imageUrl ?? '',
            addLabel: l10n.teamRequestCrestAdd,
            emptyIcon: Icons.shield_outlined,
            size: AppSizes.s100,
            onPicked: (file) => setState(() => _crest = file),
            onRemove: () => setState(() => _crest = null),
          ),
        ),
        if (regions != null && regions.isNotEmpty) ...[
          const SizedBox(height: AppSizes.s20),
          Text(l10n.teamEditRegionLabel, style: AppTypography.label(color: AppColors.textPrimary)),
          const SizedBox(height: AppSizes.s8),
          Wrap(
            spacing: AppSizes.s8,
            runSpacing: AppSizes.s8,
            children: [
              for (final region in regions)
                ArenaChoiceChip(
                  label: region,
                  icon: Icons.place_outlined,
                  selected: region == selectedRegion,
                  onTap: () => setState(() => _region = region),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSizes.s20),
        TextField(
          controller: _description,
          minLines: 3,
          maxLines: 6,
          maxLength: 300,
          textCapitalization: TextCapitalization.sentences,
          decoration: arenaInputDecoration(label: l10n.teamRequestDescriptionLabel, icon: Icons.notes_rounded),
        ),
        TeamColorsPicker(
          primary: _primary ?? team?.primaryColor ?? '',
          secondary: _secondary ?? team?.secondaryColor ?? '',
          onPrimaryChanged: (hex) => setState(() => _primary = hex),
          onSecondaryChanged: (hex) => setState(() => _secondary = hex),
        ),
        if (widget.note != null) ...[
          const SizedBox(height: AppSizes.s16),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: AppSizes.s18, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.s6),
              Expanded(
                child: Text(widget.note!, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSizes.s20),
        ArenaButton.primary(
          title: l10n.commonSave,
          isLoading: widget.saving,
          function: widget.saving || team == null ? null : () => _save(team),
        ),
      ],
    );
  }
}
