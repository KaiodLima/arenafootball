import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/presentation/widgets/highlight_avatar.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_request_cubit.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_request_state.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Sou parceiro": sem pedido (ou editando), o formulário; pendente,
/// rejeitado ou removido, a situação; aprovado, a área do parceiro (o que ele
/// pode publicar, as vagas usadas e os destaques dele).
class PartnerRequestPage extends StatefulWidget {
  const PartnerRequestPage({super.key});

  @override
  State<PartnerRequestPage> createState() => _PartnerRequestPageState();
}

class _PartnerRequestPageState extends State<PartnerRequestPage> {
  late final PartnerRequestCubit _cubit;
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _message = TextEditingController();
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<PartnerRequestCubit>(context);
    final user = BlocProvider.of<SessionCubit>(context).state.user!;
    _cubit.start(
      userId: user.id,
      userName: user.name,
      email: user.email,
      initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion,
    );
  }

  @override
  void dispose() {
    for (final c in [_name, _contact, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(PartnerRequestForm form) {
    if (_name.text != form.name) _name.text = form.name;
    if (_contact.text != form.contact) _contact.text = form.contact;
    if (_message.text != form.message) _message.text = form.message;
  }

  void _submit(PartnerRequestForm form) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (form.error != null) {
      setState(() => _showErrors = true);
      return;
    }
    _cubit.submit();
  }

  void _edit() {
    _cubit.startEditing();
    setState(() => _showErrors = false);
  }

  Future<void> _confirmCancel(PartnerRequestDTO request, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.partnerCancelTitle,
      message: l10n.partnerCancelMessage(request.name),
      confirmLabel: l10n.partnerCancel,
      cancelLabel: l10n.playerRequestKeep,
      icon: Icons.cancel_outlined,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await _cubit.cancelRequest();
  }

  /// Abre a tela de publicar e, na volta, recarrega as vagas.
  Future<void> _publish(String route, {Object? arguments}) async {
    await Navigator.pushNamed(context, route, arguments: arguments);
    if (mounted) await _cubit.refreshSlots();
  }

  Future<void> _confirmDeleteHighlight(HighlightDTO highlight, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.partnerHighlightDeleteTitle(highlight.title),
      confirmLabel: l10n.commonDelete,
      icon: Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await _cubit.deleteHighlight(highlight);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PartnerRequestCubit, PartnerRequestState>(
      listenWhen: (previous, current) =>
          current is NoticePartnerRequestState ||
          current is ErrorPartnerRequestState ||
          previous.editing != current.editing,
      listener: (context, state) {
        if (state is NoticePartnerRequestState) {
          if (state.notice == PartnerRequestNotice.submitted) setState(() => _showErrors = false);
          showSnackBar(
            context: context,
            message: switch (state.notice) {
              PartnerRequestNotice.submitted => l10n.partnerRequestSent,
              PartnerRequestNotice.cancelled => l10n.partnerRequestCancelled,
              PartnerRequestNotice.highlightDeleted => l10n.partnerHighlightDeleted,
              PartnerRequestNotice.linkRequested => l10n.partnerLinkRequested,
            },
          );
        }
        if (state is ErrorPartnerRequestState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
        if (state.editing) _syncControllers(state.form);
      },
      builder: (context, state) {
        final request = state.request;
        final submitting = state is SubmittingPartnerRequestState;
        final ready = state is! LoadingPartnerRequestState && state is! LoadErrorPartnerRequestState;
        final showForm = state.showForm && ready;
        final approved = request != null && request.isApproved && !state.editing;

        return PopScope(
          canPop: !(state.editing && request != null),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !submitting) _cubit.stopEditing();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              surfaceTintColor: AppColors.transparent,
              titleSpacing: 0,
              title: Text(
                approved ? l10n.partnerMenuApproved : l10n.partnerRequestTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
            ),
            bottomNavigationBar: showForm
                ? ArenaSubmitBar(
                    title: l10n.partnerRequestSubmit,
                    loading: submitting,
                    onPressed: () => _submit(state.form),
                  )
                : null,
            body: switch (state) {
              LoadingPartnerRequestState() => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              LoadErrorPartnerRequestState() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ArenaEmptyState.error(message: l10n.partnerLoadError),
                    TextButton(onPressed: _cubit.retry, child: Text(l10n.commonTryAgain)),
                  ],
                ),
              _ when showForm => _buildForm(state, l10n),
              _ when approved => _PartnerArea(
                  state: state,
                  onPublish: _publish,
                  onDeleteHighlight: (highlight) => _confirmDeleteHighlight(highlight, l10n),
                  onToggleLink: _cubit.toggleLinkRequest,
                ),
              _ => _StatusView(
                  request: request!,
                  busy: submitting,
                  onEdit: _edit,
                  onCancel: () => _confirmCancel(request, l10n),
                ),
            },
          ),
        );
      },
    );
  }

  Widget _buildForm(PartnerRequestState state, AppLocalizations l10n) {
    final form = state.form;
    final error = _showErrors ? form.error : null;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
      children: [
        Text(l10n.partnerRequestIntro, style: AppTypography.subtitle()),
        const SizedBox(height: AppSizes.s16),
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
        const SizedBox(height: AppSizes.s20),
        FormSection(
          title: l10n.teamsSectionData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                onChanged: _cubit.changeName,
                maxLength: PartnerRequestForm.nameMaxLength,
                textCapitalization: TextCapitalization.words,
                style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                decoration: arenaInputDecoration(
                  label: l10n.partnerNameLabel,
                  icon: Icons.storefront_outlined,
                  errorText: error == PartnerRequestFormError.name ? l10n.partnerNameRequired : null,
                ),
              ),
              TextField(
                controller: _contact,
                onChanged: _cubit.changeContact,
                keyboardType: TextInputType.phone,
                decoration: arenaInputDecoration(
                  label: l10n.teamRequestContactLabel,
                  icon: Icons.phone_iphone_rounded,
                  hintText: l10n.teamRequestContactHint,
                  errorText: error == PartnerRequestFormError.contact ? l10n.teamRequestContactRequired : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s6, AppSizes.s12, AppSizes.s16),
                child: Text(
                  l10n.partnerContactInfo,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ),
              TextField(
                controller: _message,
                onChanged: _cubit.changeMessage,
                maxLength: PartnerRequestForm.messageMaxLength,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: arenaInputDecoration(
                  label: l10n.playerRequestMessageLabel,
                  icon: Icons.chat_bubble_outline_rounded,
                ),
              ),
            ],
          ),
        ),
        if (state.unlinkedHighlights.isNotEmpty) ...[
          const SizedBox(height: AppSizes.s16),
          FormSection(
            title: l10n.partnerClaimTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.partnerClaimHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                for (final highlight in state.unlinkedHighlights)
                  _ClaimTile(
                    highlight: highlight,
                    claimed: form.claimedHighlightIds.contains(highlight.id),
                    onTap: () => _cubit.toggleClaim(highlight.id),
                  ),
              ],
            ),
          ),
        ],
        if (state.editing && state.request != null)
          Center(
            child: TextButton(
              onPressed: _cubit.stopEditing,
              child: Text(l10n.playerRequestDiscardEdit, style: AppTypography.label(color: AppColors.textSecondary)),
            ),
          ),
      ],
    );
  }
}

