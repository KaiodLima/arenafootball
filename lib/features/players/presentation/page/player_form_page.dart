import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_state.dart';
import 'package:arena_soccer/features/players/presentation/widgets/count_stepper.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/players/presentation/widgets/squad_strip.dart';
import 'package:arena_soccer/features/players/presentation/widgets/team_select_tile.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Cadastro de jogador (admin): região, time (com escudo), foto opcional,
/// nome e gols/assistências com − / +, prévia do card do elenco, aviso de
/// nome repetido e o elenco atual do time. Depois de cadastrar, limpa nome,
/// foto e números e mantém o time para o próximo. Sair com algo preenchido
/// pede confirmação.
class PlayerFormPage extends StatefulWidget {
  const PlayerFormPage({super.key});

  @override
  State<PlayerFormPage> createState() => _PlayerFormPageState();
}

class _PlayerFormPageState extends State<PlayerFormPage> {
  static const int _nameMaxLength = 40;

  late final PlayerFormCubit _cubit;
  final _nameController = TextEditingController();

  /// Erros só depois da primeira tentativa de cadastrar.
  bool _showErrors = false;

  /// Liberado para fechar sem perguntar (após confirmar o descarte).
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<PlayerFormCubit>(context);
    _cubit.load(initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTeam(PlayerFormData form) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = AppLocalizations.of(context);
    final picked = await showTeamPickerSheet(
      context,
      title: l10n.playersTeam,
      teams: form.selectableTeams,
      selected: form.selectedTeam,
    );
    if (picked != null) _cubit.selectTeam(picked.name);
  }

