import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/domain/region_usage.dart';
import 'package:arena_soccer/features/regions/domain/usecases/create_region_usecase.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/manage_regions_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/manage_regions_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Painel de regiões (admin): as regiões cadastradas, com os times de cada
/// uma na temporada atual; criar, renomear, excluir (só vazia) e a
/// manutenção "Vincular regiões por id".
class ManageRegionsPage extends StatefulWidget {
  const ManageRegionsPage({super.key});

  @override
  State<ManageRegionsPage> createState() => _ManageRegionsPageState();
}

class _ManageRegionsPageState extends State<ManageRegionsPage> {
  late final ManageRegionsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ManageRegionsCubit>(context)..load();
  }

  /// Sem [current], cria; com ele, renomeia.
  Future<void> _openForm({String? current}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider<ManageRegionsCubit>.value(
        value: _cubit,
        child: _RegionFormSheet(current: current),
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  String _usageText(RegionUsage usage, AppLocalizations l10n) {
    final parts = [
      if (usage.of(RegionUsageKind.teams) > 0) l10n.regionsUsageTeams(usage.of(RegionUsageKind.teams)),
      if (usage.of(RegionUsageKind.matches) > 0) l10n.regionsUsageMatches(usage.of(RegionUsageKind.matches)),
      if (usage.of(RegionUsageKind.news) > 0) l10n.regionsUsageNews(usage.of(RegionUsageKind.news)),
      if (usage.of(RegionUsageKind.championships) > 0)
        l10n.regionsUsageChampionships(usage.of(RegionUsageKind.championships)),
      if (usage.of(RegionUsageKind.groups) > 0) l10n.regionsUsageGroups(usage.of(RegionUsageKind.groups)),
    ];
    return parts.join(' · ');
  }

  Future<void> _onDeleteChecked(DeleteCheckedManageRegionsState state, AppLocalizations l10n) async {
    if (!state.usage.isEmpty) {
      await showArenaNotice(
        context,
        title: l10n.regionsDeleteBlockedTitle,
        message: l10n.regionsDeleteBlockedMessage(state.name, _usageText(state.usage, l10n)),
        icon: Icons.block_rounded,
        tone: ArenaAlertTone.warning,
      );
      return;
    }
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.regionsDeleteTitle(state.name),
      message: l10n.regionsDeleteMessage,
      confirmLabel: l10n.commonDelete,
      icon: Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await _cubit.delete(state.name);
  }

  Future<void> _confirmLink(AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.regionsLinkTitle,
      message: l10n.regionsLinkConfirm,
      confirmLabel: l10n.regionsLinkRun,
      icon: Icons.link_rounded,
      tone: ArenaAlertTone.primary,
    );
    if (confirmed) await _cubit.linkRegions();
  }

  Future<void> _showLinkReport(LinkedManageRegionsState state, AppLocalizations l10n) {
    final report = state.report;
    return showArenaNotice(
      context,
      title: l10n.regionsLinkTitle,
      message: [
        report.total == 0 ? l10n.regionsLinkNothing : l10n.regionsLinkDone(report.total),
        if (report.unmatched.isNotEmpty) l10n.regionsLinkUnmatched(report.unmatched.join(', ')),
      ].join('\n\n'),
      icon: Icons.fact_check_outlined,
      tone: ArenaAlertTone.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.regionsManageTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.regionsCreate,
        onPressed: _openForm,
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocConsumer<ManageRegionsCubit, ManageRegionsState>(
        listener: (context, state) {
          final regions = BlocProvider.of<RegionCubit>(context);
          if (state is CreatedManageRegionsState) {
            showSnackBar(context: context, message: l10n.regionsCreated(state.name));
            // A lista nova aparece nos chips da home e nos cadastros.
            regions.load();
          }
          if (state is RenamedManageRegionsState) {
            showSnackBar(context: context, message: l10n.regionsRenamed(state.previous, state.name));
            regions.load();
          }
          if (state is DeletedManageRegionsState) {
            showSnackBar(context: context, message: l10n.regionsDeleted(state.name));
            regions.load();
          }
          if (state is DeleteCheckedManageRegionsState) _onDeleteChecked(state, l10n);
          if (state is LastRegionManageRegionsState) {
            showSnackBar(context: context, message: l10n.regionsLastRegion, isSuccess: false);
          }
          if (state is LinkedManageRegionsState) _showLinkReport(state, l10n);
          if (state is ErrorManageRegionsState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
        },
        builder: (context, state) {
          if (state is LoadingManageRegionsState && state.regions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.regions.isEmpty) {
            return state is ErrorManageRegionsState
                ? ArenaEmptyState.error(message: l10n.regionsLoadError)
                : ArenaEmptyState(message: l10n.regionsEmpty, icon: Icons.place_outlined);
          }
          return Column(
            children: [
              if (state.working) const LinearProgressIndicator(color: AppColors.primary, minHeight: 2),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s80),
                  children: [
                    for (final region in state.regions)
                      _RegionTile(
                        name: region,
                        teams: state.teamsIn(region),
                        actions: [
                          CardMenuAction(
                            icon: Icons.edit_outlined,
                            label: l10n.regionsRename,
                            onSelected: () => _openForm(current: region),
                          ),
                          CardMenuAction(
                            icon: Icons.delete_outline_rounded,
                            label: l10n.commonDelete,
                            destructive: true,
                            onSelected: () => _cubit.checkDelete(region),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSizes.s16),
                    _LinkCard(working: state.working, onRun: () => _confirmLink(l10n)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  final String name;
  final int teams;
  final List<CardMenuAction> actions;

  const _RegionTile({required this.name, required this.teams, required this.actions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s10, AppSizes.s4, AppSizes.s10),
      child: Row(
        children: [
          Container(
            width: AppSizes.s40,
            height: AppSizes.s40,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.place_outlined, color: AppColors.primaryDark, size: AppSizes.s20),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16)),
                const SizedBox(height: AppSizes.s2),
                Text(l10n.regionsTeamsCount(teams), style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ],
            ),
          ),
          CardMenuButton(actions: actions),
        ],
      ),
    );
  }
}

/// Manutenção: grava o id da região nos docs antigos (que só têm o nome).
class _LinkCard extends StatelessWidget {
  final bool working;
  final VoidCallback onRun;

  const _LinkCard({required this.working, required this.onRun});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSizes.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded, color: AppColors.primaryDark, size: AppSizes.s20),
              const SizedBox(width: AppSizes.s8),
              Text(l10n.regionsLinkTitle,
                  style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
            ],
          ),
          const SizedBox(height: AppSizes.s6),
          Text(l10n.regionsLinkHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          const SizedBox(height: AppSizes.s10),
          ArenaButton.outlined(title: l10n.regionsLinkRun, isLoading: working, function: working ? null : onRun),
        ],
      ),
    );
  }
}

