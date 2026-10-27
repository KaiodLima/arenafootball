import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_requests_panel_cubit.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_requests_panel_state.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/team_requests/presentation/widgets/reason_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel do admin "Parceiros": pedidos pendentes (aprovar/rejeitar),
/// parceiros ativos (permissões, remover) e os respondidos.
class PartnerRequestsPanelPage extends StatefulWidget {
  const PartnerRequestsPanelPage({super.key});

  @override
  State<PartnerRequestsPanelPage> createState() => _PartnerRequestsPanelPageState();
}

class _PartnerRequestsPanelPageState extends State<PartnerRequestsPanelPage> {
  late final PartnerRequestsPanelCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<PartnerRequestsPanelCubit>(context)..watch();
  }

  Future<void> _confirmApprove(PartnerRequestDTO request, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.partnerApproveTitle(request.name),
      message: l10n.partnerApproveMessage(request.region),
      confirmLabel: l10n.playerRequestsApprove,
      icon: Icons.handshake_outlined,
      tone: ArenaAlertTone.primary,
    );
    if (confirmed) await _cubit.approve(request);
  }

  Future<void> _reject(PartnerRequestDTO request, AppLocalizations l10n) async {
    final reason = await showReasonDialog(
      context,
      title: l10n.partnerRejectTitle(request.name),
      confirmLabel: l10n.playerRequestsReject,
    );
    if (reason != null) await _cubit.reject(request, reason: reason);
  }

  Future<void> _revoke(PartnerRequestDTO request, AppLocalizations l10n) async {
    final reason = await showReasonDialog(
      context,
      title: l10n.partnerRevokeTitle(request.name),
      confirmLabel: l10n.partnerRevoke,
    );
    if (reason != null) await _cubit.revoke(request, reason: reason);
  }

  Future<void> _confirmLink(PartnerRequestDTO request, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.partnerLinkTitle(request.name),
      message: l10n.partnerLinkMessage(request.region),
      confirmLabel: l10n.partnerLinkConfirm,
      icon: Icons.link_rounded,
      tone: ArenaAlertTone.primary,
    );
    if (confirmed) await _cubit.linkHighlights(request);
  }

  Future<void> _editPermissions(PartnerRequestDTO request) async {
    final permissions = await showModalBottomSheet<PartnerPermissions>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PartnerPermissionsSheet(request: request),
    );
    if (permissions != null && permissions != request.permissions) {
      await _cubit.savePermissions(request, permissions);
    }
  }

  Future<void> _openWhatsApp(PartnerRequestDTO request, AppLocalizations l10n) async {
    var opened = false;
    try {
      final uri = Uri.tryParse(request.whatsAppUrl);
      if (uri != null && request.whatsAppUrl.isNotEmpty) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppLogger.e('openWhatsApp', name: 'PartnerRequestsPanelPage', error: e);
    }
    if (!opened && mounted) showSnackBar(context: context, message: l10n.teamRequestsWhatsAppError, isSuccess: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.white,
          surfaceTintColor: AppColors.transparent,
          titleSpacing: 0,
          title: Text(
            l10n.partnerPanelTitle,
            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.whiteSoft,
            tabs: [
              BlocSelector<PartnerRequestsPanelCubit, PartnerRequestsPanelState, int>(
                selector: (state) => state.pending.length,
                builder: (context, count) => Tab(
                  text: count == 0 ? l10n.playerRequestsTabPending : '${l10n.playerRequestsTabPending} ($count)',
                ),
              ),
              Tab(text: l10n.partnerTabActive),
              Tab(text: l10n.playerRequestsTabAnswered),
            ],
          ),
        ),
        body: BlocConsumer<PartnerRequestsPanelCubit, PartnerRequestsPanelState>(
          listener: (context, state) {
            if (state is ErrorPartnerRequestsPanelState) {
              showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
            }
            if (state is NoticePartnerRequestsPanelState) {
              showSnackBar(
                context: context,
                message: switch (state.notice) {
                  PartnerRequestsNotice.approved => l10n.partnerApproved(state.name),
                  PartnerRequestsNotice.rejected => l10n.playerRequestsRejected,
                  PartnerRequestsNotice.revoked => l10n.partnerRevoked,
                  PartnerRequestsNotice.permissionsSaved => l10n.partnerPermissionsSaved,
                  PartnerRequestsNotice.linked => l10n.partnerLinked(state.count),
                  PartnerRequestsNotice.linksCleared => l10n.partnerLinksCleared,
                },
              );
            }
          },
          builder: (context, state) {
            if (state.loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            if (state.requests.isEmpty && state is ErrorPartnerRequestsPanelState) {
              return ArenaEmptyState.error(message: l10n.partnerLoadError);
            }

            Widget list(List<PartnerRequestDTO> requests, String empty, _CardMode mode) {
              if (requests.isEmpty) return ArenaEmptyState(message: empty, icon: Icons.handshake_outlined);
              return ListView.separated(
                padding: const EdgeInsets.all(AppSizes.s16),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSizes.s12),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _RequestCard(
                    request: request,
                    mode: mode,
                    busy: state.busy.contains(request.userId),
                    onWhatsApp: () => _openWhatsApp(request, l10n),
                    onApprove: () => _confirmApprove(request, l10n),
                    onReject: () => _reject(request, l10n),
                    onPermissions: () => _editPermissions(request),
                    onRevoke: () => _revoke(request, l10n),
                    claimedTitles: [
                      for (final id in request.claimedHighlightIds) state.highlightTitles[id] ?? '',
                    ],
                    onLink: () => _confirmLink(request, l10n),
                    onClearLinks: () => _cubit.clearHighlightLinks(request),
                  );
                },
              );
            }

            return TabBarView(
              children: [
                list(state.pending, l10n.partnerPanelEmptyPending, _CardMode.pending),
                list(state.active, l10n.partnerPanelEmptyActive, _CardMode.active),
                list(state.answered, l10n.partnerPanelEmptyAnswered, _CardMode.answered),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum _CardMode { pending, active, answered }

class _RequestCard extends StatelessWidget {
  final PartnerRequestDTO request;
  final _CardMode mode;
  final bool busy;
  final VoidCallback onWhatsApp;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onPermissions;
  final VoidCallback onRevoke;

  /// Títulos dos destaques pedidos no vínculo ('' = não achado).
  final List<String> claimedTitles;
  final VoidCallback onLink;
  final VoidCallback onClearLinks;

  const _RequestCard({
    required this.request,
    required this.mode,
    required this.busy,
    required this.onWhatsApp,
    required this.onApprove,
    required this.onReject,
    required this.onPermissions,
    required this.onRevoke,
    required this.claimedTitles,
    required this.onLink,
    required this.onClearLinks,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = playerRequestDate(context, request.createdAt);
    final permissions = request.permissions;

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
                    Text(request.region, style: AppTypography.subtitle()),
                  ],
                ),
              ),
              PlayerRequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          Text(
            [l10n.partnerRequestedBy(request.userName), if (date.isNotEmpty) date].join(' · '),
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.s10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.s12)),
              child: Text('"${request.message}"', style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
            ),
          ],
          if (mode == _CardMode.active) ...[
            const SizedBox(height: AppSizes.s8),
            Text(
              [
                if (permissions.canNews) l10n.partnerPermNews,
                if (permissions.canHighlightsNow) l10n.partnerLimitHighlights(permissions.highlightLimit),
                if (permissions.canAdsNow) l10n.partnerLimitAds(permissions.adsPerDay),
                if (!permissions.canPublish) l10n.partnerNothingAllowedShort,
              ].join(' · '),
              style: AppTypography.body(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
            ),
          ],
          if (claimedTitles.isNotEmpty && mode != _CardMode.answered) ...[
            const SizedBox(height: AppSizes.s8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.s10),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    claimedTitles.every((t) => t.isNotEmpty)
                        ? l10n.partnerClaimedList(claimedTitles.join(', '))
                        : l10n.partnerClaimedCount(claimedTitles.length),
                    style: AppTypography.body(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s14),
                  ),
                  Text(
                    mode == _CardMode.pending ? l10n.partnerClaimOnApprove : l10n.partnerClaimActiveHint,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                  if (mode == _CardMode.active)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: busy ? null : onClearLinks,
                          child: Text(l10n.partnerLinkRefuse, style: AppTypography.label(color: AppColors.danger)),
                        ),
                        TextButton.icon(
                          onPressed: busy ? null : onLink,
                          icon: const Icon(Icons.link_rounded, size: AppSizes.s18),
                          label: Text(l10n.partnerLinkConfirm),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          if (mode == _CardMode.answered && request.reason.isNotEmpty) ...[
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
              if (mode == _CardMode.active)
                TextButton.icon(
                  onPressed: busy ? null : onPermissions,
                  icon: const Icon(Icons.tune_rounded, size: AppSizes.s18),
                  label: Text(l10n.partnerPermissions),
                ),
            ],
          ),
          if (mode == _CardMode.pending)
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
          if (mode == _CardMode.active)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: busy ? null : onRevoke,
                child: Text(l10n.partnerRevoke, style: AppTypography.label(color: AppColors.danger)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Permissões de um parceiro: o que pode publicar e os limites. Devolve as
/// permissões novas (ou nulo se fechar sem salvar).
class PartnerPermissionsSheet extends StatefulWidget {
  final PartnerRequestDTO request;

  const PartnerPermissionsSheet({super.key, required this.request});

  @override
  State<PartnerPermissionsSheet> createState() => _PartnerPermissionsSheetState();
}

class _PartnerPermissionsSheetState extends State<PartnerPermissionsSheet> {
  late PartnerPermissions _permissions = widget.request.permissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.partnerPermissions, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
            Text(widget.request.name, style: AppTypography.subtitle()),
            const SizedBox(height: AppSizes.s12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.partnerPermNews, style: AppTypography.body()),
              value: _permissions.canNews,
              onChanged: (value) => setState(() => _permissions = _permissions.copyWith(canNews: value)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.partnerPermHighlights, style: AppTypography.body()),
              value: _permissions.canHighlights,
              onChanged: (value) => setState(() => _permissions = _permissions.copyWith(canHighlights: value)),
            ),
            if (_permissions.canHighlights)
              _LimitStepper(
                label: l10n.partnerHighlightLimitLabel,
                value: _permissions.highlightLimit,
                onChanged: (value) => setState(() => _permissions = _permissions.copyWith(highlightLimit: value)),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.partnerPermAds, style: AppTypography.body()),
              value: _permissions.canAds,
              onChanged: (value) => setState(() => _permissions = _permissions.copyWith(canAds: value)),
            ),
            if (_permissions.canAds)
              _LimitStepper(
                label: l10n.partnerAdsPerDayLabel,
                value: _permissions.adsPerDay,
                onChanged: (value) => setState(() => _permissions = _permissions.copyWith(adsPerDay: value)),
              ),
            const SizedBox(height: AppSizes.s20),
            ArenaButton.primary(title: l10n.commonSave, function: () => Navigator.pop(context, _permissions)),
          ],
        ),
      ),
    );
  }
}

/// Limite com − e + (de 1 até [PartnerPermissions.maxLimit]).
class _LimitStepper extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _LimitStepper({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.s16, bottom: AppSizes.s8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.subtitle())),
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          Text('$value', style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
          IconButton(
            onPressed: value < PartnerPermissions.maxLimit ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}
