import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/core/utils/relative_time.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_state.dart';
import 'package:arena_soccer/features/players/presentation/widgets/count_stepper.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_photo_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/photo_gallery_page.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

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

  void _share(PlayerProfileState state, AppLocalizations l10n) {
    final player = state.player;
    if (player == null) return;
    ShareService.shareText(
      l10n.athleteShareText(player.name, player.team, player.goals, player.assists),
      subject: player.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = context.watch<SessionCubit>().state.isAdmin;

    return BlocConsumer<PlayerProfileCubit, PlayerProfileState>(
      listenWhen: (_, current) => current is ErrorPlayerProfileState && current.player != null,
      listener: (context, state) => showSnackBar(
        context: context,
        message: (state as ErrorPlayerProfileState).errorMessage,
        isSuccess: false,
      ),
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
            _ => _Content(state: state, player: player, isAdmin: isAdmin, season: widget.season),
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
        if (isAdmin) _AdminEditor(player: player, saving: state.saving),
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
              onTap: team == null
                  ? null
                  : () => Navigator.pushNamed(context, AppRoutes.teamPlayersPage, arguments: {'team': team}),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s6, AppSizes.s4, AppSizes.s8, AppSizes.s4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TeamCrest(imageUrl: team?.imageUrl, size: AppSizes.s24),
                    const SizedBox(width: AppSizes.s6),
                    Text(player.team, style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14)),
                    if (team != null) const Icon(Icons.chevron_right_rounded, size: AppSizes.s18, color: AppColors.white),
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
class _AdminEditor extends StatefulWidget {
  final PlayerDTO player;
  final bool saving;

  const _AdminEditor({required this.player, required this.saving});

  @override
  State<_AdminEditor> createState() => _AdminEditorState();
}

class _AdminEditorState extends State<_AdminEditor> {
  late final _nameController = TextEditingController(text: widget.player.name);

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
              CountStepper(
                icon: Icons.sports_soccer_rounded,
                label: l10n.playersSummaryGoals,
                value: player.goals,
                max: 999,
                onIncrement: () => cubit.adjustGoals(1),
                onDecrement: () => cubit.adjustGoals(-1),
              ),
              const SizedBox(height: AppSizes.s12),
              CountStepper(
                icon: Icons.assistant_rounded,
                label: l10n.playersSummaryAssists,
                value: player.assists,
                max: 999,
                onIncrement: () => cubit.adjustAssists(1),
                onDecrement: () => cubit.adjustAssists(-1),
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
