import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/achievements_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_labels.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/features/referrals/presentation/bloc/referral_config_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_gold_avatar.dart';

/// Fontes esportivas empacotadas (as mesmas dos cards do feed e das artes).
const _display = 'Anton';
const _condensed = 'BarlowCondensed';

/// Cubit global, se houver (testes e prévias montam o menu sem ele).
T? _maybeOf<T extends StateStreamableSource<Object?>>(BuildContext context) {
  try {
    return BlocProvider.of<T>(context);
  } catch (_) {
    return null;
  }
}

/// Menu lateral da home: cabeçalho "carteirinha" (foto do atleta ou escudo do time do coração,
/// nome, papéis e o nível das conquistas), atalhos em grade colorida, "Em
/// campo" com os pedidos/áreas da conta, o bloco do admin e, no rodapé,
/// Configurações e Sair.
class HomeDrawer extends StatelessWidget {
  final UserDTO? user;
  final String? favoriteTeamImage;

  /// Pedidos "Sou jogador" pendentes (contador do item do admin).
  final int pendingPlayerRequests;

  /// Pedidos "Sou dono de time" pendentes (contador do item do admin).
  final int pendingTeamRequests;

  /// Pedidos "Sou parceiro" pendentes (contador do item do admin).
  final int pendingPartnerRequests;

  /// Time em que a conta joga ("Sou jogador" aprovado) e o atleta dela.
  final String? playerTeam;
  final String? playerId;
  final String? playerSeason;

  /// Foto do atleta da conta: no cabeçalho, no lugar do escudo do time.
  final String? playerPhotoUrl;

  /// Time do qual a conta é dona/treinadora ("Sou dono de time" aprovado).
  final String? ownedTeam;

  /// "Sou parceiro" aprovado.
  final bool isPartner;
  final VoidCallback onChooseTeam;
  final VoidCallback onLogout;

  /// Âncoras do tour do menu (nulo = sem tour).
  final HomeDrawerTourKeys? tourKeys;

  /// XP das conquistas; nulo = lido do `AchievementsCubit` global (sem ele ou
  /// carregando, sem a barra de nível).
  final int? fanXp;

  /// "Indique amigos" ligado; nulo = lido do `ReferralConfigCubit` global.
  final bool? referralsEnabled;

  const HomeDrawer({
    super.key,
    this.user,
    this.favoriteTeamImage,
    this.pendingPlayerRequests = 0,
    this.pendingTeamRequests = 0,
    this.pendingPartnerRequests = 0,
    this.playerTeam,
    this.playerId,
    this.playerSeason,
    this.playerPhotoUrl,
    this.ownedTeam,
    this.isPartner = false,
    required this.onChooseTeam,
    required this.onLogout,
    this.tourKeys,
    this.fanXp,
    this.referralsEnabled,
  });

