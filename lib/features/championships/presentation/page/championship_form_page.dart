import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/championship_rules_file.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_form_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_form_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/team_multi_select_grid.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/picked_image_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Cadastro/edição de campeonato (admin), numa tela só em seções: banner,
/// dados, times participantes, regulamento (PDF) e premiação.
class ChampionshipFormPage extends StatefulWidget {
  /// Campeonato a editar; nulo = novo.
  final ChampionshipDTO? championship;

  const ChampionshipFormPage({super.key, this.championship});

  @override
  State<ChampionshipFormPage> createState() => _ChampionshipFormPageState();
}

class _ChampionshipFormPageState extends State<ChampionshipFormPage> {
  static const int _maxPdfBytes = 10 * 1024 * 1024;

  late final ChampionshipFormCubit _cubit;
  late final String _initialRegion;
  late final _title = TextEditingController(text: widget.championship?.title);
  late final _description = TextEditingController(text: widget.championship?.description);
  late final _rulesSummary = TextEditingController(text: widget.championship?.rules);
  late final _prize1 = TextEditingController(text: widget.championship?.firstPrize);
  late final _prize2 = TextEditingController(text: widget.championship?.secondPrize);
  late final _prize3 = TextEditingController(text: widget.championship?.thirdPrize);
  late final _prizeTopScorer = TextEditingController(text: widget.championship?.topScorerPrize);
  late final _prizeGoalkeeper = TextEditingController(text: widget.championship?.goalkeeperPrize);

  /// Erros só depois da primeira tentativa de salvar.
  bool _showErrors = false;

  /// Liberado para fechar sem perguntar (após confirmar o descarte).
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ChampionshipFormCubit>(context);
    _initialRegion = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    _cubit.load(initial: widget.championship, initialRegion: _initialRegion);
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _rulesSummary,
      _prize1,
      _prize2,
      _prize3,
      _prizeTopScorer,
      _prizeGoalkeeper,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickRules(AppLocalizations l10n) async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['pdf']);
      if (file == null || !mounted) return;
      final size = file.lengthSync() ?? await file.length() ?? 0;
      if (size > _maxPdfBytes) {
        if (mounted) showSnackBar(context: context, message: l10n.championshipFormRulesTooBig, isSuccess: false);
        return;
      }
      final bytes = await file.readAsBytes();
      _cubit.setRulesFile(ChampionshipRulesFile(bytes: bytes, name: file.name));
    } catch (e) {
      AppLogger.e('pickRules', name: 'ChampionshipFormPage', error: e);
      if (mounted) showSnackBar(context: context, message: l10n.commonGenericError, isSuccess: false);
    }
  }

  void _submit(ChampionshipFormData form) {
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

    return BlocConsumer<ChampionshipFormCubit, ChampionshipFormState>(
      listener: (context, state) {
        if (state is SavedChampionshipFormState) {
          showSnackBar(
            context: context,
            message: state.created ? l10n.championshipFormCreated : l10n.championshipFormSaved,
          );
          setState(() => _leaving = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
        }
        if (state is ErrorChampionshipFormState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final form = state.form;
        final submitting = state is SubmittingChampionshipFormState;

        return PopScope(
          canPop: _leaving || !form.dirty,
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
                form.isEditing ? l10n.championshipFormEditTitle : l10n.championshipFormNewTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
            ),
            bottomNavigationBar: state is LoadingChampionshipFormState || state is LoadErrorChampionshipFormState
                ? null
                : ArenaSubmitBar(
                    title: form.isEditing ? l10n.commonSave : l10n.championshipFormSubmitCreate,
                    loading: submitting,
                    onPressed: () => _submit(form),
                  ),
            body: switch (state) {
              LoadingChampionshipFormState() => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              LoadErrorChampionshipFormState() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ArenaEmptyState.error(message: l10n.championshipFormLoadError),
                    TextButton(
                      onPressed: () => _cubit.retry(initial: widget.championship, initialRegion: _initialRegion),
                      child: Text(l10n.commonTryAgain),
                    ),
                  ],
                ),
              _ => _buildForm(form, l10n),
            },
          ),
        );
      },
    );
  }

  Widget _buildForm(ChampionshipFormData form, AppLocalizations l10n) {
    final error = _showErrors ? form.error : null;
    final base = form.base;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
      children: [
        // Banner
        PickedImageField(file: form.banner, currentUrl: base.imageUrl, onPicked: _cubit.setBanner),
        const SizedBox(height: AppSizes.s16),

        // Dados
        FormSection(
          title: l10n.championshipFormSectionData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                onChanged: _cubit.changeTitle,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                decoration: arenaInputDecoration(
                  label: l10n.championshipFormTitleLabel,
                  icon: Icons.emoji_events_outlined,
                  errorText: error == ChampionshipFormError.title ? l10n.championshipFormTitleRequired : null,
                ),
              ),
              const SizedBox(height: AppSizes.s4),
              _Label(l10n.registerRegionLabel),
              _Chips(
                values: form.regions,
                selected: base.region,
                icon: Icons.place_outlined,
                onSelected: _cubit.selectRegion,
              ),
              const SizedBox(height: AppSizes.s14),
              _Label(l10n.championshipFormSeasonLabel),
              _Chips(values: form.seasons, selected: base.season, onSelected: _cubit.selectSeason),
              const SizedBox(height: AppSizes.s16),
              TextField(
                controller: _description,
                onChanged: _cubit.changeDescription,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: arenaInputDecoration(
                  label: l10n.championshipFormDescriptionLabel,
                  icon: Icons.notes_rounded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s16),

        // Times participantes
        FormSection(
          title: l10n.championshipFormSectionTeams,
          trailing: l10n.championshipFormTeamsSelected(form.selectedTeams.length),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (form.loadingTeams)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.s20),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (form.teams.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                  child: Text(l10n.championshipFormTeamsEmpty, style: AppTypography.subtitle()),
                )
              else ...[
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _cubit.selectAllTeams,
                      icon: const Icon(Icons.done_all_rounded, size: AppSizes.s18),
                      label: Text(l10n.championshipFormTeamsAll),
                    ),
                    TextButton.icon(
                      onPressed: form.selectedTeams.isEmpty ? null : _cubit.clearTeams,
                      icon: const Icon(Icons.clear_all_rounded, size: AppSizes.s18),
                      label: Text(l10n.championshipFormTeamsClear),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s4),
                TeamMultiSelectGrid(teams: form.teams, selected: form.selectedTeams, onToggle: _cubit.toggleTeam),
              ],
              if (error == ChampionshipFormError.teams)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.s8),
                  child: Text(
                    l10n.championshipFormTeamsRequired,
                    style: AppTypography.body(color: AppColors.danger).copyWith(fontSize: AppSizes.s12),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s16),

        // Regulamento
        FormSection(
          title: l10n.championshipFormSectionRules,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.championshipFormRulesHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              const SizedBox(height: AppSizes.s12),
              if (form.hasRules)
                _RulesFileTile(
                  name: form.rulesName,
                  onReplace: () => _pickRules(l10n),
                  onRemove: _cubit.removeRules,
                )
              else
                OutlinedButton.icon(
                  onPressed: () => _pickRules(l10n),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.fieldRadius)),
                  ),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(l10n.championshipFormRulesAttach),
                ),
              const SizedBox(height: AppSizes.s16),
              TextField(
                controller: _rulesSummary,
                onChanged: _cubit.changeRulesSummary,
                minLines: 2,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: arenaInputDecoration(
                  label: l10n.championshipFormRulesSummary,
                  icon: Icons.rule_rounded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s16),

        // Premiação (recolhível)
        _PrizesSection(
          initiallyExpanded: [
            base.firstPrize,
            base.secondPrize,
            base.thirdPrize,
            base.topScorerPrize,
            base.goalkeeperPrize
          ].any((p) => p.isNotEmpty),
          fields: [
            (
              _prize1,
              l10n.championshipFormPrize1,
              Icons.looks_one_outlined,
              (String v) => _cubit.changePrizes(first: v)
            ),
            (
              _prize2,
              l10n.championshipFormPrize2,
              Icons.looks_two_outlined,
              (String v) => _cubit.changePrizes(second: v)
            ),
            (_prize3, l10n.championshipFormPrize3, Icons.looks_3_outlined, (String v) => _cubit.changePrizes(third: v)),
            (
              _prizeTopScorer,
              l10n.championshipFormPrizeTopScorer,
              Icons.sports_soccer_rounded,
              (String v) => _cubit.changePrizes(topScorer: v),
            ),
            (
              _prizeGoalkeeper,
              l10n.championshipFormPrizeGoalkeeper,
              Icons.sports_handball_rounded,
              (String v) => _cubit.changePrizes(goalkeeper: v),
            ),
          ],
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s8),
      child: Text(text, style: AppTypography.label(color: AppColors.textPrimary)),
    );
  }
}

