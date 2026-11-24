import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/scoring/presentation/bloc/scoring_settings_cubit.dart';
import 'package:arena_soccer/features/scoring/presentation/widgets/scoring_table_editor.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel do admin → "Pontuações": a tabela padrão do Arena Fantasy
/// (`config/pontuacao_fantasy`) e os pontos do bolão (`config/bolao`).
class ScoringSettingsPage extends StatefulWidget {
  const ScoringSettingsPage({super.key});

  @override
  State<ScoringSettingsPage> createState() => _ScoringSettingsPageState();
}

class _ScoringSettingsPageState extends State<ScoringSettingsPage> {
  ScoringSettingsCubit get _cubit => context.read<ScoringSettingsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.white,
          surfaceTintColor: AppColors.transparent,
          titleSpacing: 0,
          title: Text(l10n.scoringTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20)),
          bottom: TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.whiteSoft,
            tabs: [
              Tab(key: const ValueKey('scoring-tab-fantasy'), text: l10n.scoringTabFantasy),
              Tab(key: const ValueKey('scoring-tab-bolao'), text: l10n.scoringTabBolao),
            ],
          ),
        ),
        body: BlocConsumer<ScoringSettingsCubit, ScoringSettingsState>(
          listenWhen: (_, current) => current.result != ScoringSaveResult.none,
          listener: (context, state) => showSnackBar(
            context: context,
            message:
                state.result == ScoringSaveResult.saved ? l10n.scoringSaved : (state.failure ?? l10n.scoringSaveError),
            isSuccess: state.result == ScoringSaveResult.saved,
          ),
          builder: (context, state) {
            if (!state.loaded) return const Center(child: CircularProgressIndicator());
            return TabBarView(
              children: [
                _FantasyTab(state: state, cubit: _cubit),
                _BolaoTab(state: state, cubit: _cubit),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FantasyTab extends StatelessWidget {
  final ScoringSettingsState state;
  final ScoringSettingsCubit cubit;

  const _FantasyTab({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, safeBottom(context, AppSizes.s24)),
      children: [
        Text(l10n.scoringFantasyIntro, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14)),
        const SizedBox(height: AppSizes.s12),
        ScoringTableEditor(
          keyPrefix: 'scoring-fantasy',
          table: state.draftFantasy,
          enabled: !state.saving,
          onChanged: (table) => cubit.editFantasy((_) => table),
        ),
        const SizedBox(height: AppSizes.s8),
        _Footer(
          note: l10n.scoringFantasyNote,
          saving: state.saving,
          dirty: state.fantasyDirty,
          onRestore: cubit.restoreFantasyDefaults,
          onSave: cubit.saveFantasy,
          keyName: 'scoring-fantasy',
        ),
      ],
    );
  }
}

class _BolaoTab extends StatelessWidget {
  final ScoringSettingsState state;
  final ScoringSettingsCubit cubit;

  const _BolaoTab({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rules = state.draftBolao;
    Widget row(String key, String label, int value, void Function(int) set) => ScoreStepperRow(
          keyName: 'scoring-bolao-$key',
          label: label,
          value: value,
          onLess: state.saving ? null : () => set(value - 1),
          onMore: state.saving ? null : () => set(value + 1),
        );
    return ListView(
      padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, safeBottom(context, AppSizes.s24)),
      children: [
        Text(l10n.scoringBolaoIntro, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14)),
        const SizedBox(height: AppSizes.s12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Column(
            children: [
              row('exact', l10n.scoringBolaoExact, rules.exact, (v) => cubit.editBolao((d) => d.copyWith(exact: v))),
              const Divider(height: 1, color: AppColors.greyLight),
              row('diff', l10n.scoringBolaoDiff, rules.winnerAndDiff,
                  (v) => cubit.editBolao((d) => d.copyWith(winnerAndDiff: v))),
              const Divider(height: 1, color: AppColors.greyLight),
              row('winner', l10n.scoringBolaoWinner, rules.winner,
                  (v) => cubit.editBolao((d) => d.copyWith(winner: v))),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s8),
        _Footer(
          note: l10n.scoringBolaoNote,
          saving: state.saving,
          dirty: state.bolaoDirty,
          onRestore: cubit.restoreBolaoDefaults,
          onSave: cubit.saveBolao,
          keyName: 'scoring-bolao',
        ),
      ],
    );
  }
}

/// "Restaurar padrões", o aviso de vigência e "Salvar".
class _Footer extends StatelessWidget {
  final String note;
  final bool saving;
  final bool dirty;
  final VoidCallback onRestore;
  final VoidCallback onSave;
  final String keyName;

  const _Footer({
    required this.note,
    required this.saving,
    required this.dirty,
    required this.onRestore,
    required this.onSave,
    required this.keyName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: ValueKey('$keyName-restore'),
            onPressed: saving ? null : onRestore,
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(l10n.scoringRestore),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
            const SizedBox(width: AppSizes.s8),
            Expanded(child: Text(note, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12))),
          ],
        ),
        const SizedBox(height: AppSizes.s16),
        ArenaButton.primary(
          key: ValueKey('$keyName-save'),
          title: l10n.scoringSave,
          isLoading: saving,
          function: dirty && !saving ? onSave : null,
        ),
      ],
    );
  }
}
