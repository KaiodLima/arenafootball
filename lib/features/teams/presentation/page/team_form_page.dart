import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_state.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/region_teams_strip.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/team_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_color_selector.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cadastro de time (admin): escudo, região, nome e descrição, com prévia do
/// card da aba Times, aviso de nome repetido e a lista dos times já
/// cadastrados na região. Grava o time e a linha dele na classificação; a
/// tela limpa e continua aberta para o próximo. Sair com algo preenchido
/// pede confirmação.
class TeamFormPage extends StatefulWidget {
  const TeamFormPage({super.key});

  @override
  State<TeamFormPage> createState() => _TeamFormPageState();
}

class _TeamFormPageState extends State<TeamFormPage> {
  static const int _nameMaxLength = 40;

  late final TeamFormCubit _cubit;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// Erro do nome só depois da primeira tentativa de cadastrar.
  bool _showErrors = false;

  /// Liberado para fechar sem perguntar (após confirmar o descarte).
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<TeamFormCubit>(context);
    _cubit.load(initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(TeamFormData form) {
    FocusScope.of(context).unfocus();
    if (!form.canSubmit) {
      setState(() => _showErrors = true);
      return;
    }
    _cubit.submit();
  }

  Future<void> _confirmDiscard(AppLocalizations l10n) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newsDiscardTitle),
        content: Text(l10n.newsDiscardMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.newsDiscardKeep)),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.newsDiscardConfirm, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
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

    return BlocConsumer<TeamFormCubit, TeamFormState>(
      listener: (context, state) {
        if (state is SuccessTeamFormState) {
          _nameController.clear();
          _descriptionController.clear();
          setState(() => _showErrors = false);
          showSnackBar(context: context, message: l10n.teamsCreated);
        }
        if (state is ErrorTeamFormState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final form = state.form;
        final submitting = state is SubmittingTeamFormState;
        final duplicate = form.duplicate;
        final previewName = form.name.trim();

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
                l10n.teamsFormTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
            ),
            bottomNavigationBar: ArenaSubmitBar(
              title: l10n.teamsSubmit,
              loading: submitting,
              onPressed: () => _submit(form),
            ),
            body: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s24),
              children: [
                Center(
                    child: CirclePhotoPicker(
                  file: form.crest,
                  addLabel: l10n.teamsCrestAdd,
                  onPicked: _cubit.setCrest,
                  onRemove: _cubit.clearCrest,
                )),
                const SizedBox(height: AppSizes.s20),
                Wrap(
                  spacing: AppSizes.s8,
                  runSpacing: AppSizes.s8,
                  alignment: WrapAlignment.center,
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
                const SizedBox(height: AppSizes.s20),
                FormSection(
                  title: l10n.teamsSectionData,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        onChanged: _cubit.changeName,
                        maxLength: _nameMaxLength,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                        decoration: arenaInputDecoration(
                          label: l10n.teamsNameLabel,
                          icon: Icons.shield_outlined,
                          errorText: _showErrors && !form.isNameValid ? l10n.teamsNameRequired : null,
                        ),
                      ),
                      if (duplicate != null) ...[
                        _DuplicateWarning(text: l10n.teamsDuplicate(duplicate.name)),
                        const SizedBox(height: AppSizes.s12),
                      ],
                      const SizedBox(height: AppSizes.s4),
                      TextField(
                        controller: _descriptionController,
                        onChanged: _cubit.changeDescription,
                        minLines: 1,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTypography.body(),
                        decoration: arenaInputDecoration(
                          label: l10n.teamsDescriptionLabel,
                          hintText: l10n.teamsDescriptionHint,
                          icon: Icons.notes_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.s16),
                FormSection(
                  title: l10n.teamColorsSection,
                  child: TeamColorsPicker(
                    primary: form.primaryColor,
                    secondary: form.secondaryColor,
                    onPrimaryChanged: _cubit.setPrimaryColor,
                    onSecondaryChanged: _cubit.setSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppSizes.s16),
                if (previewName.isNotEmpty) ...[
                  _Label(l10n.teamsPreview),
                  TeamCard(
                    team: TeamDTO(id: '', name: previewName, description: form.description.trim()),
                    crestFile: form.crest,
                  ),
                  const SizedBox(height: AppSizes.s12),
                ],
                if (form.existing.isNotEmpty) ...[
                  _Label(l10n.teamsInRegion(form.existing.length)),
                  RegionTeamsStrip(teams: form.existing, highlightId: duplicate?.id),
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
