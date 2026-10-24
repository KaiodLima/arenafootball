import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/relative_time.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_state.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/features/players/presentation/widgets/athlete_share_card.dart';
import 'package:arena_soccer/features/players/presentation/widgets/count_stepper.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_photo_dialog.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/photo_gallery_page.dart';
import 'package:arena_soccer/utils/components/share_image_frame.dart';
import 'package:arena_soccer/utils/components/share_image_sheet.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Tela do atleta: foto, nome e time no topo; gols e assistências com a
/// posição nos rankings da região; os cards de gol em que participou. O
/// admin edita foto, nome e números (grava na hora).
class PlayerProfilePage extends StatefulWidget {
  final String playerId;

  /// Temporada dos jogadores (nulo = a corrente).
  final String? season;

  /// Mostrado no topo enquanto o jogador carrega.
  final String? name;

  /// Já conhecido (ex.: vindo do elenco): aparece na hora.
  final PlayerDTO? initial;

  const PlayerProfilePage({super.key, required this.playerId, this.season, this.name, this.initial});

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  late final _cubit = BlocProvider.of<PlayerProfileCubit>(context);

  @override
  void initState() {
    super.initState();
    _cubit.watch(playerId: widget.playerId, season: widget.season, initial: widget.initial);
  }

  /// Card do atleta com as estatísticas (o texto vira a legenda).
  void _share(PlayerProfileState state, AppLocalizations l10n) {
    final player = state.player;
    if (player == null) return;
    final slug = player.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    showShareImageSheet(
      context,
      title: l10n.athleteShareTitle,
      fileName: 'atleta_$slug',
      preview: ShareImageFrame(
        date: DateTime.now(),
        card: AthleteShareCard(
          player: player,
          // Time só se o jogador ainda está nele.
          team: player.team.isEmpty ? null : state.team,
          season: widget.season ?? BlocProvider.of<RegionCubit>(context).state.selectedSeason,
          goalsRank: state.goalsRank,
          assistsRank: state.assistsRank,
          participations: state.participations.length,
        ),
      ),
      shareText: '${l10n.athleteShareText(player.name, player.team, player.goals, player.assists)}\n'
          '${athleteLink(widget.season ?? SeasonCollection.currentSeason, player.id)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = context.watch<SessionCubit>().state.isAdmin;
    final ownedTeam = context.watch<OwnedTeamCubit>().state;

    return BlocConsumer<PlayerProfileCubit, PlayerProfileState>(
      listenWhen: (_, current) =>
          (current is ErrorPlayerProfileState && current.player != null) ||
          current is DeletedPlayerProfileState ||
          current is RemovedFromSquadPlayerProfileState,
      listener: (context, state) {
        if (state is RemovedFromSquadPlayerProfileState) {
          showSnackBar(context: context, message: l10n.athleteRemoved(state.name, state.teamName));
          return;
        }
        if (state is DeletedPlayerProfileState) {
          showSnackBar(context: context, message: l10n.athleteDeleted(state.name, state.teamName));
          Navigator.pop(context);
          return;
        }
        showSnackBar(context: context, message: (state as ErrorPlayerProfileState).errorMessage, isSuccess: false);
      },
      builder: (context, state) {
        final player = state.player;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            elevation: 0,
            title: Text(l10n.athleteTitle),
            actions: [
              if (player != null)
                IconButton(
                  tooltip: l10n.athleteShare,
                  onPressed: () => _share(state, l10n),
                  icon: const Icon(Icons.share_rounded),
                ),
            ],
          ),
          body: switch (state) {
            _ when state.notFound => ArenaEmptyState(message: l10n.athleteNotFound, icon: Icons.person_off_outlined),
            ErrorPlayerProfileState() when player == null => ArenaEmptyState.error(message: l10n.athleteLoadError),
            _ when player == null => _Loading(name: widget.name),
            // O dono do time edita os jogadores do próprio elenco, como o admin.
            _ => _Content(
                state: state,
                player: player,
                isAdmin: isAdmin ||
                    ownedTeam.owns(id: player.teamId, name: player.team) ||
                    player.enrollments.any((e) => ownedTeam.owns(id: e.teamId, name: e.team)),
                season: widget.season,
              ),
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  final String? name;

  const _Loading({this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: AppSizes.s60, backgroundColor: AppColors.whiteMuted),
              if (name != null) ...[
                const SizedBox(height: AppSizes.s12),
                Text(name!, style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s24)),
              ],
            ],
          ),
        ),
        const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      ],
    );
  }
}

