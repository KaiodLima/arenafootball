import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_state.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_choice_selector.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Sou jogador": o usuário pede para entrar no elenco de um time da região.
/// Sem pedido (ou editando), mostra o formulário; com pedido, a situação
/// (pendente, aprovada ou rejeitada) em tempo real.
class PlayerRequestPage extends StatefulWidget {
  const PlayerRequestPage({super.key});

  @override
  State<PlayerRequestPage> createState() => _PlayerRequestPageState();
}

class _PlayerRequestPageState extends State<PlayerRequestPage> {
  late final PlayerRequestCubit _cubit;
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  /// Erros só depois da primeira tentativa de enviar.
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<PlayerRequestCubit>(context);
    final user = BlocProvider.of<SessionCubit>(context).state.user!;
    _nameController.text = user.name;
    _cubit.start(
      userId: user.id,
      userName: user.name,
      email: user.email,
      initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Os campos de texto acompanham o formulário quando ele é preenchido pelo
  /// pedido (abrir edição/reenvio).
  void _syncControllers(PlayerRequestForm form) {
    if (_nameController.text != form.name) _nameController.text = form.name;
    if (_messageController.text != form.message) _messageController.text = form.message;
  }

  void _edit(PlayerRequestState state) {
    _cubit.startEditing();
    setState(() => _showErrors = false);
  }

  void _submit(PlayerRequestForm form) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (form.error != null) {
      setState(() => _showErrors = true);
      return;
    }
    _cubit.submit();
  }

  Future<void> _confirmCancel(PlayerRequestDTO request, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.playerRequestCancelTitle),
        content: Text(l10n.playerRequestCancelMessage(request.team)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.playerRequestKeep)),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.playerRequestCancel, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _cubit.cancelRequest();
  }

  void _openProfile(PlayerRequestDTO request) {
    Navigator.pushNamed(context, AppRoutes.playerProfilePage, arguments: {
      'playerId': request.playerId,
      'season': request.season == SeasonCollection.currentSeason ? null : request.season,
      'name': request.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PlayerRequestCubit, PlayerRequestState>(
      listenWhen: (previous, current) =>
          current is SubmittedPlayerRequestState ||
          current is CancelledPlayerRequestState ||
          current is ErrorPlayerRequestState ||
          previous.editing != current.editing,
      listener: (context, state) {
        if (state is SubmittedPlayerRequestState) {
          setState(() => _showErrors = false);
          showSnackBar(context: context, message: l10n.playerRequestSent);
        }
        if (state is CancelledPlayerRequestState) showSnackBar(context: context, message: l10n.playerRequestCancelled);
        if (state is ErrorPlayerRequestState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
        if (state.editing) _syncControllers(state.form);
      },
      builder: (context, state) {
        final submitting = state is SubmittingPlayerRequestState;
        final showForm = state.showForm && state is! LoadingPlayerRequestState && state is! LoadErrorPlayerRequestState;

        return PopScope(
          // Editando um pedido existente: "voltar" fecha a edição, não a tela.
          canPop: !(state.editing && state.request != null),
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
                l10n.playerRequestTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
            ),
            bottomNavigationBar: showForm
                ? ArenaSubmitBar(
                    title: l10n.playerRequestSubmit,
                    loading: submitting,
                    onPressed: () => _submit(state.form),
                  )
                : null,
            body: switch (state) {
              LoadingPlayerRequestState() => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              LoadErrorPlayerRequestState() => _LoadError(onRetry: _cubit.retry),
              _ when showForm => _buildForm(state, l10n),
              _ => _StatusView(
                  request: state.request!,
                  crest: state.form.crestOf(state.request!.team),
                  busy: submitting,
                  onEdit: () => _edit(state),
                  onCancel: () => _confirmCancel(state.request!, l10n),
                  onResubmit: () => _edit(state),
                  onOpenProfile: () => _openProfile(state.request!),
                ),
            },
          ),
        );
      },
    );
  }

  Widget _buildForm(PlayerRequestState state, AppLocalizations l10n) {
    final form = state.form;
    final error = _showErrors ? form.error : null;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
      children: [
        Text(l10n.playerRequestIntro, style: AppTypography.subtitle()),
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
        const SizedBox(height: AppSizes.s16),
        TeamChoiceSelector(
          key: ValueKey(form.selectedRegion),
          teams: form.teams,
          selected: form.selectedTeam,
          loading: form.loadingTeams,
          placeholder: l10n.playersTeam,
          onSelected: _cubit.selectTeam,
        ),
        if (error == PlayerRequestFormError.team) _ErrorText(l10n.playerRequestTeamRequired),
        const SizedBox(height: AppSizes.s20),
        Center(
          child: CirclePhotoPicker(
            file: form.photo,
            currentUrl: form.imageUrl,
            addLabel: l10n.playersPhotoAdd,
            emptyIcon: Icons.add_a_photo_outlined,
            size: AppSizes.s100,
            onPicked: _cubit.setPhoto,
            onRemove: _cubit.clearPhoto,
          ),
        ),
        const SizedBox(height: AppSizes.s20),
        FormSection(
          title: l10n.playersSectionData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                onChanged: _cubit.changeName,
                maxLength: PlayerRequestForm.nameMaxLength,
                textCapitalization: TextCapitalization.words,
                style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                decoration: arenaInputDecoration(
                  label: l10n.playerRequestNameLabel,
                  icon: Icons.person_outline_rounded,
                  errorText: error == PlayerRequestFormError.name ? l10n.playersNameRequired : null,
                ),
              ),
              const SizedBox(height: AppSizes.s4),
              Text(l10n.playerRequestPositionLabel, style: AppTypography.label(color: AppColors.textPrimary)),
              const SizedBox(height: AppSizes.s10),
              Wrap(
                spacing: AppSizes.s8,
                runSpacing: AppSizes.s8,
                children: [
                  for (final position in PlayerPosition.values)
                    ArenaChoiceChip(
                      label: playerPositionLabel(l10n, position),
                      selected: position == form.position,
                      onTap: () => _cubit.selectPosition(position),
                    ),
                ],
              ),
              if (error == PlayerRequestFormError.position) _ErrorText(l10n.playerRequestPositionRequired),
              const SizedBox(height: AppSizes.s20),
              TextField(
                controller: _messageController,
                onChanged: _cubit.changeMessage,
                maxLength: PlayerRequestForm.messageMaxLength,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: arenaInputDecoration(
                  label: l10n.playerRequestMessageLabel,
                  icon: Icons.chat_bubble_outline_rounded,
                  hintText: l10n.playerRequestMessageHint,
                ),
              ),
            ],
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

class _ErrorText extends StatelessWidget {
  final String text;

  const _ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s6, left: AppSizes.s12),
      child: Text(text, style: AppTypography.body(color: AppColors.danger).copyWith(fontSize: AppSizes.s12)),
    );
  }
}

