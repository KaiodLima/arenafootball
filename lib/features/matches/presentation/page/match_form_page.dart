import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/domain/match_form_hints.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_state.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/date_time_chips.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matchup_picker.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cadastro de partida (admin): região, confronto com escudos (⇄ inverte o
/// mando), data e hora por atalhos ou seletores nativos, local sugerido pelos
/// já usados, aviso de conflito e prévia do card. Placar começa 0 x 0 e a
/// votação fechada. Depois de cadastrar, data/hora/local ficam para a
/// próxima partida da rodada.
class MatchFormPage extends StatefulWidget {
  const MatchFormPage({super.key});

  @override
  State<MatchFormPage> createState() => _MatchFormPageState();
}

class _MatchFormPageState extends State<MatchFormPage> {
  late final MatchFormCubit _cubit;
  final _venueController = TextEditingController();
  final _venueFocus = FocusNode();

  /// Erros só aparecem depois da primeira tentativa de cadastrar.
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<MatchFormCubit>(context);
    _cubit.load(initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  @override
  void dispose() {
    _venueController.dispose();
    _venueFocus.dispose();
    super.dispose();
  }

  Future<void> _pickTeam(MatchFormData form, {required bool home}) async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    final picked = await showTeamPickerSheet(
      context,
      title: home ? l10n.goalHome : l10n.goalAway,
      teams: form.teams,
      selected: home ? form.homeTeam : form.awayTeam,
    );
    if (picked == null) return;
    home ? _cubit.selectHomeTeam(picked) : _cubit.selectAwayTeam(picked);
  }

  void _submit(MatchFormData form) {
    if (!form.canSubmit) {
      FocusScope.of(context).unfocus();
      setState(() => _showErrors = true);
      return;
    }
    FocusScope.of(context).unfocus();
    _cubit.submit();
  }

  String? _teamsError(MatchFormData form, AppLocalizations l10n) {
    if (form.sameTeam) return l10n.goalSameTeam;
    if (_showErrors && form.missing == MatchFormMissing.teams) return l10n.matchFormMissingTeams;
    return null;
  }

  String? _whenError(MatchFormData form, AppLocalizations l10n) {
    if (!_showErrors) return null;
    return switch (form.missing) {
      MatchFormMissing.date => l10n.matchFormMissingDate,
      MatchFormMissing.time => l10n.matchFormMissingTime,
      _ => null,
    };
  }

  String _conflictText(MatchConflict conflict, AppLocalizations l10n) => switch (conflict.type) {
        MatchConflictType.teamSameDay => l10n.matchFormConflictTeam(conflict.subject, conflict.times.join(', ')),
        MatchConflictType.venueTaken => l10n.matchFormConflictVenue(conflict.subject, conflict.times.first),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<MatchFormCubit, MatchFormState>(
      listener: (context, state) {
        if (state is SuccessMatchFormState) {
          setState(() => _showErrors = false);
          showSnackBar(context: context, message: l10n.matchFormSaved);
        }
        if (state is ErrorMatchFormState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final form = state.form;
        final conflicts = form.conflicts;
        final whenError = _whenError(form, l10n);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.maybePop(context)),
            titleSpacing: 0,
            title: Text(
              l10n.matchesFormTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
          ),
          bottomNavigationBar: ArenaSubmitBar(
            title: l10n.matchFormSubmit,
            loading: state is SubmittingMatchFormState,
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
              // Vários campeonatos ao mesmo tempo na região: escolhe em qual entra.
              if (form.championships.length > 1) ...[
                const SizedBox(height: AppSizes.s20),
                _Label(l10n.matchFormChampionship),
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
              ],
              const SizedBox(height: AppSizes.s20),
              _Label(l10n.matchFormMatchup),
              MatchupPicker(
                homeTeam: form.homeTeam,
                awayTeam: form.awayTeam,
                homeCrest: form.crestOf(form.homeTeam),
                awayCrest: form.crestOf(form.awayTeam),
                onPickHome: () => _pickTeam(form, home: true),
                onPickAway: () => _pickTeam(form, home: false),
                onSwap: _cubit.swapTeams,
                errorText: _teamsError(form, l10n),
              ),
              const SizedBox(height: AppSizes.s20),
              _Label(l10n.matchFormWhen),
              MatchDateChips(selected: form.date, onSelected: _cubit.selectDate),
              const SizedBox(height: AppSizes.s10),
              MatchTimeChips(frequent: form.frequentTimes, selected: form.time, onSelected: _cubit.selectTime),
              if (whenError != null) ...[
                const SizedBox(height: AppSizes.s8),
                Text(whenError, style: AppTypography.label(color: AppColors.danger).copyWith(fontSize: AppSizes.s12)),
              ],
              const SizedBox(height: AppSizes.s20),
              _Label(l10n.matchFormWhere),
              _VenuePicker(
                venues: form.frequentVenues,
                selected: form.venue,
                custom: form.customVenue,
                controller: _venueController,
                focusNode: _venueFocus,
                onSelected: _cubit.selectVenue,
                onNew: () {
                  _venueController.clear();
                  _cubit.startCustomVenue();
                  // O campo só aparece no próximo frame.
                  WidgetsBinding.instance.addPostFrameCallback((_) => _venueFocus.requestFocus());
                },
                onChanged: _cubit.changeVenue,
              ),
              for (final conflict in conflicts) ...[
                const SizedBox(height: AppSizes.s10),
                _ConflictBanner(text: _conflictText(conflict, l10n)),
              ],
              if (form.homeTeam != null && form.awayTeam != null && !form.sameTeam) ...[
                const SizedBox(height: AppSizes.s24),
                _Label(l10n.matchFormPreview, trailing: form.date),
                MatchCard(
                  match: form.toMatch(),
                  isAdmin: false,
                  showVoting: false,
                  homeCrest: form.crestOf(form.homeTeam),
                  awayCrest: form.crestOf(form.awayTeam),
                  onVotingTap: () {},
                  onToggleVoting: () {},
                  onEditScore: () {},
                  onDelete: () {},
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final String? trailing;

  const _Label(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    final style =
        AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12, letterSpacing: 1.1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, 0, AppSizes.s4, AppSizes.s8),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: style)),
          if (trailing != null && trailing!.isNotEmpty) Text(trailing!, style: style),
        ],
      ),
    );
  }
}

/// Locais já usados em chips + "Novo local" (campo de texto).
class _VenuePicker extends StatelessWidget {
  final List<String> venues;
  final String selected;
  final bool custom;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSelected;
  final VoidCallback onNew;
  final ValueChanged<String> onChanged;

  const _VenuePicker({
    required this.venues,
    required this.selected,
    required this.custom,
    required this.controller,
    required this.focusNode,
    required this.onSelected,
    required this.onNew,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSizes.s8,
          runSpacing: AppSizes.s8,
          children: [
            for (final venue in venues)
              ArenaChoiceChip(
                label: venue,
                icon: Icons.stadium_outlined,
                selected: !custom && venue == selected,
                onTap: () => onSelected(venue),
              ),
            ArenaChoiceChip(label: l10n.matchFormNewVenue, icon: Icons.add_rounded, selected: custom, onTap: onNew),
          ],
        ),
        if (custom || venues.isEmpty) ...[
          const SizedBox(height: AppSizes.s10),
          TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            textCapitalization: TextCapitalization.words,
            style: AppTypography.body(),
            decoration: arenaInputDecoration(label: l10n.matchFormVenueHint, icon: Icons.stadium_outlined),
          ),
        ],
      ],
    );
  }
}

class _ConflictBanner extends StatelessWidget {
  final String text;

  const _ConflictBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.s12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: AppSizes.s20),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            child: Text(text, style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
          ),
        ],
      ),
    );
  }
}