/// Faixa verde-escura do topo.
class _HeroBox extends StatelessWidget {
  final Widget child;

  const _HeroBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSizes.s24)),
        child: ArenaHeroBackground(
          watermarkFactor: 0.6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, AppSizes.s24),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final PlayerProfileState state;
  final PlayerDTO player;
  final bool isAdmin;
  final String? season;

  const _Content({required this.state, required this.player, required this.isAdmin, required this.season});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSizes.s32),
      children: [
        _HeroBox(child: _Header(state: state, player: player)),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, 0),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.sports_soccer_rounded,
                  label: l10n.playersSummaryGoals,
                  value: player.goals,
                  rank: state.goalsRank == null ? l10n.athleteNoRank : l10n.athleteRankGoals(state.goalsRank!),
                ),
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: _StatCard(
                  icon: Icons.assistant_rounded,
                  label: l10n.playersSummaryAssists,
                  value: player.assists,
                  rank: state.assistsRank == null ? l10n.athleteNoRank : l10n.athleteRankAssists(state.assistsRank!),
                ),
              ),
            ],
          ),
        ),
        if (player.enrollments.isNotEmpty || player.friendlyGoals > 0 || player.friendlyAssists > 0) ...[
          _SectionLabel(l10n.athletePlaysFor),
          for (final enrollment in player.enrollments) _EnrollmentTile(state: state, enrollment: enrollment),
          // Amistosos: contagem à parte, fora do Geral.
          if (player.friendlyGoals > 0 || player.friendlyAssists > 0)
            ArenaCard(
              margin: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s8),
              padding: const EdgeInsets.all(AppSizes.s12),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.s40,
                    height: AppSizes.s40,
                    decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                    child: const Icon(Icons.handshake_outlined, color: AppColors.primaryDark, size: AppSizes.s20),
                  ),
                  const SizedBox(width: AppSizes.s12),
                  Expanded(
                    child: Text(l10n.athleteStatsFriendly, style: AppTypography.label(color: AppColors.textPrimary)),
                  ),
                  Text(
                    l10n.athleteEnrollmentStats(player.friendlyGoals, player.friendlyAssists),
                    style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ),
            ),
        ],
        if (isAdmin) _AdminEditor(player: player, saving: state.saving, state: state),
        _SectionLabel(l10n.athleteParticipations),
        if (state.participations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20, vertical: AppSizes.s8),
            child: Text(l10n.athleteNoParticipations, style: AppTypography.subtitle()),
          )
        else
          for (final card in state.participations) _ParticipationTile(card: card, playerId: player.id),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final PlayerProfileState state;
  final PlayerDTO player;

  const _Header({required this.state, required this.player});

  @override
  Widget build(BuildContext context) {
    final team = state.team;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: player.imageUrl.isEmpty ? null : () => PhotoGalleryPage.open(context, images: [player.imageUrl]),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s4),
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                PlayerAvatar(player: player, size: AppSizes.s120),
                if (state.saving)
                  const SizedBox(
                    width: AppSizes.s120,
                    height: AppSizes.s120,
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.s12),
        Text(
          player.name,
          textAlign: TextAlign.center,
          style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s24),
        ),
        if (player.team.isNotEmpty) ...[
          const SizedBox(height: AppSizes.s10),
          Material(
            color: AppColors.whiteMuted,
            borderRadius: BorderRadius.circular(AppSizes.s20),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.s20),
              onTap: team == null ? null : () => openTeamRoster(context, {'team': team}),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s6, AppSizes.s4, AppSizes.s8, AppSizes.s4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TeamCrest(imageUrl: team?.imageUrl, size: AppSizes.s24),
                    const SizedBox(width: AppSizes.s6),
                    Text(player.team,
                        style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14)),
                    if (team != null)
                      const Icon(Icons.chevron_right_rounded, size: AppSizes.s18, color: AppColors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Número grande com a posição no ranking embaixo.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final String rank;

  const _StatCard({required this.icon, required this.label, required this.value, required this.rank});

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s14, horizontal: AppSizes.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.s16, color: AppColors.primary),
              const SizedBox(width: AppSizes.s6),
              Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            ],
          ),
          const SizedBox(height: AppSizes.s4),
          Text('$value', style: AppTypography.display().copyWith(fontSize: AppSizes.s32)),
          Text(
            rank,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
          ),
        ],
      ),
    );
  }
}

