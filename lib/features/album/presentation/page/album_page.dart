import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_layout.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_cubit.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_event_cubit.dart';
import 'package:arena_soccer/features/album/presentation/widgets/pack_opening_dialog.dart';
import 'package:arena_soccer/features/album/presentation/widgets/sticker_tile.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Álbum de figurinhas do evento ativo: progresso, o pacotinho do dia e uma
/// página por time com os espaços numerados.
class StickerAlbumPage extends StatefulWidget {
  const StickerAlbumPage({super.key});

  @override
  State<StickerAlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<StickerAlbumPage> {
  late final AlbumCubit _cubit;
  final _pages = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<AlbumCubit>(context);
    final event = BlocProvider.of<AlbumEventCubit>(context).state.event;
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (event != null && user != null) _cubit.start(event: event, userId: user.id);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Color _frameOf(AlbumState state, StickerDTO sticker) =>
      colorFromHex(state.teams[sticker.teamId]?.primaryColor ?? '') ?? AppColors.primary;

  void _goTo(int index) {
    _pages.animateToPage(index, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
            frameOf: (sticker) => _frameOf(state, sticker),
          );
        }
      },
      builder: (context, state) {
        final event = state.event;
        final pages = state.pages;
        final total = state.stickers.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              event?.title ?? l10n.albumTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
          ),
          body: event == null
              ? ArenaEmptyState(message: l10n.albumNoEvent, icon: Icons.collections_bookmark_outlined)
              : state.loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : Column(
                      children: [
                        _Header(state: state, total: total, onOpen: _cubit.openPack),
                        if (pages.isEmpty)
                          Expanded(child: ArenaEmptyState(message: l10n.albumEmpty, icon: Icons.style_outlined))
                        else ...[
                          SizedBox(
                            height: AppSizes.s48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s6),
                              itemCount: pages.length,
                              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s8),
                              itemBuilder: (context, i) => ArenaChoiceChip(
                                label: pages[i].team,
                                icon: pages[i].isComplete(state.album) ? Icons.verified_rounded : null,
                                selected: i == _page,
                                onTap: () => _goTo(i),
                              ),
                            ),
                          ),
                          Expanded(
                            child: PageView.builder(
                              controller: _pages,
                              itemCount: pages.length,
                              onPageChanged: (i) => setState(() => _page = i),
                              itemBuilder: (context, i) => _TeamPage(
                                page: pages[i],
                                state: state,
                                frame: pages[i].stickers.isEmpty
                                    ? AppColors.primary
                                    : _frameOf(state, pages[i].stickers.first),
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

/// Progresso, repetidas e o botão do pacote do dia.
class _Header extends StatelessWidget {
  final AlbumState state;
  final int total;
  final VoidCallback onOpen;

  const _Header({required this.state, required this.total, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final collected = state.collected;
    final duplicates = state.album.duplicates(state.stickers);

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s4),
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryMedium, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.albumProgress(collected, total),
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                ),
              ),
              if (duplicates > 0)
                Text(
                  l10n.albumDuplicates(duplicates),
                  style: AppTypography.label(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.s6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: total == 0 ? 0 : collected / total),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: AppSizes.s8,
                backgroundColor: AppColors.whiteMuted,
                color: AppColors.googleYellow,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.s12),
          FilledButton.icon(
            onPressed: state.packAvailable ? onOpen : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.googleYellow,
              foregroundColor: AppColors.black,
              disabledBackgroundColor: AppColors.whiteMuted,
              disabledForegroundColor: AppColors.whiteSoft,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
            ),
            icon: state.opening
                ? const SizedBox.square(
                    dimension: AppSizes.s18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                  )
                : Icon(state.packAvailable ? Icons.card_giftcard_rounded : Icons.schedule_rounded),
            label: Text(
              state.opening
                  ? l10n.albumPackOpeningShort
                  : state.packAvailable
                      ? l10n.albumOpenPack
                      : l10n.albumComeBackTomorrow,
              style: AppTypography.label(color: state.packAvailable ? AppColors.black : AppColors.whiteSoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// Página de um time: cabeçalho (escudo, nome, progresso, selo de completa) e
/// a grade de espaços.
class _TeamPage extends StatelessWidget {
  final AlbumTeamPage page;
  final AlbumState state;
  final Color frame;

  const _TeamPage({required this.page, required this.state, required this.frame});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final complete = page.isComplete(state.album);
    final crest = state.teams[page.teamId]?.imageUrl ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, AppSizes.s32),
      children: [
        Row(
          children: [
            TeamCrest(imageUrl: crest, size: AppSizes.s40),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(page.team, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                  Text(
                    l10n.albumPageProgress(page.collected(state.album), page.stickers.length),
                    style: AppTypography.subtitle(),
                  ),
                ],
              ),
            ),
            if (complete)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                decoration: BoxDecoration(color: frame, borderRadius: BorderRadius.circular(AppSizes.s20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, color: AppColors.white, size: AppSizes.s16),
                    const SizedBox(width: AppSizes.s4),
                    Text(l10n.albumPageComplete,
                        style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.s16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSizes.s12,
          crossAxisSpacing: AppSizes.s12,
          childAspectRatio: 3 / 4,
          children: [
            for (final sticker in page.stickers)
              StickerTile(sticker: sticker, count: state.album.countOf(sticker.id), frame: frame),
          ],
        ),
      ],
    );
  }
}
