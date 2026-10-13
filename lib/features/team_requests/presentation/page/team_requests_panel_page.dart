import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/team_requests_panel_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/team_requests_panel_state.dart';
import 'package:arena_soccer/features/team_requests/presentation/widgets/reason_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_color_selector.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel do admin com os pedidos "Sou dono de time": pendentes (aprovar,
/// rejeitar, editar, chamar no WhatsApp) e respondidos.
class TeamRequestsPanelPage extends StatefulWidget {
  const TeamRequestsPanelPage({super.key});

  @override
  State<TeamRequestsPanelPage> createState() => _TeamRequestsPanelPageState();
}

class _TeamRequestsPanelPageState extends State<TeamRequestsPanelPage> {
  late final TeamRequestsPanelCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<TeamRequestsPanelCubit>(context)..watch();
  }

  Future<void> _confirmApprove(TeamRequestDTO request, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.teamRequestsApproveTitle(request.name)),
        content: Text(l10n.teamRequestsApproveMessage(request.region, request.userName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.playerRequestsApprove)),
        ],
      ),
    );
    if (confirmed == true) await _cubit.approve(request);
  }

  Future<void> _reject(TeamRequestDTO request, AppLocalizations l10n) async {
    final reason = await showReasonDialog(
      context,
      title: l10n.teamRequestsRejectTitle(request.name),
      confirmLabel: l10n.playerRequestsReject,
    );
    if (reason != null) await _cubit.reject(request, reason: reason);
  }

  Future<void> _edit(TeamRequestDTO request) async {
    final edited = await showModalBottomSheet<TeamRequestDTO>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditSheet(request: request, regions: BlocProvider.of<RegionCubit>(context).state.regions),
    );
    if (edited != null && edited != request) await _cubit.update(edited);
  }

  Future<void> _openWhatsApp(TeamRequestDTO request, AppLocalizations l10n) async {
    var opened = false;
    try {
      final uri = Uri.tryParse(request.whatsAppUrl);
      if (uri != null && request.whatsAppUrl.isNotEmpty) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppLogger.e('openWhatsApp', name: 'TeamRequestsPanelPage', error: e);
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
            l10n.teamRequestsPanelTitle,
            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.whiteSoft,
            tabs: [
              BlocSelector<TeamRequestsPanelCubit, TeamRequestsPanelState, int>(
                selector: (state) => state.pending.length,
                builder: (context, count) => Tab(
                  text: count == 0 ? l10n.playerRequestsTabPending : '${l10n.playerRequestsTabPending} ($count)',
                ),
              ),
              Tab(text: l10n.playerRequestsTabAnswered),
            ],
          ),
        ),
        body: BlocConsumer<TeamRequestsPanelCubit, TeamRequestsPanelState>(
          listener: (context, state) {
            if (state is ErrorTeamRequestsPanelState) {
              showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
            }
            if (state is NoticeTeamRequestsPanelState) {
              showSnackBar(
                context: context,
                message: switch (state.notice) {
                  TeamRequestsNotice.approved => l10n.teamRequestsApproved(state.name),
                  TeamRequestsNotice.rejected => l10n.playerRequestsRejected,
                  TeamRequestsNotice.updated => l10n.playerRequestsUpdated,
                },
              );
            }
          },
          builder: (context, state) {
            if (state.loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            if (state.requests.isEmpty && state is ErrorTeamRequestsPanelState) {
              return ArenaEmptyState.error(message: l10n.teamRequestsLoadError);
            }

            Widget list(List<TeamRequestDTO> requests, String empty, {required bool actions}) {
              if (requests.isEmpty) return ArenaEmptyState(message: empty, icon: Icons.shield_outlined);
              return ListView.separated(
                padding: const EdgeInsets.all(AppSizes.s16),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSizes.s12),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _RequestCard(
                    request: request,
                    duplicate: actions ? state.duplicateOf(request)?.name : null,
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
                list(state.pending, l10n.teamRequestsEmptyPending, actions: true),
                list(state.answered, l10n.teamRequestsEmptyAnswered, actions: false),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TeamRequestDTO request;
  final String? duplicate;
  final bool busy;
  final VoidCallback onWhatsApp;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onEdit;

  const _RequestCard({
    required this.request,
    required this.duplicate,
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
                    Row(
                      children: [
                        Flexible(child: Text(request.region, style: AppTypography.subtitle())),
                        const SizedBox(width: AppSizes.s6),
                        TeamColorsBadge(primary: request.primaryColor, secondary: request.secondaryColor),
                      ],
                    ),
                  ],
                ),
              ),
              PlayerRequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSizes.s10),
          Text(
            [l10n.teamRequestsOwner(request.userName), if (date.isNotEmpty) date].join(' · '),
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
          if (request.description.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s8),
            Text(request.description, style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
          ],
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.s10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.s12)),
              child: Text('"${request.message}"', style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
            ),
          ],
          if (duplicate != null) ...[
            const SizedBox(height: AppSizes.s8),
            Text(
              l10n.teamRequestNameTaken(duplicate!),
              style: AppTypography.body(color: AppColors.warning).copyWith(fontSize: AppSizes.s12),
            ),
          ],
          if (request.status == PlayerRequestStatus.rejected && request.reason.isNotEmpty) ...[
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

/// Edição do admin antes de responder: nome, região e descrição.
class _EditSheet extends StatefulWidget {
  final TeamRequestDTO request;
  final List<String> regions;

  const _EditSheet({required this.request, required this.regions});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final _name = TextEditingController(text: widget.request.name);
  late final _description = TextEditingController(text: widget.request.description);
  late String _region = widget.request.region;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid = _name.text.trim().length >= 3;
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
              maxLength: 40,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              decoration: arenaInputDecoration(
                label: l10n.teamRequestNameLabel,
                icon: Icons.shield_outlined,
                errorText: valid ? null : l10n.teamRequestNameRequired,
              ),
            ),
            Wrap(
              spacing: AppSizes.s8,
              runSpacing: AppSizes.s8,
              children: [
                for (final region in regions)
                  ArenaChoiceChip(
                    label: region,
                    icon: Icons.place_outlined,
                    selected: region == _region,
                    onTap: () => setState(() => _region = region),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.s16),
            TextField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: arenaInputDecoration(label: l10n.teamRequestDescriptionLabel, icon: Icons.notes_rounded),
            ),
            const SizedBox(height: AppSizes.s20),
            ArenaButton.primary(
              title: l10n.commonSave,
              function: valid
                  ? () => Navigator.pop(
                        context,
                        widget.request.copyWith(
                          name: _name.text.trim(),
                          region: _region,
                          description: _description.text.trim(),
                        ),
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
