import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_board.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/achievements_cubit.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_labels.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/team_change_policy.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/page/choose_team_page.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/team_change_notice.dart';
import 'package:arena_soccer/features/fan_card/domain/fan_card_number.dart';
import 'package:arena_soccer/features/fan_card/presentation/bloc/fan_card_cubit.dart';
import 'package:arena_soccer/features/fan_card/presentation/bloc/fan_card_state.dart';
import 'package:arena_soccer/features/fan_card/presentation/widgets/fan_card.dart';
import 'package:arena_soccer/features/fan_card/presentation/widgets/fan_card_tilt.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/image_source_sheet.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/share_image_frame.dart';
import 'package:arena_soccer/utils/components/share_image_sheet.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Carteirinha de torcedor do usuário logado: o cartão de sócio (frente e
/// verso, inclina e vira), as ações rápidas (compartilhar, foto, time) e o
/// nível de torcedor das conquistas.
class FanCardPage extends StatefulWidget {
  const FanCardPage({super.key});

  @override
  State<FanCardPage> createState() => _FanCardPageState();
}

class _FanCardPageState extends State<FanCardPage> {
  late final FanCardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<FanCardCubit>(context);
    _loadTeam();
  }

  void _loadTeam() {
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    _cubit.load(favoriteTeam: user?.favoriteTeam ?? '', favoriteTeamId: user?.favoriteTeamId ?? '');
  }

  Future<void> _pickPhoto(String userId) async {
    final source = await showImageSourceSheet(context);
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 800);
    if (picked == null || !mounted) return;
    await _cubit.changePhoto(userId: userId, photo: File(picked.path));
  }

  /// Troca de time: antes do prazo de 15 dias, só o aviso com a data.
  Future<void> _changeTeam(UserDTO user) async {
    if (user.hasFavoriteTeam && !TeamChangePolicy.canChange(user, DateTime.now())) {
      return showTeamChangeLocked(context, TeamChangePolicy.nextChangeAt(user));
    }
    await Navigator.pushNamed(context, AppRoutes.chooseTeamPage, arguments: const ChooseTeamArgs(canGoBack: true));
    if (!mounted) return;
    _loadTeam();
  }

  /// Frente do cartão (a mesma da tela, da prévia e da imagem compartilhada).
  FanCard _buildCard(FanCardState state, {double sheen = 0}) {
    final user = BlocProvider.of<SessionCubit>(context).state.user!;
    final region = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    // Vitrine das conquistas: nível e as 3 melhores medalhas (some sem nenhuma).
    final board = BlocProvider.of<AchievementsCubit>(context).state.board;
    final best = board.best(limit: 3);
    return FanCard(
      name: user.name,
      photoUrl: user.photoUrl,
      favoriteTeam: user.favoriteTeam,
      team: state.team,
      region: state.team?.region.isNotEmpty == true ? state.team!.region : region,
      memberSince: state.memberSince,
      number: fanCardNumber(user.id),
      playerTeam: BlocProvider.of<MyPlayerCubit>(context).state.teamName,
      ownedTeam: BlocProvider.of<OwnedTeamCubit>(context).state.teamName,
      level: best.isEmpty ? null : fanLevelLabel(AppLocalizations.of(context), board.level).toUpperCase(),
      medals: [for (final entry in best) (tier: entry.achievement.tier, icon: entry.achievement.icon)],
      sheen: sheen,
    );
  }

  FanCardBack _buildBack(FanCardState state, {double sheen = 0}) {
    final l10n = AppLocalizations.of(context);
    final user = BlocProvider.of<SessionCubit>(context).state.user!;
    final board = BlocProvider.of<AchievementsCubit>(context).state.board;
    return FanCardBack(
      name: user.name,
      number: fanCardNumber(user.id),
      team: state.team,
      favoriteTeam: user.favoriteTeam,
      season: BlocProvider.of<RegionCubit>(context).state.selectedSeason,
      qrData: appLink,
      stats: board.unlocked.isEmpty
          ? ''
          : l10n.fanCardBackStats(fanLevelLabel(l10n, board.level), board.xp, board.unlocked.length),
      sheen: sheen,
    );
  }

  void _share() {
    final l10n = AppLocalizations.of(context);
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (user == null || _cubit.state.loading) return;
    showShareImageSheet(
      context,
      title: l10n.fanCardShareTitle,
      fileName: 'carteirinha_arena',
      preview: ShareImageFrame(card: _buildCard(_cubit.state), date: DateTime.now()),
      shareText: '${user.hasFavoriteTeam ? l10n.fanCardShareText(user.favoriteTeam) : l10n.fanCardShareTextNoTeam}'
          '\n$appLink',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<SessionCubit>().state.user;
    // Reconstrói quando região/papéis/conquistas mudam (o card lê os valores em _buildCard).
    context.watch<RegionCubit>();
    context.watch<MyPlayerCubit>();
    context.watch<OwnedTeamCubit>();
    final board = context.watch<AchievementsCubit>().state.board;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.fanCardTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
        actions: [
          if (user != null)
            IconButton(tooltip: l10n.fanCardShare, onPressed: _share, icon: const Icon(Icons.share_rounded)),
        ],
      ),
      body: user == null
          ? const SizedBox.shrink()
          : BlocConsumer<FanCardCubit, FanCardState>(
              listener: (context, state) {
                if (state is PhotoSavedFanCardState) {
                  final session = BlocProvider.of<SessionCubit>(context);
                  final current = session.state.user;
                  if (current != null) session.updateUser(current.copyWith(photoUrl: state.photoUrl));
                  showSnackBar(context: context, message: l10n.fanCardPhotoSaved);
                }
                if (state is ErrorFanCardState) {
                  showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
                }
              },
              builder: (context, state) {
                final teamLocked = user.hasFavoriteTeam && !TeamChangePolicy.canChange(user, DateTime.now());
                return ListView(
                  padding: EdgeInsets.only(bottom: safeBottom(context, AppSizes.s32)),
                  children: [
                    _Showcase(
                      glow: FanCard.paletteFor(state.team).accent,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: state.loading
                            ? const _FanCardSkeleton(key: ValueKey('skeleton'))
                            : FanCardTilt(
                                key: const ValueKey('card'),
                                front: (sheen) => _buildCard(state, sheen: sheen),
                                back: (sheen) => _buildBack(state, sheen: sheen),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                      // As ações sobem por cima do fim da vitrine.
                      child: Transform.translate(
                        offset: const Offset(0, -AppSizes.s28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickAction(
                                    icon: Icons.ios_share_rounded,
                                    label: l10n.fanCardActionShare,
                                    onTap: state.loading ? null : _share,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.s10),
                                Expanded(
                                  child: _QuickAction(
                                    key: const ValueKey('fan-card-photo'),
                                    icon: Icons.photo_camera_rounded,
                                    label: user.photoUrl.isEmpty ? l10n.fanCardAddPhoto : l10n.fanCardActionPhoto,
                                    busy: state.savingPhoto,
                                    onTap: state.savingPhoto ? null : () => _pickPhoto(user.id),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.s10),
                                Expanded(
                                  child: _QuickAction(
                                    key: const ValueKey('fan-card-team'),
                                    icon: teamLocked ? Icons.lock_clock_rounded : Icons.shield_rounded,
                                    label: l10n.fanCardActionTeam,
                                    muted: teamLocked,
                                    onTap: () => _changeTeam(user),
                                  ),
                                ),
                              ],
                            ),
                            if (teamLocked && TeamChangePolicy.nextChangeAt(user) != null) ...[
                              const SizedBox(height: AppSizes.s8),
                              Text(
                                l10n.fanCardChangeTeamNextAt(
                                    teamChangeDate(context, TeamChangePolicy.nextChangeAt(user)!)),
                                textAlign: TextAlign.center,
                                style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                              ),
                            ],
                            const SizedBox(height: AppSizes.s24),
                            if (board.entries.isNotEmpty)
                              FormSection(title: l10n.fanCardLevelSection, child: _LevelPanel(board: board)),
                            Text(
                              l10n.fanCardHint,
                              textAlign: TextAlign.center,
                              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

/// Vitrine: o fundo da marca com um brilho na cor do time atrás do cartão,
/// a dica de virar e o degradê que funde com o fundo do app.
class _Showcase extends StatelessWidget {
  final Color glow;
  final Widget child;

  const _Showcase({required this.glow, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        ArenaHeroBackground(
          watermarkFactor: 0.7,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.75,
                      colors: [glow.withValues(alpha: 0.45), AppColors.transparent],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s28, AppSizes.s24, AppSizes.s56),
                child: Column(
                  children: [
                    child,
                    const SizedBox(height: AppSizes.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app_rounded, color: AppColors.whiteSoft, size: AppSizes.s16),
                        const SizedBox(width: AppSizes.s6),
                        Text(
                          l10n.fanCardFlipHint,
                          style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Funde o fundo verde com o fundo do app.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: AppSizes.s32,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.background.withValues(alpha: 0), AppColors.background],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botão compacto das ações: ícone num círculo e rótulo embaixo, num card
/// que sobe por cima do fim da vitrine.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final bool muted;

  const _QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.textSecondary : AppColors.primary;
    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s12, horizontal: AppSizes.s6),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: AppSizes.s44,
            height: AppSizes.s44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(AppSizes.s12),
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                  )
                : Icon(icon, color: color, size: AppSizes.s22),
          ),
          const SizedBox(height: AppSizes.s8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.label(color: muted ? AppColors.textSecondary : AppColors.textPrimary)
                .copyWith(fontSize: AppSizes.s12),
          ),
        ],
      ),
    );
  }
}

/// Nível de torcedor: o nível, o XP, a barra até o próximo e as medalhas
/// desbloqueadas; "Ver conquistas" abre a tela delas.
class _LevelPanel extends StatelessWidget {
  final AchievementBoard board;

  const _LevelPanel({required this.board});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final xp = board.xp;
    final level = FanLevel.of(xp);
    final next = level.next;
    final medals = board.best(limit: 6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: AppSizes.s48,
              height: AppSizes.s48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.medalGoldLight, AppColors.gold, AppColors.medalGoldDark],
                ),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.white, size: AppSizes.s28),
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fanLevelLabel(l10n, level).toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Anton',
                      fontSize: AppSizes.s24,
                      height: 1.1,
                      letterSpacing: 0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(l10n.achievementsXp(xp), style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.s12),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.s8),
          child: LinearProgressIndicator(
            value: level.progressOf(xp),
            minHeight: AppSizes.s8,
            backgroundColor: AppColors.greyLight,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: AppSizes.s6),
        Text(
          next == null ? l10n.fanCardMaxLevel : l10n.achievementsNextLevel(next.minXp - xp, fanLevelLabel(l10n, next)),
          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
        ),
        if (medals.isNotEmpty) ...[
          const SizedBox(height: AppSizes.s12),
          Wrap(
            spacing: AppSizes.s6,
            runSpacing: AppSizes.s6,
            children: [
              for (final entry in medals)
                MedalBadge(
                  tier: entry.achievement.tier,
                  icon: entry.achievement.icon,
                  unlocked: true,
                  size: AppSizes.s36,
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSizes.s4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.achievementsPage),
            icon: const Icon(Icons.chevron_right_rounded, size: AppSizes.s18),
            label: Text(l10n.fanCardSeeAchievements),
          ),
        ),
      ],
    );
  }
}

/// Lugar da carteirinha enquanto o time do coração carrega: mesmo formato,
/// translúcido e pulsando de leve, sem cores de time.
class _FanCardSkeleton extends StatefulWidget {
  const _FanCardSkeleton({super.key});

  @override
  State<_FanCardSkeleton> createState() => _FanCardSkeletonState();
}

class _FanCardSkeletonState extends State<_FanCardSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: FanCard.aspectRatio,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.55, end: 1).animate(_pulse),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
        ),
      ),
    );
  }
}