class _Chips extends StatelessWidget {
  final List<String> values;
  final String selected;
  final IconData? icon;
  final ValueChanged<String> onSelected;

  const _Chips({required this.values, required this.selected, required this.onSelected, this.icon});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.s8,
      runSpacing: AppSizes.s8,
      children: [
        for (final value in values)
          ArenaChoiceChip(label: value, icon: icon, selected: value == selected, onTap: () => onSelected(value)),
      ],
    );
  }
}

/// PDF anexado: nome do arquivo + trocar/remover.
class _RulesFileTile extends StatelessWidget {
  final String name;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  const _RulesFileTile({required this.name, required this.onReplace, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s8, AppSizes.s4, AppSizes.s8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: AppSizes.s28),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Text(
              name.isEmpty ? l10n.championshipFormSectionRules : name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body().copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(onPressed: onReplace, child: Text(l10n.championshipFormRulesReplace)),
          IconButton(
            tooltip: l10n.championshipFormRulesRemove,
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _PrizesSection extends StatelessWidget {
  final bool initiallyExpanded;
  final List<(TextEditingController, String, IconData, ValueChanged<String>)> fields;

  const _PrizesSection({required this.initiallyExpanded, required this.fields});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: const Icon(Icons.military_tech_outlined, color: AppColors.primaryDark),
          title: Text(l10n.championshipFormSectionPrizes, style: AppTypography.label(color: AppColors.textPrimary)),
          childrenPadding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s16),
          children: [
            for (final (controller, label, icon, onChanged) in fields) ...[
              TextField(
                controller: controller,
                onChanged: onChanged,
                textCapitalization: TextCapitalization.sentences,
                decoration: arenaInputDecoration(label: label, icon: icon),
              ),
              const SizedBox(height: AppSizes.s12),
            ],
          ],
        ),
      ),
    );
  }
}