/// Formulário da região (nova ou renomear): o erro (curto/repetido) aparece
/// no campo e o painel fecha sozinho ao gravar.
class _RegionFormSheet extends StatefulWidget {
  /// Região a renomear (nula = nova).
  final String? current;

  const _RegionFormSheet({this.current});

  @override
  State<_RegionFormSheet> createState() => _RegionFormSheetState();
}

class _RegionFormSheetState extends State<_RegionFormSheet> {
  late final _controller = TextEditingController(text: widget.current);
  RegionNameError? _error;

  bool get _renaming => widget.current != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(ManageRegionsState state) {
    final others = state.regions.where((region) => region != widget.current).toList();
    final error = CreateRegionUseCase.validate(_controller.text, others);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final cubit = BlocProvider.of<ManageRegionsCubit>(context);
    _renaming ? cubit.rename(widget.current!, _controller.text) : cubit.create(_controller.text);
  }

  String? _errorText(AppLocalizations l10n) => switch (_error) {
        RegionNameError.tooShort => l10n.regionsNameTooShort,
        RegionNameError.duplicate => l10n.regionsDuplicate,
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ManageRegionsCubit, ManageRegionsState>(
      listener: (context, state) {
        if (state is CreatedManageRegionsState || state is RenamedManageRegionsState) Navigator.pop(context);
        if (state is InvalidNameManageRegionsState) setState(() => _error = state.error);
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.s20,
            0,
            AppSizes.s20,
            AppSizes.s20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _renaming ? l10n.regionsRenameTitle : l10n.regionsCreate,
                  style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
                ),
                const SizedBox(height: AppSizes.s4),
                Text(
                  _renaming ? l10n.regionsRenameHint : l10n.regionsNameHint,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                const SizedBox(height: AppSizes.s16),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  maxLength: 40,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _submit(state),
                  decoration: arenaInputDecoration(
                    label: l10n.regionsNameLabel,
                    icon: Icons.place_outlined,
                    errorText: _errorText(l10n),
                  ),
                ),
                const SizedBox(height: AppSizes.s8),
                ArenaButton.primary(
                  title: _renaming ? l10n.newsSave : l10n.regionsCreate,
                  isLoading: state.saving,
                  function: () => _submit(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
