import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_cubit.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_event_cubit.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_cards.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_ranking.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_visuals.dart';
import 'package:arena_soccer/features/album/presentation/widgets/pack_opening_dialog.dart';
import 'package:arena_soccer/features/album/presentation/widgets/sticker_card.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Cor do time da figurinha (selo e faixa); sem cor, o verde do app.
Color albumAccentOf(AlbumState state, String teamId) =>
    colorFromHex(state.teams[teamId]?.primaryColor ?? '') ?? AppColors.primary;

/// Cores e escudo do time para desenhar a figurinha.
StickerStyle albumStyleOf(AlbumState state, String teamId) {
  final team = state.teams[teamId];
  return StickerStyle(
    accent: albumAccentOf(state, teamId),
    secondary: colorFromHex(team?.secondaryColor ?? ''),
    crestUrl: team?.imageUrl ?? '',
  );
}

/// Capa do álbum (no estilo dos álbuns digitais): o herói com o anel de
/// progresso, o pacotinho do dia, o índice dos times (cada um abre as páginas)
/// e a aba das repetidas.
class StickerAlbumPage extends StatefulWidget {
  const StickerAlbumPage({super.key});

  @override
  State<StickerAlbumPage> createState() => _StickerAlbumPageState();
}

class _StickerAlbumPageState extends State<StickerAlbumPage> {
  late final AlbumCubit _cubit;
  _CoverTab _tab = _CoverTab.teams;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<AlbumCubit>(context);
    final event = BlocProvider.of<AlbumEventCubit>(context).state.event;
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (event != null && user != null) _cubit.start(event: event, userId: user.id);
  }

  void _openPages(int index) {
    Navigator.pushNamed(context, AppRoutes.albumPagesPage, arguments: {'cubit': _cubit, 'index': index});
  }

  /// Só o admin: a abertura com um pacote simulado (5 figurinhas sorteadas
  /// do catálogo; novas = as que a conta não tem). Não grava nada.
  void _previewPack(AlbumState state) {
    if (state.stickers.isEmpty) return;
    final random = math.Random();
    final ids = [
      for (var i = 0; i < (state.event?.perPack ?? 5); i++) state.stickers[random.nextInt(state.stickers.length)].id
    ];
    showPackOpening(
      context,
      pack: AlbumPackDTO(
        id: 'preview',
        status: AlbumPackStatus.opened,
        stickers: ids,
        newOnes: ids.where((id) => !state.album.has(id)).toSet().toList(),
      ),
      stickerOf: state.sticker,
      frameOf: (sticker) => albumStyleOf(state, sticker.teamId),
      eventTitle: state.event?.title ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = BlocProvider.of<SessionCubit>(context).state.isAdmin;

    return BlocConsumer<AlbumCubit, AlbumState>(
      listener: (context, state) async {
        if (state is ErrorAlbumState) {
          showSnackBar(
            context: context,
            message: state.errorMessage.isEmpty ? l10n.albumPackFailed : state.errorMessage,
            isSuccess: false,
          );
        }
        if (state is PackOpenedAlbumState) {
          BlocProvider.of<AlbumEventCubit>(context).refresh();
          await showPackOpening(
            context,
            pack: state.pack,
            stickerOf: state.sticker,
            frameOf: (sticker) => albumStyleOf(state, sticker.teamId),
            eventTitle: state.event?.title ?? '',
          );
        }
      },
      builder: (context, state) {
        final event = state.event;
        if (event == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: AppColors.primaryDark, foregroundColor: AppColors.white),
            body: ArenaEmptyState(message: l10n.albumNoEvent, icon: Icons.collections_bookmark_outlined),
          );
        }
        final pages = state.pages;
        final duplicates = [
          for (final s in state.stickers)
            if (state.album.countOf(s.id) > 1) s,
        ];

        final ranking = state.ranking;
        return Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: _tab == _CoverTab.ranking && ranking != null
              ? AlbumMyPositionBar(view: ranking, total: state.stickers.length)
              : null,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: AppSizes.s250,
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.white,
                surfaceTintColor: AppColors.transparent,
                title: Text(
                  event.title,
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _Hero(state: state),
                ),
              ),
              if (state.loading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, 0),
                  sliver: SliverToBoxAdapter(
                    child: PackCard(
                      available: state.packAvailable,
                      opening: state.opening,
                      onOpen: _cubit.openPack,
                      onLongPress: isAdmin ? () => _previewPack(state) : null,
                      nextPackAt: state.nextPackAt,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s12),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: AppSizes.s8,
                      runSpacing: AppSizes.s8,
                      children: [
                        ArenaChoiceChip(
                          label: l10n.albumTabTeams,
                          icon: Icons.grid_view_rounded,
                          selected: _tab == _CoverTab.teams,
                          onTap: () => setState(() => _tab = _CoverTab.teams),
                        ),
                        ArenaChoiceChip(
                          label: l10n.albumTabDuplicates(duplicates.length),
                          icon: Icons.copy_all_rounded,
                          selected: _tab == _CoverTab.duplicates,
                          onTap: () => setState(() => _tab = _CoverTab.duplicates),
                        ),
                        ArenaChoiceChip(
                          label: l10n.albumTabRanking,
                          icon: Icons.emoji_events_outlined,
                          selected: _tab == _CoverTab.ranking,
                          onTap: () {
                            setState(() => _tab = _CoverTab.ranking);
                            _cubit.loadRanking();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (_tab == _CoverTab.teams && pages.isEmpty)
                  SliverToBoxAdapter(child: ArenaEmptyState(message: l10n.albumEmpty, icon: Icons.style_outlined))
                else if (_tab == _CoverTab.teams)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s32),
                    sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: AppSizes.s12,
                        crossAxisSpacing: AppSizes.s12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: pages.length,
                      itemBuilder: (context, i) => TeamIndexCard(
                        page: pages[i],
                        album: state.album,
                        crestUrl: state.teams[pages[i].teamId]?.imageUrl ?? '',
                        accent: albumAccentOf(state, pages[i].teamId),
                        onTap: () => _openPages(i),
                      ),
                    ),
                  )
                else if (_tab == _CoverTab.ranking)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s32),
                    sliver: SliverToBoxAdapter(
                      child: AlbumRankingSection(
                        view: state.ranking,
                        loading: state.rankingLoading,
                        total: state.stickers.length,
                        userId: BlocProvider.of<SessionCubit>(context).state.user?.id ?? '',
                        onRefresh: () => _cubit.loadRanking(force: true),
                      ),
                    ),
                  )
                else if (duplicates.isEmpty)
                  SliverToBoxAdapter(
                    child: ArenaEmptyState(message: l10n.albumNoDuplicates, icon: Icons.copy_all_outlined),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s6, AppSizes.s16, AppSizes.s32),
                    sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: AppSizes.s16,
                        crossAxisSpacing: AppSizes.s12,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: duplicates.length,
                      itemBuilder: (context, i) => StickerCard(
                        sticker: duplicates[i],
                        style: albumStyleOf(state, duplicates[i].teamId),
                        count: state.album.countOf(duplicates[i].id),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Herói da capa: fundo escuro com listras diagonais, o anel com a % e os
/// números (coladas, faltam, repetidas).
class _Hero extends StatelessWidget {
  final AlbumState state;

  const _Hero({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = state.stickers.length;
    final collected = state.collected;
    final percent = total == 0 ? 0 : (collected * 100 / total).floor();
    final rares = state.stickers.where((s) => s.rare).toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primaryMedium],
            ),
          ),
        ),
        CustomPaint(painter: StripesPainter(color: AppColors.white.withValues(alpha: 0.04), diagonal: true)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s60, AppSizes.s20, AppSizes.s20),
            child: Row(
              children: [
                AlbumProgressRing(
                  value: total == 0 ? 0 : collected / total,
                  size: AppSizes.s120,
                  stroke: AppSizes.s10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$percent%', style: AppTypography.display(color: AppColors.white)),
                      Text(
                        l10n.albumCompleted,
                        style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.s20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Stat(value: collected, label: l10n.albumStatCollected, color: AppColors.googleYellow),
                      _Stat(value: total - collected, label: l10n.albumStatMissing, color: AppColors.white),
                      _Stat(
                        value: state.album.duplicates(state.stickers),
                        label: l10n.albumStatDuplicates,
                        color: AppColors.whiteSoft,
                      ),
                      if (rares.isNotEmpty)
                        _Stat(
                          value: rares.where((s) => state.album.has(s.id)).length,
                          label: l10n.albumStatRares(rares.length),
                          color: AppColors.gold,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: AppSizes.s48,
            child: Text('$value', style: AppTypography.title(color: color).copyWith(fontSize: AppSizes.s22)),
          ),
          Text(label, style: AppTypography.subtitle(color: AppColors.whiteSoft)),
        ],
      ),
    );
  }
}

/// Abas da capa: índice dos times, repetidas e o ranking de colecionadores.
enum _CoverTab { teams, duplicates, ranking }

