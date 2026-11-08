import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_requests_panel_cubit.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/page/organizer_request_page.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_select_tile.dart';
import 'package:arena_soccer/features/team_requests/presentation/widgets/reason_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel do admin com os pedidos "Sou organizador de campeonato":
/// pendentes (aprovar, rejeitar, editar, chamar no WhatsApp) e respondidos.
class OrganizerRequestsPanelPage extends StatefulWidget {
  const OrganizerRequestsPanelPage({super.key});

  @override
  State<OrganizerRequestsPanelPage> createState() => _OrganizerRequestsPanelPageState();
}

class _OrganizerRequestsPanelPageState extends State<OrganizerRequestsPanelPage> {
  late final OrganizerRequestsPanelCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<OrganizerRequestsPanelCubit>(context)..watch();
  }

  Future<void> _confirmApprove(OrganizerRequestDTO request, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.organizerRequestsApproveTitle(request.name),
      message: l10n.organizerRequestsApproveMessage(
        request.region,
        championshipScopeName(l10n, request.scope),
        request.userName,
      ),
      confirmLabel: l10n.playerRequestsApprove,
      icon: Icons.emoji_events_outlined,
      tone: ArenaAlertTone.primary,
    );
    if (confirmed) await _cubit.approve(request);
  }

  Future<void> _reject(OrganizerRequestDTO request, AppLocalizations l10n) async {
    final reason = await showReasonDialog(
      context,
      title: l10n.organizerRequestsRejectTitle(request.name),
      confirmLabel: l10n.playerRequestsReject,
    );
    if (reason != null) await _cubit.reject(request, reason: reason);
  }

  Future<void> _edit(OrganizerRequestDTO request) async {
    final edited = await showModalBottomSheet<OrganizerRequestDTO>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditSheet(request: request, regions: BlocProvider.of<RegionCubit>(context).state.regions),
    );
    if (edited != null && edited != request) await _cubit.update(edited);
  }

  Future<void> _openWhatsApp(OrganizerRequestDTO request, AppLocalizations l10n) async {
    var opened = false;
    try {
      final uri = Uri.tryParse(request.whatsAppUrl);
      if (uri != null && request.whatsAppUrl.isNotEmpty) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppLogger.e('openWhatsApp', name: 'OrganizerRequestsPanelPage', error: e);
    }
    if (!opened && mounted) showSnackBar(context: context, message: l10n.teamRequestsWhatsAppError, isSuccess: false);
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
          title: Text(
            l10n.organizerRequestsPanelTitle,
            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.whiteSoft,
            tabs: [
              BlocSelector<OrganizerRequestsPanelCubit, OrganizerRequestsPanelState, int>(
                selector: (state) => state.pending.length,
                builder: (context, count) => Tab(
                  text: count == 0 ? l10n.playerRequestsTabPending : '${l10n.playerRequestsTabPending} ($count)',
                ),
              ),
              Tab(text: l10n.playerRequestsTabAnswered),
            ],
          ),
        ),
        body: BlocConsumer<OrganizerRequestsPanelCubit, OrganizerRequestsPanelState>(
          listener: (context, state) {
            if (state is ErrorOrganizerRequestsPanelState) {
              showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
            }
            if (state is NoticeOrganizerRequestsPanelState) {
              showSnackBar(
                context: context,
                message: switch (state.notice) {
                  OrganizerRequestsNotice.approved => l10n.organizerRequestsApproved(state.name),
                  OrganizerRequestsNotice.rejected => l10n.playerRequestsRejected,
                  OrganizerRequestsNotice.updated => l10n.playerRequestsUpdated,
                },
              );
            }
          },
          builder: (context, state) {
            if (state.loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            if (state.requests.isEmpty && state is ErrorOrganizerRequestsPanelState) {
              return ArenaEmptyState.error(message: l10n.organizerRequestsLoadError);
            }

            Widget list(List<OrganizerRequestDTO> requests, String empty, {required bool actions}) {
              if (requests.isEmpty) return ArenaEmptyState(message: empty, icon: Icons.emoji_events_outlined);
              return ListView.separated(
                padding: const EdgeInsets.all(AppSizes.s16),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSizes.s12),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _RequestCard(
                    request: request,
                    busy: state.busy.contains(request.userId),
                    onWhatsApp: () => _openWhatsApp(request, l10n),
                    onApprove: actions ? () => _confirmApprove(request, l10n) : null,
                    onReject: actions ? () => _reject(request, l10n) : null,
                    onEdit: actions ? () => _edit(request) : null,
                  );
                },
              );
            }

            return TabBarView(
              children: [
                list(state.pending, l10n.organizerRequestsEmptyPending, actions: true),
                list(state.answered, l10n.organizerRequestsEmptyAnswered, actions: false),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final OrganizerRequestDTO request;
  final bool busy;
  final VoidCallback onWhatsApp;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onEdit;

  const _RequestCard({
    required this.request,
    required this.busy,
    required this.onWhatsApp,
    this.onApprove,
    this.onReject,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = playerRequestDate(context, request.createdAt);

    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TeamCrest(imageUrl: request.imageUrl, size: AppSizes.s56),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body().copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${request.region} · ${championshipScopeName(l10n, request.scope)}',
                      style: AppTypography.subtitle(),
                    ),
                  ],
                ),
              ),
              PlayerRequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSizes.s10),
          Text(
            [l10n.organizerRequestsOrganizer(request.userName), if (date.isNotEmpty) date].join(' · '),
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
          if (request.description.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.s10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.s12)),
              child: Text(request.description, style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
            ),
          ],
          if (request.isRejected && request.reason.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s8),
            Text(l10n.playerRequestReason(request.reason), style: AppTypography.body(color: AppColors.danger)),
          ],
          const SizedBox(height: AppSizes.s10),
          Row(
            children: [
              if (request.contact.isNotEmpty)
                TextButton.icon(
                  onPressed: onWhatsApp,
                  icon: const Icon(Icons.chat_rounded, size: AppSizes.s18),
                  label: Text(l10n.teamRequestsWhatsApp),
                ),
              const Spacer(),
              if (onEdit != null)
                IconButton(
                  tooltip: l10n.commonEdit,
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                ),
            ],
          ),
          if (onApprove != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: Text(l10n.playerRequestsReject),
                  ),
                ),
                const SizedBox(width: AppSizes.s8),
                Expanded(
                  child: FilledButton(
                    onPressed: busy ? null : onApprove,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    child: busy
                        ? const SizedBox.square(
                            dimension: AppSizes.s16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : Text(l10n.playerRequestsApprove),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Edição do admin antes de responder: nome, região e categoria.
class _EditSheet extends StatefulWidget {
  final OrganizerRequestDTO request;
  final List<String> regions;

  const _EditSheet({required this.request, required this.regions});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final _name = TextEditingController(text: widget.request.name);
  late String _region = widget.request.region;
  late ChampionshipScope _scope = widget.request.scope;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid = _name.text.trim().length >= OrganizerRequestDTO.nameMinLength;
    final regions = {...widget.regions, widget.request.region}.where((r) => r.isNotEmpty).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.s20,
        0,
        AppSizes.s20,
        AppSizes.s20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.playerRequestEdit, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
            const SizedBox(height: AppSizes.s16),
            TextField(
              controller: _name,
              maxLength: OrganizerRequestDTO.nameMaxLength,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              decoration: arenaInputDecoration(
                label: l10n.organizerRequestNameLabel,
                icon: Icons.emoji_events_outlined,
                errorText: valid ? null : l10n.organizerRequestNameRequired,
              ),
            ),
            RegionSelectTile(
              label: l10n.registerRegionLabel,
              region: _region,
              regions: regions,
              recent: BlocProvider.of<RegionCubit>(context).state.recentRegions,
              onChanged: (region) => setState(() => _region = region),
            ),
            const SizedBox(height: AppSizes.s16),
            Wrap(
              spacing: AppSizes.s8,
              runSpacing: AppSizes.s8,
              children: [
                for (final scope in ChampionshipScope.values)
                  ArenaChoiceChip(
                    label: championshipScopeName(l10n, scope),
                    selected: _scope == scope,
                    onTap: () => setState(() => _scope = scope),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.s20),
            ArenaButton.primary(
              title: l10n.commonSave,
              function: valid
                  ? () => Navigator.pop(
                        context,
                        widget.request.copyWith(name: _name.text.trim(), region: _region, scope: _scope),
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
