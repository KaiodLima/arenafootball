import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_requests_panel_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_requests_panel_state.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/edit_player_request_sheet.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_claim_info.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Painel do admin com os pedidos "Sou jogador": pendentes (aprovar, rejeitar,
/// editar) e respondidos.
class PlayerRequestsPanelPage extends StatefulWidget {
  const PlayerRequestsPanelPage({super.key});

  @override
  State<PlayerRequestsPanelPage> createState() => _PlayerRequestsPanelPageState();
}

class _PlayerRequestsPanelPageState extends State<PlayerRequestsPanelPage> {
  late final PlayerRequestsPanelCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<PlayerRequestsPanelCubit>(context)..watch();
  }

  Future<void> _confirmApprove(PlayerRequestDTO request, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.playerRequestsApproveTitle(request.name),
      message: request.isClaim
          ? l10n.playerRequestsApproveClaimMessage(request.name)
          : l10n.playerRequestsApproveMessage(request.name, request.team),
      confirmLabel: l10n.playerRequestsApprove,
      icon: Icons.how_to_reg_outlined,
      tone: ArenaAlertTone.primary,
    );
    if (confirmed) await _cubit.approve(request);
  }

  /// A conta já tem outro atleta: juntar os dois no reivindicado.
  Future<void> _confirmMerge(MergeNeededPlayerRequestsPanelState state, AppLocalizations l10n) async {
    final request = state.request;
    final current = state.current;
    final claimed = state.players.where((p) => p.id == request.claimedPlayerId).firstOrNull;
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.playerRequestsMergeTitle,
      message: l10n.playerRequestsMergeMessage(
        current.name,
        current.team,
        current.goals,
        claimed?.name ?? request.name,
        request.team,
      ),
      confirmLabel: l10n.playerRequestsMergeConfirm,
      icon: Icons.merge_rounded,
      tone: ArenaAlertTone.primary,
    );
    if (confirmed) await _cubit.approve(request, mergePlayerId: current.id);
  }

  Future<void> _confirmReject(PlayerRequestDTO request, AppLocalizations l10n) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _RejectDialog(name: request.name),
    );
    if (reason != null) await _cubit.reject(request, reason: reason);
  }

  Future<void> _edit(PlayerRequestDTO request, PlayerRequestsPanelState state) async {
    final edited = await showEditPlayerRequestSheet(
      context,
      request: request,
      teams: state.teamsOf(request.region),
    );
    if (edited != null && edited != request) await _cubit.update(edited);
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
            l10n.playerRequestsPanelTitle,
            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.whiteSoft,
            tabs: [
              BlocSelector<PlayerRequestsPanelCubit, PlayerRequestsPanelState, int>(
                selector: (state) => state.pending.length,
                builder: (context, count) => Tab(
                  text: count == 0 ? l10n.playerRequestsTabPending : '${l10n.playerRequestsTabPending} ($count)',
                ),
              ),
              Tab(text: l10n.playerRequestsTabAnswered),
            ],
          ),
        ),
        body: BlocConsumer<PlayerRequestsPanelCubit, PlayerRequestsPanelState>(
          listener: (context, state) {
            if (state is ErrorPlayerRequestsPanelState) {
              showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
            }
            if (state is ApprovedPlayerRequestsPanelState) {
              showSnackBar(
                context: context,
                message: state.merged
                    ? l10n.playerRequestsMerged(state.name)
                    : l10n.playerRequestsApproved(state.name, state.team),
              );
            }
            if (state is MergeNeededPlayerRequestsPanelState) _confirmMerge(state, l10n);
            if (state is RejectedPlayerRequestsPanelState) {
              showSnackBar(context: context, message: l10n.playerRequestsRejected);
            }
            if (state is UpdatedPlayerRequestsPanelState) {
              showSnackBar(context: context, message: l10n.playerRequestsUpdated);
            }
          },
          builder: (context, state) {
            if (state is LoadingPlayerRequestsPanelState) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state.requests.isEmpty && state is ErrorPlayerRequestsPanelState) {
              return ArenaEmptyState.error(message: l10n.playerRequestsLoadError);
            }
            return TabBarView(
              children: [
                _RequestList(
                  requests: state.pending,
                  state: state,
                  emptyMessage: l10n.playerRequestsEmptyPending,
                  onApprove: (r) => _confirmApprove(r, l10n),
                  onReject: (r) => _confirmReject(r, l10n),
                  onEdit: (r) => _edit(r, state),
                ),
                _RequestList(
                  requests: state.answered,
                  state: state,
                  emptyMessage: l10n.playerRequestsEmptyAnswered,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<PlayerRequestDTO> requests;
  final PlayerRequestsPanelState state;
  final String emptyMessage;
  final ValueChanged<PlayerRequestDTO>? onApprove;
  final ValueChanged<PlayerRequestDTO>? onReject;
  final ValueChanged<PlayerRequestDTO>? onEdit;

  const _RequestList({
    required this.requests,
    required this.state,
    required this.emptyMessage,
    this.onApprove,
    this.onReject,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) return ArenaEmptyState(message: emptyMessage, icon: Icons.how_to_reg_outlined);
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.s16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.s12),
      itemBuilder: (context, index) {
        final request = requests[index];
        return _RequestCard(
          request: request,
          crest: state.crestOf(request.team),
          duplicateName: request.isPending ? state.duplicateOf(request)?.name : null,
          claimed: PlayerRequestClaimInfo.find(request, state.players),
          busy: state.busy.contains(request.userId),
          onApprove: onApprove == null ? null : () => onApprove!(request),
          onReject: onReject == null ? null : () => onReject!(request),
          onEdit: onEdit == null ? null : () => onEdit!(request),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final PlayerRequestDTO request;
  final String? crest;
  final String? duplicateName;

  /// Atleta reivindicado (pedido de vínculo), se estiver na lista carregada.
  final PlayerDTO? claimed;
  final bool busy;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onEdit;

  const _RequestCard({
    required this.request,
    required this.crest,
    required this.duplicateName,
    this.claimed,
    required this.busy,
    this.onApprove,
    this.onReject,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final position = request.position;
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
              CircleAvatar(
                radius: AppSizes.s28,
                backgroundColor: AppColors.background,
                backgroundImage: request.imageUrl.isEmpty ? null : CachedNetworkImageProvider(request.imageUrl),
                child: request.imageUrl.isEmpty
                    ? const Icon(Icons.person_rounded, color: AppColors.textSecondary, size: AppSizes.s28)
                    : null,
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body().copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (position != null) Text(playerPositionLabel(l10n, position), style: AppTypography.subtitle()),
                  ],
                ),
              ),
              PlayerRequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          Row(
            children: [
              TeamCrest(imageUrl: crest, size: AppSizes.s28),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: Text(
                  [request.team, if (request.championship.isNotEmpty) request.championship, request.region].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body().copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          Text(
            [l10n.playerRequestsAccount(request.userName), if (date.isNotEmpty) date].join(' · '),
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.s10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.s12),
              ),
              child: Text('"${request.message}"', style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
            ),
          ],
          if (request.isClaim) ...[
            const SizedBox(height: AppSizes.s10),
            PlayerRequestClaimInfo(request: request, player: claimed),
          ],
          if (duplicateName != null) ...[
            const SizedBox(height: AppSizes.s10),
            _Warning(text: l10n.playersDuplicate(duplicateName!, request.team)),
          ],
          if (request.status == PlayerRequestStatus.rejected && request.reason.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s10),
            Text(l10n.playerRequestReason(request.reason), style: AppTypography.body(color: AppColors.danger)),
          ],
          if (request.isPending) ...[
            const SizedBox(height: AppSizes.s12),
            Row(
              children: [
                IconButton(
                  tooltip: l10n.commonEdit,
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: busy ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: Text(l10n.playerRequestsReject),
                ),
                const SizedBox(width: AppSizes.s8),
                FilledButton(
                  onPressed: busy ? null : onApprove,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: busy
                      ? const SizedBox.square(
                          dimension: AppSizes.s16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : Text(l10n.playerRequestsApprove),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  final String text;

  const _Warning({required this.text});

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

/// Confirmação da rejeição, com motivo opcional. Devolve o motivo (pode ser
/// vazio) ou `null` se cancelar.
class _RejectDialog extends StatefulWidget {
  final String name;

  const _RejectDialog({required this.name});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.playerRequestsRejectTitle(widget.name)),
      content: TextField(
        controller: _controller,
        maxLength: 200,
        minLines: 1,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: arenaInputDecoration(label: l10n.playerRequestsRejectReason),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(l10n.playerRequestsReject, style: const TextStyle(color: AppColors.danger)),
        ),
      ],
    );
  }
}