/// Pedido pendente, rejeitado ou removido.
class _StatusView extends StatelessWidget {
  final PartnerRequestDTO request;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _StatusView({required this.request, required this.busy, required this.onEdit, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rejected = request.status == PlayerRequestStatus.rejected;
    final removed = request.status == PlayerRequestStatus.removed;
    final sentOn = playerRequestDate(context, request.createdAt);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.s16),
      children: [
        _Card(
          child: Column(
            children: [
              PlayerRequestStatusBadge(status: request.status),
              const SizedBox(height: AppSizes.s16),
              const Icon(Icons.handshake_outlined, size: AppSizes.s48, color: AppColors.primaryDark),
              const SizedBox(height: AppSizes.s12),
              Text(request.name, textAlign: TextAlign.center, style: AppTypography.title()),
              const SizedBox(height: AppSizes.s4),
              Text(request.region, style: AppTypography.subtitle()),
              if (sentOn.isNotEmpty)
                Text(l10n.playerRequestSentOn(sentOn),
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              const SizedBox(height: AppSizes.s16),
              Text(
                removed
                    ? l10n.partnerRemovedInfo
                    : rejected
                        ? l10n.partnerRejectedInfo
                        : l10n.partnerPendingInfo,
                textAlign: TextAlign.center,
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
              if ((rejected || removed) && request.reason.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.s12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.s12),
                  ),
                  child: Text(l10n.playerRequestReason(request.reason), style: AppTypography.body()),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s20),
        if (rejected || removed)
          ArenaButton.primary(title: l10n.partnerResubmit, function: onEdit)
        else ...[
          ArenaButton.outlined(title: l10n.partnerEdit, function: busy ? null : onEdit),
          const SizedBox(height: AppSizes.s8),
          Center(
            child: TextButton(
              onPressed: busy ? null : onCancel,
              child: Text(l10n.partnerCancel, style: AppTypography.label(color: AppColors.danger)),
            ),
          ),
        ],
      ],
    );
  }
}

/// Área do parceiro aprovado.
class _PartnerArea extends StatelessWidget {
  final PartnerRequestState state;
  final Future<void> Function(String route, {Object? arguments}) onPublish;
  final ValueChanged<HighlightDTO> onDeleteHighlight;
  final ValueChanged<String> onToggleLink;

  const _PartnerArea({
    required this.state,
    required this.onPublish,
    required this.onDeleteHighlight,
    required this.onToggleLink,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final partner = state.request!;
    final permissions = partner.permissions;
    final slots = state.slots;
    final highlightsFull = slots != null && slots.freeHighlight == null;
    final adsFull = slots != null && slots.freeAd == null;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.s16),
      children: [
        _Card(
          child: Column(
            children: [
              const PlayerRequestStatusBadge(status: PlayerRequestStatus.approved),
              const SizedBox(height: AppSizes.s12),
              Text(partner.name, textAlign: TextAlign.center, style: AppTypography.title()),
              const SizedBox(height: AppSizes.s4),
              Text(l10n.partnerApprovedTitle(partner.region), style: AppTypography.subtitle()),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s16),
        FormSection(
          title: l10n.partnerCanPublish,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!permissions.canPublish)
                Text(l10n.partnerNothingAllowed, style: AppTypography.body(color: AppColors.textSecondary)),
              if (permissions.canNews)
                _PublishRow(
                  icon: Icons.article_outlined,
                  label: l10n.homePublishNews,
                  detail: l10n.partnerNewsDetail(partner.region),
                  onTap: () => onPublish(AppRoutes.registerNewsPage),
                ),
              if (permissions.canHighlightsNow)
                _PublishRow(
                  icon: Icons.star_outline_rounded,
                  label: l10n.homePublishHighlight,
                  detail: slots == null
                      ? l10n.partnerLimitHighlights(permissions.highlightLimit)
                      : l10n.partnerUsageHighlights(slots.usedHighlights, permissions.highlightLimit),
                  onTap: highlightsFull ? null : () => onPublish(AppRoutes.registerHighlightPage),
                ),
              if (permissions.canAdsNow)
                _PublishRow(
                  icon: Icons.campaign_outlined,
                  label: l10n.homePublishAd,
                  detail: slots == null
                      ? l10n.partnerLimitAds(permissions.adsPerDay)
                      : l10n.partnerUsageAds(slots.usedAds, permissions.adsPerDay),
                  onTap: adsFull ? null : () => onPublish(AppRoutes.publishAdPage),
                ),
            ],
          ),
        ),
        if (permissions.canHighlights || state.highlights.isNotEmpty) ...[
          const SizedBox(height: AppSizes.s16),
          FormSection(
            title: l10n.partnerMyHighlights,
            child: state.highlights.isEmpty
                ? Text(l10n.partnerNoHighlights, style: AppTypography.body(color: AppColors.textSecondary))
                : Column(
                    children: [
                      for (final highlight in state.highlights)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: HighlightRing(imageUrl: highlight.imageUrl, size: AppSizes.s48),
                          title: Text(highlight.title, style: AppTypography.body()),
                          subtitle: highlight.isVisible
                              ? null
                              : Text(l10n.partnerHighlightHidden, style: AppTypography.subtitle()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: l10n.commonEdit,
                                icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                                onPressed: () =>
                                    onPublish(AppRoutes.registerHighlightPage, arguments: {'highlight': highlight}),
                              ),
                              IconButton(
                                tooltip: l10n.commonDelete,
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                onPressed: () => onDeleteHighlight(highlight),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.highlightDetailsPage,
                            arguments: {'highlight': highlight},
                          ),
                        ),
                    ],
                  ),
          ),
        ],
        if (state.unlinkedHighlights.isNotEmpty) ...[
          const SizedBox(height: AppSizes.s16),
          FormSection(
            title: l10n.partnerUnlinkedTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.partnerClaimHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                for (final highlight in state.unlinkedHighlights)
                  _ClaimTile(
                    highlight: highlight,
                    claimed: partner.claimedHighlightIds.contains(highlight.id),
                    onTap: () => onToggleLink(highlight.id),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Destaque sem dono: marcar "é meu" pede o vínculo (o admin confirma).
class _ClaimTile extends StatelessWidget {
  final HighlightDTO highlight;
  final bool claimed;
  final VoidCallback onTap;

  const _ClaimTile({required this.highlight, required this.claimed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: HighlightRing(imageUrl: highlight.imageUrl, size: AppSizes.s48),
      title: Text(highlight.title, style: AppTypography.body()),
      subtitle: claimed
          ? Text(l10n.partnerClaimPending, style: AppTypography.subtitle().copyWith(color: AppColors.primaryDark))
          : null,
      trailing: Checkbox(value: claimed, activeColor: AppColors.primary, onChanged: (_) => onTap()),
    );
  }
}

/// Uma opção de publicar com o detalhe (limite/uso). [onTap] nulo = sem vaga.
class _PublishRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback? onTap;

  const _PublishRow({required this.icon, required this.label, required this.detail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      onTap: onTap,
      leading: Container(
        width: AppSizes.s36,
        height: AppSizes.s36,
        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s10)),
        child: Icon(icon, color: AppColors.primaryDark, size: AppSizes.s20),
      ),
      title: Text(label, style: AppTypography.label(color: AppColors.textPrimary)),
      subtitle: Text(detail, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
      trailing: Icon(
        enabled ? Icons.add_circle_outline_rounded : Icons.block_rounded,
        color: enabled ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: child,
    );
  }
}