  void _open(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  int? _xp(BuildContext context) {
    if (fanXp != null) return fanXp;
    final cubit = _maybeOf<AchievementsCubit>(context);
    if (cubit == null || cubit.state.loading) return null;
    return cubit.state.board.xp;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Admin efetivo: no modo jogador, o menu é o de um jogador.
    final isAdmin = _maybeOf<SessionCubit>(context)?.state.isAdmin ?? (user?.isAdmin ?? false);
    final loggedIn = user != null;
    final referrals = referralsEnabled ?? _maybeOf<ReferralConfigCubit>(context)?.state.enabled ?? false;

    final shortcuts = [
      _Shortcut(
        key: tourKeys?.predictions,
        icon: Icons.scoreboard_rounded,
        title: l10n.drawerPredictions,
        color: AppColors.primaryStrong,
        onTap: () => _open(context, AppRoutes.predictionRankingPage),
      ),
      if (loggedIn)
        _Shortcut(
          key: tourKeys?.achievements,
          icon: Icons.military_tech_rounded,
          title: l10n.drawerAchievements,
          color: AppColors.medalGoldDark,
          onTap: () => _open(context, AppRoutes.achievementsPage),
        ),
      _Shortcut(
        icon: Icons.groups_rounded,
        title: l10n.fanRankingTitle,
        color: AppColors.teamOrange,
        onTap: () => _open(context, AppRoutes.fanRankingPage),
      ),
      if (loggedIn)
        _Shortcut(
          icon: Icons.badge_rounded,
          title: l10n.fanCardMenu,
          color: AppColors.teamBlue,
          onTap: () => _open(context, AppRoutes.fanCardPage),
        ),
      if (loggedIn && referrals)
        _Shortcut(
          icon: Icons.group_add_rounded,
          title: l10n.referralTitle,
          color: AppColors.teamPurple,
          onTap: () => _open(context, AppRoutes.referralPage),
        ),
      _Shortcut(
        icon: Icons.public_rounded,
        title: l10n.drawerResults,
        color: AppColors.teamNavy,
        onTap: () => _open(context, AppRoutes.globalResultsPage),
      ),
    ];

    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.85,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppSizes.radiusLarge)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          KeyedSubtree(
            key: tourKeys?.header,
            child: _ProfileHeader(
              user: user,
              favoriteTeamImage: favoriteTeamImage,
              playerPhotoUrl: playerId == null ? null : playerPhotoUrl,
              playerTeam: playerTeam,
              ownedTeam: ownedTeam,
              xp: loggedIn ? _xp(context) : null,
              onOpenAchievements: () => _open(context, AppRoutes.achievementsPage),
              onOpenPlayer: playerId == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      openAthlete(context, {'playerId': playerId, 'season': playerSeason});
                    },
              onOpenOwnedTeam: () => _open(context, AppRoutes.teamRequestPage),
              onOpenProfile: () => _open(context, AppRoutes.profilePage),
              onChooseTeam: () {
                Navigator.pop(context);
                onChooseTeam();
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s16, AppSizes.s14, AppSizes.s16),
              children: [
                _SectionLabel(l10n.drawerFanSection),
                _ShortcutGrid(shortcuts: shortcuts),
                if (loggedIn) ...[
                  const SizedBox(height: AppSizes.s20),
                  _SectionLabel(l10n.drawerOnFieldSection),
                  _Panel(
                    children: [
                      _RichItem(
                        key: tourKeys?.player,
                        icon: Icons.sports_soccer_rounded,
                        color: AppColors.primaryStrong,
                        title: playerTeam != null ? l10n.drawerMyPlayerProfile : l10n.playerRequestMenu,
                        subtitle: playerTeam != null ? l10n.drawerPlayerHintApproved : l10n.drawerPlayerHint,
                        onTap: () => _open(context, AppRoutes.playerRequestPage),
                      ),
                      _RichItem(
                        icon: Icons.shield_rounded,
                        color: AppColors.teamBlue,
                        title: ownedTeam != null ? l10n.myTeamTitle : l10n.teamRequestMenu,
                        subtitle: ownedTeam != null ? l10n.drawerOwnerHintApproved : l10n.drawerOwnerHint,
                        onTap: () => _open(context, AppRoutes.teamRequestPage),
                      ),
                      _RichItem(
                        icon: Icons.handshake_rounded,
                        color: AppColors.teamOrange,
                        title: isPartner ? l10n.partnerMenuApproved : l10n.partnerMenu,
                        subtitle: isPartner ? l10n.drawerPartnerHintApproved : l10n.drawerPartnerHint,
                        onTap: () => _open(context, AppRoutes.partnerRequestPage),
                      ),
                      _RichItem(
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.medalGoldDark,
                        title: l10n.organizerRequestMenu,
                        subtitle: l10n.drawerOrganizerHint,
                        onTap: () => _open(context, AppRoutes.organizerRequestPage),
                      ),
                    ],
                  ),
                ],
                if (isAdmin) ...[
                  const SizedBox(height: AppSizes.s20),
                  _AdminBlock(
                    title: l10n.drawerAdmin,
                    items: [
                      _AdminItem(
                        icon: Icons.how_to_reg_rounded,
                        title: l10n.playerRequestsPanelTitle,
                        badge: pendingPlayerRequests,
                        onTap: () => _open(context, AppRoutes.playerRequestsPanelPage),
                      ),
                      _AdminItem(
                        icon: Icons.add_moderator_rounded,
                        title: l10n.teamRequestsPanelTitle,
                        badge: pendingTeamRequests,
                        onTap: () => _open(context, AppRoutes.teamRequestsPanelPage),
                      ),
                      _AdminItem(
                        icon: Icons.handshake_rounded,
                        title: l10n.partnerPanelTitle,
                        badge: pendingPartnerRequests,
                        onTap: () => _open(context, AppRoutes.partnerRequestsPanelPage),
                      ),
                      _AdminItem(
                        icon: Icons.emoji_events_rounded,
                        title: l10n.organizerRequestsPanelTitle,
                        onTap: () => _open(context, AppRoutes.organizerRequestsPanelPage),
                      ),
                      _AdminItem(
                        icon: Icons.admin_panel_settings_rounded,
                        title: l10n.adminPanelTitle,
                        onTap: () => _open(context, AppRoutes.adminPanelPage),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (loggedIn)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s4, AppSizes.s14, AppSizes.s14),
                child: Row(
                  children: [
                    Expanded(
                      child: _FooterButton(
                        icon: Icons.settings_rounded,
                        label: l10n.settingsTitle,
                        color: AppColors.textPrimary,
                        onTap: () => _open(context, AppRoutes.settingsPage),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s10),
                    Expanded(
                      child: _FooterButton(
                        icon: Icons.logout_rounded,
                        label: l10n.drawerLogout,
                        color: AppColors.danger,
                        onTap: () {
                          Navigator.pop(context);
                          onLogout();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final _headerButtonStyle = FilledButton.styleFrom(
  backgroundColor: AppColors.white,
  foregroundColor: AppColors.primaryDark,
  shape: const StadiumBorder(),
);

class _ProfileHeader extends StatelessWidget {
  final UserDTO? user;
  final String? favoriteTeamImage;

  /// "Meu perfil" (foto e nome da conta): toque no avatar sem foto de atleta e no nome.
  final VoidCallback onOpenProfile;

  /// Atleta da conta com foto: o avatar é a foto dele (toque abre o perfil).
  final String? playerPhotoUrl;
  final String? playerTeam;
  final String? ownedTeam;

  /// XP das conquistas (nulo = sem a barra de nível).
  final int? xp;
  final VoidCallback onOpenAchievements;
  final VoidCallback onChooseTeam;
  final VoidCallback? onOpenPlayer;
  final VoidCallback onOpenOwnedTeam;

  const _ProfileHeader({
    this.user,
    this.favoriteTeamImage,
    this.playerPhotoUrl,
    this.playerTeam,
    this.ownedTeam,
    this.xp,
    required this.onOpenAchievements,
    required this.onChooseTeam,
    this.onOpenPlayer,
    required this.onOpenOwnedTeam,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isGuest = user == null;
    final xp = this.xp;

    return ArenaHeroBackground(
      watermarkFactor: 0.9,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s20, AppSizes.s20, AppSizes.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    // À direita, espaço para o ✕.
                    padding: const EdgeInsets.only(right: AppSizes.s40),
                    child: Row(
                      children: [
                        // Jogador com foto: a foto do atleta; senão, a foto da conta;
                        // sem nenhuma, o escudo do time do coração.
                        if (playerPhotoUrl != null && playerPhotoUrl!.trim().isNotEmpty)
                          GestureDetector(
                            onTap: onOpenPlayer,
                            child: _Avatar(key: const ValueKey('drawer-player-photo'), image: playerPhotoUrl!.trim()),
                          )
                        else if (isGuest)
                          _Avatar(image: favoriteTeamImage)
                        else
                          Semantics(
                            button: true,
                            label: l10n.profileMenu,
                            child: GestureDetector(
                              onTap: onOpenProfile,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  user!.photoUrl.trim().isNotEmpty
                                      ? _Avatar(
                                          key: const ValueKey('drawer-account-photo'),
                                          image: user!.photoUrl.trim(),
                                        )
                                      : _Avatar(image: favoriteTeamImage),
                                  const Positioned(right: 0, bottom: 0, child: _EditBadge()),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(width: AppSizes.s14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: isGuest ? null : onOpenProfile,
                                child: Text(
                                  (isGuest ? l10n.drawerGuest : user!.name).toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: _display,
                                    fontSize: AppSizes.s24,
                                    height: 1.1,
                                    letterSpacing: 0.5,
                                    color: AppColors.white,
                                    shadows: [
                                      Shadow(color: AppColors.black.withValues(alpha: 0.3), offset: const Offset(0, 2))
                                    ],
                                  ),
                                ),
                              ),
                              if (isGuest) ...[
                                const SizedBox(height: AppSizes.s4),
                                Text(
                                  l10n.drawerGuestSubtitle,
                                  style: AppTypography.subtitle(color: AppColors.whiteSoft)
                                      .copyWith(fontSize: AppSizes.s12),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.s14),
                  if (isGuest)
                    FilledButton(
                      style: _headerButtonStyle,
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginPage, (_) => false),
                      child: Text(l10n.drawerSignIn),
                    )
                  else ...[
                    // Papéis da conta: dono/treinador, jogador e torcedor.
                    if (ownedTeam != null || playerTeam != null || user!.hasFavoriteTeam)
                      Wrap(
                        spacing: AppSizes.s6,
                        runSpacing: AppSizes.s6,
                        children: [
                          if (ownedTeam != null)
                            _RoleBadge(
                              icon: Icons.shield_rounded,
                              label: l10n.drawerOwnerOf(ownedTeam!),
                              highlighted: true,
                              onTap: onOpenOwnedTeam,
                            ),
                          if (playerTeam != null)
                            _RoleBadge(
                              icon: Icons.sports_soccer_rounded,
                              label: l10n.drawerPlayerOf(playerTeam!),
                              highlighted: true,
                              onTap: onOpenPlayer,
                            ),
                          if (user!.hasFavoriteTeam)
                            _RoleBadge(icon: Icons.favorite_rounded, label: l10n.drawerFanOf(user!.favoriteTeam)),
                        ],
                      ),
                    if (!user!.hasFavoriteTeam) ...[
                      if (ownedTeam != null || playerTeam != null) const SizedBox(height: AppSizes.s10),
                      FilledButton.icon(
                        style: _headerButtonStyle,
                        onPressed: onChooseTeam,
                        icon: const Icon(Icons.shield_outlined, size: AppSizes.s18),
                        label: Text(l10n.drawerChooseTeam),
                      ),
                    ],
                    if (xp != null) ...[
                      const SizedBox(height: AppSizes.s14),
                      _LevelBar(xp: xp, onTap: onOpenAchievements),
                    ],
                  ],
                ],
              ),
            ),
            // Mesmo círculo translúcido dos botões do cabeçalho da home.
            Positioned(
              top: AppSizes.s14,
              right: AppSizes.s12,
              child: Tooltip(
                message: l10n.drawerClose,
                child: Material(
                  color: AppColors.white.withValues(alpha: 0.12),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: AppSizes.s40,
                      height: AppSizes.s40,
                      child: Icon(Icons.close_rounded, color: AppColors.white, size: AppSizes.s22),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selo de lápis do avatar: abre "Meu perfil".
class _EditBadge extends StatelessWidget {
  const _EditBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.25), blurRadius: AppSizes.s4)],
      ),
      child: const Icon(Icons.edit_rounded, color: AppColors.primaryDark, size: AppSizes.s14),
    );
  }
}

/// Foto do atleta ou escudo do time do coração num anel dourado.
class _Avatar extends StatelessWidget {
  final String? image;

  const _Avatar({super.key, this.image});

  @override
  Widget build(BuildContext context) => ArenaGoldAvatar(image: image);
}

/// Nível das conquistas: "LEAL · 240 XP", barra dourada até o próximo nível
/// e quanto falta; o toque abre "Minhas conquistas".
class _LevelBar extends StatelessWidget {
  final int xp;
  final VoidCallback onTap;

  const _LevelBar({required this.xp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final level = FanLevel.of(xp);
    final next = level.next;
    final radius = BorderRadius.circular(AppSizes.s14);
    return Material(
      color: AppColors.black.withValues(alpha: 0.22),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s8, AppSizes.s10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.military_tech_rounded, color: AppColors.gold, size: AppSizes.s20),
                  const SizedBox(width: AppSizes.s6),
                  Expanded(
                    child: Text(
                      '${fanLevelLabel(l10n, level)}  ·  ${l10n.achievementsXp(xp)}'.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: _condensed,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSizes.s16,
                        letterSpacing: 1,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.whiteSoft, size: AppSizes.s20),
                ],
              ),
              const SizedBox(height: AppSizes.s8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.s4),
                child: LinearProgressIndicator(
                  value: level.progressOf(xp),
                  minHeight: AppSizes.s6,
                  color: AppColors.gold,
                  backgroundColor: AppColors.white.withValues(alpha: 0.18),
                ),
              ),
              if (next != null) ...[
                const SizedBox(height: AppSizes.s6),
                Text(
                  l10n.achievementsNextLevel(next.minXp - xp, fanLevelLabel(l10n, next)),
                  style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, 0, AppSizes.s4, AppSizes.s10),
      child: Row(
        children: [
          Container(width: AppSizes.s4, height: AppSizes.s14, color: AppColors.gold),
          const SizedBox(width: AppSizes.s8),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontFamily: _condensed,
              fontWeight: FontWeight.w700,
              fontSize: AppSizes.s14,
              letterSpacing: 1.8,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Atalho da grade: cartão na cor própria, ícone num círculo e o título.
class _Shortcut {
  final Key? key;
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _Shortcut({this.key, required this.icon, required this.title, required this.color, required this.onTap});
}

/// Grade 2 × N dos atalhos (o último sozinho ocupa a linha toda).
class _ShortcutGrid extends StatelessWidget {
  final List<_Shortcut> shortcuts;

  const _ShortcutGrid({required this.shortcuts});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSizes.s10;
        final half = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < shortcuts.length; i++)
              SizedBox(
                width: shortcuts.length.isOdd && i == shortcuts.length - 1 ? constraints.maxWidth : half,
                // Mesma altura em todos (título de 1 ou 2 linhas).
                height: AppSizes.s100,
                child: KeyedSubtree(key: shortcuts[i].key, child: _ShortcutTile(shortcut: shortcuts[i])),
              ),
          ],
        );
      },
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final _Shortcut shortcut;

  const _ShortcutTile({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    final color = shortcut.color;
    final radius = BorderRadius.circular(AppSizes.s16);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, AppColors.white, 0.12)!, Color.lerp(color, AppColors.black, 0.18)!],
        ),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: AppSizes.s10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: shortcut.onTap,
          child: Stack(
            children: [
              Positioned(
                right: -AppSizes.s14,
                bottom: -AppSizes.s14,
                child: Icon(shortcut.icon, size: AppSizes.s72, color: AppColors.white.withValues(alpha: 0.12)),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.s12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: AppSizes.s36,
                      height: AppSizes.s36,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(shortcut.icon, color: AppColors.white, size: AppSizes.s20),
                    ),
                    const Spacer(),
                    // Flexível: fonte maior (acessibilidade) não estoura o cartão.
                    Flexible(
                      flex: 6,
                      child: Text(
                        shortcut.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: _condensed,
                          fontWeight: FontWeight.w700,
                          fontSize: AppSizes.s16,
                          height: 1.05,
                          letterSpacing: 0.6,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão branco que agrupa os itens de "Em campo", com divisórias.
class _Panel extends StatelessWidget {
  final List<Widget> children;

  const _Panel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s10, offset: Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: AppSizes.s64, color: AppColors.greyLight),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Item com ícone num quadro colorido, título e subtítulo.
class _RichItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RichItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s8, AppSizes.s10),
        child: Row(
          children: [
            Container(
              width: AppSizes.s40,
              height: AppSizes.s40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.s12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.lerp(color, AppColors.white, 0.15)!, color],
                ),
              ),
              child: Icon(icon, color: AppColors.white, size: AppSizes.s22),
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                  ),
                  const SizedBox(height: AppSizes.s2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
          ],
        ),
      ),
    );
  }
}

/// Bloco escuro do admin, com borda dourada e os itens compactos.
class _AdminBlock extends StatelessWidget {
  final String title;
  final List<_AdminItem> items;

  const _AdminBlock({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, Color.lerp(AppColors.primaryDark, AppColors.black, 0.35)!],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s12, AppSizes.s14, AppSizes.s4),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.gold, size: AppSizes.s16),
                const SizedBox(width: AppSizes.s6),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: _condensed,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.s14,
                    letterSpacing: 1.8,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          ...items,
          const SizedBox(height: AppSizes.s6),
        ],
      ),
    );
  }
}

class _AdminItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  /// Contador ao lado do título (0 = sem contador).
  final int badge;

  const _AdminItem({required this.icon, required this.title, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.whiteSoft, size: AppSizes.s20),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
              ),
            ),
            if (badge > 0)
              Container(
                margin: const EdgeInsets.only(left: AppSizes.s8),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppSizes.s10)),
                child: Text(
                  '$badge',
                  style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                ),
              ),
            Icon(Icons.chevron_right_rounded, color: AppColors.white.withValues(alpha: 0.5), size: AppSizes.s20),
          ],
        ),
      ),
    );
  }
}

/// Botão-pílula do rodapé (Configurações / Sair).
class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FooterButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final shape = StadiumBorder(side: BorderSide(color: color.withValues(alpha: 0.25)));
    return Material(
      color: AppColors.surface,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: AppSizes.s18),
              const SizedBox(width: AppSizes.s6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selo do cabeçalho (papel da conta). Destacado = verde (jogador, dono).
class _RoleBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback? onTap;

  const _RoleBadge({required this.icon, required this.label, this.highlighted = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.s20);
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: highlighted ? AppColors.primary : AppColors.white.withValues(alpha: 0.15),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppSizes.s14, color: AppColors.white),
                const SizedBox(width: AppSizes.s4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Âncoras do tour do menu (criadas pela home).
class HomeDrawerTourKeys {
  final header = GlobalKey();
  final predictions = GlobalKey();
  final achievements = GlobalKey();
  final player = GlobalKey();
}