/// Situação do pedido enviado, com as ações de cada caso.
class _StatusView extends StatelessWidget {
  final PlayerRequestDTO request;
  final String? crest;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onResubmit;
  final VoidCallback onOpenProfile;

  const _StatusView({
    required this.request,
    required this.crest,
    required this.busy,
    required this.onEdit,
    required this.onCancel,
    required this.onResubmit,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final position = request.position;
    final sentOn = playerRequestDate(context, request.createdAt);

    final (info, infoColor) = switch (request.status) {
      PlayerRequestStatus.pending => (l10n.playerRequestPendingInfo, AppColors.textSecondary),
      PlayerRequestStatus.approved => (l10n.playerRequestApprovedInfo(request.team), AppColors.primaryDark),
      PlayerRequestStatus.rejected => (l10n.playerRequestRejectedInfo, AppColors.textSecondary),
      PlayerRequestStatus.removed => (l10n.playerRequestRemovedInfo(request.team), AppColors.textSecondary),
    };

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
              TeamCrest(imageUrl: crest, size: AppSizes.s80),
              const SizedBox(height: AppSizes.s12),
              Text(request.name, textAlign: TextAlign.center, style: AppTypography.title()),
              const SizedBox(height: AppSizes.s4),
              Text(
                [request.team, if (position != null) playerPositionLabel(l10n, position)].join(' · '),
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(),
              ),
              if (sentOn.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s4),
                Text(
                  l10n.playerRequestSentOn(sentOn),
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ],
              const SizedBox(height: AppSizes.s16),
              Text(
                info,
                textAlign: TextAlign.center,
                style: AppTypography.body(color: infoColor).copyWith(
                  fontWeight: request.status == PlayerRequestStatus.approved ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              if (request.status == PlayerRequestStatus.rejected && request.reason.isNotEmpty) ...[
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
        ...switch (request.status) {
          PlayerRequestStatus.pending => [
              ArenaButton.outlined(title: l10n.playerRequestEdit, function: busy ? null : onEdit),
              const SizedBox(height: AppSizes.s8),
              Center(
                child: TextButton(
                  onPressed: busy ? null : onCancel,
                  child: Text(l10n.playerRequestCancel, style: AppTypography.label(color: AppColors.danger)),
                ),
              ),
            ],
          PlayerRequestStatus.rejected => [
              ArenaButton.primary(title: l10n.playerRequestResubmit, function: onResubmit),
            ],
          PlayerRequestStatus.approved => [
              if (request.playerId.isNotEmpty)
                ArenaButton.primary(title: l10n.playerRequestViewProfile, function: onOpenProfile),
            ],
          // Saiu do elenco: pede outro time; o perfil (com os números) continua.
          PlayerRequestStatus.removed => [
              ArenaButton.primary(title: l10n.playerRequestJoinAnother, function: onResubmit),
              if (request.playerId.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s8),
                ArenaButton.outlined(title: l10n.playerRequestViewProfile, function: onOpenProfile),
              ],
            ],
        },
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ArenaEmptyState.error(message: l10n.playerRequestLoadError),
        TextButton(onPressed: onRetry, child: Text(l10n.commonTryAgain)),
      ],
    );
  }
}
