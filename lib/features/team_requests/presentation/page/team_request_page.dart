import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/team_request_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/team_request_state.dart';
import 'package:arena_soccer/features/team_requests/presentation/widgets/my_team_view.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_color_selector.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// "Sou dono de time": sem pedido (ou editando), o formulário; pendente ou
/// rejeitado, a situação; aprovado, a área "Meu time" do dono.
class TeamRequestPage extends StatefulWidget {
  const TeamRequestPage({super.key});

  @override
  State<TeamRequestPage> createState() => _TeamRequestPageState();
}

class _TeamRequestPageState extends State<TeamRequestPage> {
  late final TeamRequestCubit _cubit;
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _contact = TextEditingController();
  final _message = TextEditingController();
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<TeamRequestCubit>(context);
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
    for (final c in [_name, _description, _contact, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(TeamRequestForm form) {
    if (_name.text != form.name) _name.text = form.name;
    if (_description.text != form.description) _description.text = form.description;
    if (_contact.text != form.contact) _contact.text = form.contact;
    if (_message.text != form.message) _message.text = form.message;
  }

  void _submit(TeamRequestForm form) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (form.error != null) {
      setState(() => _showErrors = true);
      return;
    }
    _cubit.submit();
  }

  Future<void> _confirmCancel(TeamRequestDTO request, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.teamRequestCancelTitle,
      message: l10n.teamRequestCancelMessage(request.name),
      confirmLabel: l10n.teamRequestCancel,
      cancelLabel: l10n.playerRequestKeep,
      icon: Icons.cancel_outlined,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await _cubit.cancelRequest();
  }

  void _edit() {
    _cubit.startEditing();
    setState(() => _showErrors = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<TeamRequestCubit, TeamRequestState>(
      listenWhen: (previous, current) =>
          current is SubmittedTeamRequestState ||
          current is CancelledTeamRequestState ||
          current is ErrorTeamRequestState ||
          previous.editing != current.editing,
      listener: (context, state) {
        if (state is SubmittedTeamRequestState) {
          setState(() => _showErrors = false);
          showSnackBar(context: context, message: l10n.teamRequestSent);
        }
        if (state is CancelledTeamRequestState) showSnackBar(context: context, message: l10n.teamRequestCancelled);
        if (state is ErrorTeamRequestState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
        if (state.editing) _syncControllers(state.form);
      },
      builder: (context, state) {
        final request = state.request;
        // Aprovado: a tela vira "Meu time".
        if (request != null && request.isApproved && !state.editing) {
          return MyTeamView(request: request);
        }

        final submitting = state is SubmittingTeamRequestState;
        final ready = state is! LoadingTeamRequestState && state is! LoadErrorTeamRequestState;
        final showForm = state.showForm && ready;

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
                l10n.teamRequestTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
            ),
            bottomNavigationBar: showForm
                ? ArenaSubmitBar(
                    title: l10n.teamRequestSubmit, loading: submitting, onPressed: () => _submit(state.form))
                : null,
            body: switch (state) {
              LoadingTeamRequestState() => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              LoadErrorTeamRequestState() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ArenaEmptyState.error(message: l10n.teamRequestLoadError),
                    TextButton(onPressed: _cubit.retry, child: Text(l10n.commonTryAgain)),
                  ],
                ),
              _ when showForm => _buildForm(state, l10n),
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

  Widget _buildForm(TeamRequestState state, AppLocalizations l10n) {
    final form = state.form;
    final error = _showErrors ? form.error : null;
    final taken = form.takenName;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
      children: [
        Text(l10n.teamRequestIntro, style: AppTypography.subtitle()),
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
        Center(
          child: CirclePhotoPicker(
            file: form.crest,
            currentUrl: form.imageUrl,
            addLabel: l10n.teamRequestCrestAdd,
            emptyIcon: Icons.shield_outlined,
            size: AppSizes.s100,
            onPicked: _cubit.setCrest,
            onRemove: _cubit.clearCrest,
          ),
        ),
        const SizedBox(height: AppSizes.s20),
        FormSection(
          title: l10n.playersSectionData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                onChanged: _cubit.changeName,
                maxLength: TeamRequestForm.nameMaxLength,
                textCapitalization: TextCapitalization.words,
                style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                decoration: arenaInputDecoration(
                  label: l10n.teamRequestNameLabel,
                  icon: Icons.shield_outlined,
                  errorText: switch (error) {
                    TeamRequestFormError.name => l10n.teamRequestNameRequired,
                    TeamRequestFormError.nameTaken => l10n.teamRequestNameTaken(taken ?? ''),
                    _ => null,
                  },
                ),
              ),
              if (taken != null && error == null) ...[
                Text(
                  l10n.teamRequestNameTaken(taken),
                  style: AppTypography.body(color: AppColors.warning).copyWith(fontSize: AppSizes.s12),
                ),
                const SizedBox(height: AppSizes.s12),
              ],
              TextField(
                controller: _description,
                onChanged: _cubit.changeDescription,
                maxLength: TeamRequestForm.descriptionMaxLength,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: arenaInputDecoration(label: l10n.teamRequestDescriptionLabel, icon: Icons.notes_rounded),
              ),
              TextField(
                controller: _contact,
                onChanged: _cubit.changeContact,
                keyboardType: TextInputType.phone,
                decoration: arenaInputDecoration(
                  label: l10n.teamRequestContactLabel,
                  icon: Icons.phone_iphone_rounded,
                  hintText: l10n.teamRequestContactHint,
                  errorText: error == TeamRequestFormError.contact ? l10n.teamRequestContactRequired : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s6, AppSizes.s12, AppSizes.s16),
                child: Text(
                  l10n.teamRequestContactInfo,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ),
              TextField(
                controller: _message,
                onChanged: _cubit.changeMessage,
                maxLength: TeamRequestForm.messageMaxLength,
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

/// Pedido pendente ou rejeitado.
class _StatusView extends StatelessWidget {
  final TeamRequestDTO request;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _StatusView({required this.request, required this.busy, required this.onEdit, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rejected = request.status == PlayerRequestStatus.rejected;
    final sentOn = playerRequestDate(context, request.createdAt);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.s16),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.s20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Column(
            children: [
              PlayerRequestStatusBadge(status: request.status),
              const SizedBox(height: AppSizes.s16),
              TeamCrest(imageUrl: request.imageUrl, size: AppSizes.s80),
              const SizedBox(height: AppSizes.s12),
              Text(request.name, textAlign: TextAlign.center, style: AppTypography.title()),
              const SizedBox(height: AppSizes.s4),
              Text(request.region, style: AppTypography.subtitle()),
              if (sentOn.isNotEmpty)
                Text(l10n.playerRequestSentOn(sentOn),
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              const SizedBox(height: AppSizes.s16),
              Text(
                rejected ? l10n.teamRequestRejectedInfo : l10n.teamRequestPendingInfo,
                textAlign: TextAlign.center,
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
              if (rejected && request.reason.isNotEmpty) ...[
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
        if (rejected)
          ArenaButton.primary(title: l10n.teamRequestResubmit, function: onEdit)
        else ...[
          ArenaButton.outlined(title: l10n.teamRequestEdit, function: busy ? null : onEdit),
          const SizedBox(height: AppSizes.s8),
          Center(
            child: TextButton(
              onPressed: busy ? null : onCancel,
              child: Text(l10n.teamRequestCancel, style: AppTypography.label(color: AppColors.danger)),
            ),
          ),
        ],
      ],
    );
  }
}
