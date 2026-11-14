import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_request_cubit.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_request_state.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_select_tile.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';

/// Nome da abrangência ("Municipal"/"Intermunicipal").
String championshipScopeName(AppLocalizations l10n, ChampionshipScope scope) =>
    scope == ChampionshipScope.municipal ? l10n.championshipScopeMunicipal : l10n.championshipScopeIntermunicipal;

/// "Sou organizador de campeonato": sem pedido (ou editando), o formulário;
/// com pedido, a situação dele. Em cima, os campeonatos que a conta organiza.
class OrganizerRequestPage extends StatefulWidget {
  const OrganizerRequestPage({super.key});

  @override
  State<OrganizerRequestPage> createState() => _OrganizerRequestPageState();
}

class _OrganizerRequestPageState extends State<OrganizerRequestPage> {
  late final OrganizerRequestCubit _cubit;
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _contact = TextEditingController();
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<OrganizerRequestCubit>(context);
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
    for (final c in [_name, _description, _contact]) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(OrganizerRequestForm form) {
    if (_name.text != form.name) _name.text = form.name;
    if (_description.text != form.description) _description.text = form.description;
    if (_contact.text != form.contact) _contact.text = form.contact;
  }

  void _submit(OrganizerRequestForm form) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (form.error != null) {
      setState(() => _showErrors = true);
      return;
    }
    _cubit.submit();
  }

  Future<void> _confirmCancel(OrganizerRequestDTO request, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.organizerRequestCancelTitle,
      message: l10n.organizerRequestCancelMessage(request.name),
      confirmLabel: l10n.organizerRequestCancel,
      cancelLabel: l10n.playerRequestKeep,
      icon: Icons.cancel_outlined,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await _cubit.cancelRequest();
  }

  void _edit({bool fresh = false}) {
    fresh ? _cubit.startNewRequest() : _cubit.startEditing();
    setState(() => _showErrors = false);
  }

  void _openChampionship(ChampionshipDTO championship) {
    Navigator.pushNamed(
      context,
      AppRoutes.championshipFormPage,
      arguments: {'championship': championship, 'organizer': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<OrganizerRequestCubit, OrganizerRequestState>(
      listenWhen: (previous, current) =>
          current is SubmittedOrganizerRequestState ||
          current is CancelledOrganizerRequestState ||
          current is ErrorOrganizerRequestState ||
          previous.editing != current.editing,
      listener: (context, state) {
        if (state is SubmittedOrganizerRequestState) {
          setState(() => _showErrors = false);
          showSnackBar(context: context, message: l10n.organizerRequestSent);
        }
        if (state is CancelledOrganizerRequestState) {
          showSnackBar(context: context, message: l10n.organizerRequestCancelled);
        }
        if (state is ErrorOrganizerRequestState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
        if (state.editing) _syncControllers(state.form);
      },
      builder: (context, state) {
        final request = state.request;
        final submitting = state is SubmittingOrganizerRequestState;
        final ready = state is! LoadingOrganizerRequestState && state is! LoadErrorOrganizerRequestState;
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
                l10n.organizerRequestTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
            ),
            bottomNavigationBar: showForm
                ? ArenaSubmitBar(
                    title: l10n.organizerRequestSubmit,
                    loading: submitting,
                    onPressed: () => _submit(state.form),
                  )
                : null,
            body: switch (state) {
              LoadingOrganizerRequestState() =>
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              LoadErrorOrganizerRequestState() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ArenaEmptyState.error(message: l10n.organizerRequestLoadError),
                    TextButton(onPressed: _cubit.retry, child: Text(l10n.commonTryAgain)),
                  ],
                ),
              _ => ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16,
                      showForm ? AppSizes.s24 : safeBottom(context, AppSizes.s24)),
                  children: [
                    if (state.championships.isNotEmpty && !state.editing) ...[
                      _MyChampionships(championships: state.championships, onOpen: _openChampionship),
                      const SizedBox(height: AppSizes.s20),
                    ],
                    if (showForm)
                      ..._buildForm(state, l10n)
                    else
                      _StatusView(
                        request: request!,
                        busy: submitting,
                        onEdit: () => _edit(),
                        onNew: () => _edit(fresh: true),
                        onCancel: () => _confirmCancel(request, l10n),
                      ),
                  ],
                ),
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildForm(OrganizerRequestState state, AppLocalizations l10n) {
    final form = state.form;
    final error = _showErrors ? form.error : null;
    final region = form.selectedRegion ?? '';

    return [
      Text(l10n.organizerRequestIntro, style: AppTypography.subtitle()),
      const SizedBox(height: AppSizes.s16),
      Center(
        child: CirclePhotoPicker(
          file: form.logo,
          currentUrl: form.imageUrl,
          addLabel: l10n.organizerRequestLogoAdd,
          emptyIcon: Icons.emoji_events_outlined,
          size: AppSizes.s100,
          onPicked: _cubit.setLogo,
          onRemove: _cubit.clearLogo,
        ),
      ),
      const SizedBox(height: AppSizes.s20),
      FormSection(
        title: l10n.organizerRequestSectionCompetition,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              onChanged: _cubit.changeName,
              maxLength: OrganizerRequestDTO.nameMaxLength,
              textCapitalization: TextCapitalization.words,
              style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
              decoration: arenaInputDecoration(
                label: l10n.organizerRequestNameLabel,
                icon: Icons.emoji_events_outlined,
                errorText: error == OrganizerRequestFormError.name ? l10n.organizerRequestNameRequired : null,
              ),
            ),
            RegionSelectTile(
              label: l10n.registerRegionLabel,
              region: region,
              regions: form.regions,
              recent: BlocProvider.of<RegionCubit>(context).state.recentRegions,
              onChanged: _cubit.selectRegion,
            ),
            const SizedBox(height: AppSizes.s16),
            Text(l10n.organizerRequestScopeLabel, style: AppTypography.label(color: AppColors.textPrimary)),
            const SizedBox(height: AppSizes.s8),
            Wrap(
              spacing: AppSizes.s8,
              runSpacing: AppSizes.s8,
              children: [
                for (final scope in ChampionshipScope.values)
                  ArenaChoiceChip(
                    label: championshipScopeName(l10n, scope),
                    icon: scope == ChampionshipScope.municipal ? Icons.location_city_rounded : Icons.public_rounded,
                    selected: form.scope == scope,
                    onTap: () => _cubit.selectScope(scope),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.s6),
            Text(
              form.scope == ChampionshipScope.intermunicipal
                  ? l10n.championshipScopeIntermunicipalHint
                  : l10n.championshipScopeMunicipalHint(region),
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
            ),
            const SizedBox(height: AppSizes.s16),
            TextField(
              controller: _description,
              onChanged: _cubit.changeDescription,
              maxLength: OrganizerRequestDTO.descriptionMaxLength,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: arenaInputDecoration(
                label: l10n.organizerRequestDescriptionLabel,
                icon: Icons.notes_rounded,
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
                errorText: error == OrganizerRequestFormError.contact ? l10n.teamRequestContactRequired : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s6, AppSizes.s12, 0),
              child: Text(
                l10n.teamRequestContactInfo,
                style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
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
    ];
  }
}

/// Campeonatos que a conta organiza: o toque abre a edição do organizador.
class _MyChampionships extends StatelessWidget {
  final List<ChampionshipDTO> championships;
  final ValueChanged<ChampionshipDTO> onOpen;

  const _MyChampionships({required this.championships, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FormSection(
      title: l10n.organizerMyChampionships,
      child: Column(
        children: [
          for (final championship in championships)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: TeamCrest(imageUrl: championship.imageUrl, size: AppSizes.s44),
              title: Text(
                championship.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                [championship.season, championship.region, championshipScopeName(l10n, championship.scope)]
                    .where((part) => part.isNotEmpty)
                    .join(' · '),
                style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
              ),
              trailing: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
              onTap: () => onOpen(championship),
            ),
        ],
      ),
    );
  }
}

/// Situação do pedido: pendente (corrigir/cancelar), rejeitado (reenviar) ou
/// aprovado (pedir outro campeonato).
class _StatusView extends StatelessWidget {
  final OrganizerRequestDTO request;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onNew;
  final VoidCallback onCancel;

  const _StatusView({
    required this.request,
    required this.busy,
    required this.onEdit,
    required this.onNew,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sentOn = playerRequestDate(context, request.createdAt);
    final info = request.isApproved
        ? l10n.organizerRequestApprovedInfo
        : request.isRejected
            ? l10n.organizerRequestRejectedInfo
            : l10n.organizerRequestPendingInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Text(
                '${request.region} · ${championshipScopeName(l10n, request.scope)}',
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(),
              ),
              if (sentOn.isNotEmpty)
                Text(l10n.playerRequestSentOn(sentOn),
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              const SizedBox(height: AppSizes.s16),
              Text(info, textAlign: TextAlign.center, style: AppTypography.body(color: AppColors.textSecondary)),
              if (request.isRejected && request.reason.isNotEmpty) ...[
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
        if (request.isApproved)
          ArenaButton.outlined(title: l10n.organizerRequestNew, function: onNew)
        else if (request.isRejected)
          ArenaButton.primary(title: l10n.organizerRequestResubmit, function: onEdit)
        else ...[
          ArenaButton.outlined(title: l10n.organizerRequestEdit, function: busy ? null : onEdit),
          const SizedBox(height: AppSizes.s8),
          Center(
            child: TextButton(
              onPressed: busy ? null : onCancel,
              child: Text(l10n.organizerRequestCancel, style: AppTypography.label(color: AppColors.danger)),
            ),
          ),
        ],
      ],
    );
  }
}