/// Edição do admin: foto, nome e os números (cada toque grava).
/// Uma inscrição: escudo, time, competição e os números dela; abre o elenco
/// do time já na competição.
class _EnrollmentTile extends StatelessWidget {
  final PlayerProfileState state;
  final PlayerEnrollment enrollment;

  const _EnrollmentTile({required this.state, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final team = state.teamOf(teamId: enrollment.teamId, name: enrollment.team);
    final title = state.championshipTitle(enrollment.championshipId);
    return ArenaCard(
      margin: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s8),
      padding: const EdgeInsets.all(AppSizes.s12),
      onTap: team == null
          ? null
          : () => openTeamRoster(context, {'team': team, 'championshipId': enrollment.championshipId}),
      child: Row(
        children: [
          TeamCrest(imageUrl: team?.imageUrl, size: AppSizes.s40),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(enrollment.team, style: AppTypography.label(color: AppColors.textPrimary)),
                Text(
                  title.isEmpty ? l10n.athleteChampionshipFallback(enrollment.championshipId) : title,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
          Text(
            l10n.athleteEnrollmentStats(enrollment.goals, enrollment.assists),
            style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
          ),
          if (team != null) const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _AdminEditor extends StatefulWidget {
  final PlayerDTO player;
  final bool saving;
  final PlayerProfileState state;

  const _AdminEditor({required this.player, required this.saving, required this.state});

  @override
  State<_AdminEditor> createState() => _AdminEditorState();
}

class _AdminEditorState extends State<_AdminEditor> {
  late final _nameController = TextEditingController(text: widget.player.name);

  /// Competição dos ajustes (nula = Geral; [PlayerDTO.friendlyId] = amistosos).
  int? _championshipId;

  PlayerEnrollment? get _enrollment {
    final id = _championshipId;
    return id == null || id == PlayerDTO.friendlyId ? null : widget.player.enrollmentIn(id);
  }

  @override
  void didUpdateWidget(covariant _AdminEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nome mudou fora daqui (ex.: salvo) e o campo não está sendo editado.
    if (oldWidget.player.name != widget.player.name && _nameController.text == oldWidget.player.name) {
      _nameController.text = widget.player.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _rename(AppLocalizations l10n) async {
    final value = _nameController.text.trim();
    if (value.length < 3) {
      showSnackBar(context: context, message: l10n.playersNameRequired, isSuccess: false);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (value == widget.player.name) return;
    await BlocProvider.of<PlayerProfileCubit>(context).rename(value);
  }

  /// Com conta vinculada, só tira do elenco (mantém os números); sem conta,
  /// exclui o jogador.
  Future<void> _confirmRemoval(AppLocalizations l10n) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final player = widget.player;
    final linked = player.userId.isNotEmpty;
    final enrollment = _enrollment;
    final team = enrollment?.team ?? player.team;
    final confirmed = await showArenaConfirm(
      context,
      title: linked ? l10n.athleteRemoveTitle(player.name) : l10n.athleteDeleteTitle(player.name),
      message: linked ? l10n.athleteRemoveMessage(player.name, team) : l10n.athleteDeleteMessage(player.name, team),
      confirmLabel: linked ? l10n.athleteRemoveFromSquad : l10n.commonDelete,
      icon: linked ? Icons.person_remove_outlined : Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (!confirmed || !mounted) return;
    final cubit = BlocProvider.of<PlayerProfileCubit>(context);
    linked ? await cubit.removeFromSquad(championshipId: enrollment?.championshipId) : await cubit.delete();
  }

  Future<void> _pickPhoto() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final cubit = BlocProvider.of<PlayerProfileCubit>(context);
    final file = await PlayerPhotoDialog.show(context);
    FocusManager.instance.primaryFocus?.unfocus();
    if (file != null) await cubit.changePhoto(file);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<PlayerProfileCubit>(context);
    final player = widget.player;
    final enrollment = _enrollment;
    final friendly = _championshipId == PlayerDTO.friendlyId;
    final championshipId = friendly ? PlayerDTO.friendlyId : enrollment?.championshipId;
    // Com inscrições, o Geral é a soma das competições: só mostra.
    final canAdjust = championshipId != null || player.isLegacy;
    final goals = friendly ? player.friendlyGoals : enrollment?.goals ?? player.goals;
    final assists = friendly ? player.friendlyAssists : enrollment?.assists ?? player.assists;
    final hint = friendly
        ? l10n.athleteStatsFriendlyHint
        : championshipId != null
            ? l10n.athleteStatsChampionshipHint
            : player.isLegacy
                ? l10n.athleteStatsTotalHint
                : l10n.athleteStatsTotalSumHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(l10n.athleteEdit),
        ArenaCard(
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
          padding: const EdgeInsets.all(AppSizes.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _rename(l10n),
                decoration: InputDecoration(
                  labelText: l10n.playersEditName,
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    tooltip: l10n.playersSaveName,
                    onPressed: widget.saving ? null : () => _rename(l10n),
                    icon: const Icon(Icons.check_rounded, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.s16),
              ...[
                Wrap(
                  spacing: AppSizes.s8,
                  runSpacing: AppSizes.s8,
                  children: [
                    ArenaChoiceChip(
                      label: l10n.athleteStatsTotal,
                      selected: championshipId == null,
                      onTap: () => setState(() => _championshipId = null),
                    ),
                    for (final e in player.enrollments)
                      ArenaChoiceChip(
                        label: widget.state.championshipTitle(e.championshipId).isEmpty
                            ? l10n.athleteChampionshipFallback(e.championshipId)
                            : widget.state.championshipTitle(e.championshipId),
                        selected: championshipId == e.championshipId,
                        onTap: () => setState(() => _championshipId = e.championshipId),
                      ),
                    ArenaChoiceChip(
                      label: l10n.athleteStatsFriendly,
                      selected: friendly,
                      onTap: () => setState(() => _championshipId = PlayerDTO.friendlyId),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s6),
                Text(
                  hint,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                const SizedBox(height: AppSizes.s12),
              ],
              CountStepper(
                icon: Icons.sports_soccer_rounded,
                label: l10n.playersSummaryGoals,
                value: goals,
                max: 999,
                enabled: canAdjust,
                onIncrement: () => cubit.adjustGoals(1, championshipId: championshipId),
                onDecrement: () => cubit.adjustGoals(-1, championshipId: championshipId),
              ),
              const SizedBox(height: AppSizes.s12),
              CountStepper(
                icon: Icons.assistant_rounded,
                label: l10n.playersSummaryAssists,
                value: assists,
                max: 999,
                enabled: canAdjust,
                onIncrement: () => cubit.adjustAssists(1, championshipId: championshipId),
                onDecrement: () => cubit.adjustAssists(-1, championshipId: championshipId),
              ),
              const SizedBox(height: AppSizes.s12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: widget.saving ? null : _pickPhoto,
                  icon: const Icon(Icons.photo_camera_outlined, size: AppSizes.s18),
                  label: Text(l10n.playersChangePhoto),
                ),
              ),
              // Vinculado e já sem time: não há o que remover.
              if (player.userId.isEmpty || player.team.isNotEmpty) ...[
                const Divider(height: AppSizes.s24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: widget.saving ? null : () => _confirmRemoval(l10n),
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                    icon: const Icon(Icons.person_remove_outlined, size: AppSizes.s18),
                    label: Text(player.userId.isEmpty ? l10n.athleteDelete : l10n.athleteRemoveFromSquad),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s24, AppSizes.s20, AppSizes.s8),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12, letterSpacing: 1),
      ),
    );
  }
}

/// Um card de gol do feed: ⚽ (marcou) ou ✦ (deu o passe), o placar e quando.
class _ParticipationTile extends StatelessWidget {
  final NewsDTO card;
  final String playerId;

  const _ParticipationTile({required this.card, required this.playerId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scored = card.scorerId == playerId;
    final date = card.date;

    return ArenaCard(
      margin: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s8),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
      child: Row(
        children: [
          Tooltip(
            message: scored ? l10n.athleteScored : l10n.athleteAssisted,
            child: Container(
              width: AppSizes.s36,
              height: AppSizes.s36,
              decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: Icon(
                scored ? Icons.sports_soccer_rounded : Icons.assistant_rounded,
                size: AppSizes.s18,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${card.homeTeam} ${card.homeGoals} × ${card.awayGoals} ${card.awayTeam}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                ),
                const SizedBox(height: AppSizes.s2),
                Text(
                  scored ? l10n.athleteScored : l10n.athleteAssisted,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
          if (date != null)
            Text(RelativeTime.format(date, l10n), style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