  void _submit(PlayerFormData form) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (form.error != null) {
      setState(() => _showErrors = true);
      return;
    }
    _cubit.submit();
  }

  Future<void> _confirmDiscard(AppLocalizations l10n) async {
    final discard = await showArenaConfirm(
      context,
      title: l10n.newsDiscardTitle,
      message: l10n.newsDiscardMessage,
      confirmLabel: l10n.newsDiscardConfirm,
      cancelLabel: l10n.newsDiscardKeep,
      icon: Icons.delete_sweep_outlined,
      tone: ArenaAlertTone.danger,
    );
    if (!discard || !mounted) return;
    // Sem isso o teclado do campo de nome continua aberto na tela anterior.
    FocusManager.instance.primaryFocus?.unfocus();
    // O PopScope só aceita depois de reconstruir com canPop verdadeiro.
    setState(() => _leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PlayerFormCubit, PlayerFormState>(
      listener: (context, state) {
        if (state is SuccessPlayerFormState) {
          _nameController.clear();
          setState(() => _showErrors = false);
          showSnackBar(context: context, message: l10n.playersCreated);
        }
        if (state is ErrorPlayerFormState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final form = state.form;
        final submitting = state is SubmittingPlayerFormState;
        final error = _showErrors ? form.error : null;
        final duplicate = form.duplicate;
        final team = form.selectedTeam;

        return PopScope(
          canPop: _leaving || !form.isDirty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !submitting) _confirmDiscard(l10n);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              surfaceTintColor: AppColors.transparent,
              leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.maybePop(context)),
              titleSpacing: 0,
              title: Text(
                l10n.playersFormTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
            ),
            bottomNavigationBar: ArenaSubmitBar(
              title: l10n.playersSubmit,
              loading: submitting,
              onPressed: () => _submit(form),
            ),
            body: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
              children: [
                Wrap(
                  spacing: AppSizes.s8,
                  runSpacing: AppSizes.s8,
                  children: [
                    for (final region in form.regions)
                      ArenaChoiceChip(
                        label: region,
                        icon: Icons.place_outlined,
                        selected: region == form.selectedRegion,
                        onTap: () => _cubit.selectRegion(region),
                      ),
                  ],
                ),
                // Competição em que o atleta entra (os times são os dela).
                if (form.championships.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s16),
                  Wrap(
                    spacing: AppSizes.s8,
                    runSpacing: AppSizes.s8,
                    children: [
                      for (final championship in form.championships)
                        ArenaChoiceChip(
                          label: championship.title,
                          icon: Icons.emoji_events_outlined,
                          selected: championship.championshipId == form.championshipId,
                          onTap: () => _cubit.selectChampionship(championship.championshipId),
                        ),
                    ],
                  ),
                  if (error == PlayerFormError.championship)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.s6, left: AppSizes.s12),
                      child: Text(
                        l10n.playerRequestChampionshipRequired,
                        style: AppTypography.body(color: AppColors.danger).copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                ],
                const SizedBox(height: AppSizes.s16),
                TeamSelectTile(
                  label: l10n.playersTeam,
                  team: team,
                  crest: form.crestOf(team),
                  placeholder: l10n.goalPickTeam,
                  errorText: error == PlayerFormError.team ? l10n.playersTeamRequired : null,
                  onTap: () => _pickTeam(form),
                ),
                const SizedBox(height: AppSizes.s20),
                Center(
                  child: CirclePhotoPicker(
                    file: form.photo,
                    addLabel: l10n.playersPhotoAdd,
                    emptyIcon: Icons.add_a_photo_outlined,
                    size: AppSizes.s100,
                    onPicked: _cubit.setPhoto,
                    onRemove: _cubit.clearPhoto,
                  ),
                ),
                const SizedBox(height: AppSizes.s20),
                FormSection(
                  title: l10n.playersSectionData,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        onChanged: _cubit.changeName,
                        maxLength: _nameMaxLength,
                        textCapitalization: TextCapitalization.words,
                        style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                        decoration: arenaInputDecoration(
                          label: l10n.playersNameLabel,
                          icon: Icons.person_outline_rounded,
                          errorText: error == PlayerFormError.name ? l10n.playersNameRequired : null,
                        ),
                      ),
                      if (duplicate != null && team != null) ...[
                        _DuplicateWarning(text: l10n.playersDuplicate(duplicate.name, team)),
                        const SizedBox(height: AppSizes.s12),
                      ],
                      CountStepper(
                        icon: Icons.sports_soccer_rounded,
                        label: l10n.playersGoalsLabel,
                        value: form.goals,
                        max: PlayerFormData.maxCount,
                        onIncrement: _cubit.incrementGoals,
                        onDecrement: _cubit.decrementGoals,
                      ),
                      const SizedBox(height: AppSizes.s12),
                      CountStepper(
                        icon: Icons.assistant_rounded,
                        label: l10n.playersAssistsLabel,
                        value: form.assists,
                        max: PlayerFormData.maxCount,
                        onIncrement: _cubit.incrementAssists,
                        onDecrement: _cubit.decrementAssists,
                      ),
                    ],
                  ),
                ),
                if (form.name.trim().isNotEmpty) ...[
                  _Label(l10n.playersPreview),
                  PlayerCard(
                    player: PlayerDTO(
                      name: form.name.trim(),
                      team: team ?? '',
                      goals: form.goals,
                      assists: form.assists,
                    ),
                    isTopScorer: false,
                    photoFile: form.photo,
                  ),
                  const SizedBox(height: AppSizes.s8),
                ],
                if (team != null && form.squad.isNotEmpty) ...[
                  _Label(l10n.playersSquadOf(team, form.squad.length)),
                  SquadStrip(players: form.squad, highlightId: duplicate?.id),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, 0, AppSizes.s4, AppSizes.s8),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12, letterSpacing: 1.1),
      ),
    );
  }
}

class _DuplicateWarning extends StatelessWidget {
  final String text;

  const _DuplicateWarning({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.s10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.s12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: AppSizes.s20),
          const SizedBox(width: AppSizes.s8),
          Expanded(child: Text(text, style: AppTypography.body().copyWith(fontSize: AppSizes.s14))),
        ],
      ),
    );
  }
}
