import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/album/domain/album_layout.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_cubit.dart';
import 'package:arena_soccer/features/album/presentation/page/album_page.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_visuals.dart';
import 'package:arena_soccer/features/album/presentation/widgets/sticker_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Páginas do álbum em tela cheia, uma por time, com a virada de página em
/// perspectiva. Usa o mesmo [AlbumCubit] da capa (nenhuma leitura nova).
class AlbumPagesPage extends StatefulWidget {
  final int initialPage;

  const AlbumPagesPage({super.key, this.initialPage = 0});

  @override
  State<AlbumPagesPage> createState() => _AlbumPagesPageState();
}

class _AlbumPagesPageState extends State<AlbumPagesPage> {
  late final PageController _controller = PageController(initialPage: widget.initialPage);
  late int _page = widget.initialPage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta, int count) {
    final target = (_page + delta).clamp(0, count - 1);
    _controller.animateToPage(target, duration: const Duration(milliseconds: 450), curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumCubit, AlbumState>(
      builder: (context, state) {
        final pages = state.pages;
        return Scaffold(
          backgroundColor: AppColors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: AppColors.transparent,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            title: Text(
              state.event?.title ?? '',
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s16),
            ),
          ),
          body: pages.isEmpty
              ? const SizedBox.shrink()
              : Stack(
                  children: [
                    PageView.builder(
                      controller: _controller,
                      itemCount: pages.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (context, i) => AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final position = _controller.hasClients && _controller.position.haveDimensions
                              ? (_controller.page ?? _page.toDouble()) - i
                              : (_page - i).toDouble();
                          return _PageTurn(position: position, child: child!);
                        },
                        child: _TeamSpread(page: pages[i], state: state),
                      ),
                    ),
                    // Setas e indicador.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: AppSizes.s16,
                      child: SafeArea(
                        top: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Arrow(
                                icon: Icons.chevron_left_rounded,
                                onTap: _page > 0 ? () => _go(-1, pages.length) : null),
                            const SizedBox(width: AppSizes.s12),
                            _Dots(count: pages.length, current: _page),
                            const SizedBox(width: AppSizes.s12),
                            _Arrow(
                              icon: Icons.chevron_right_rounded,
                              onTap: _page < pages.length - 1 ? () => _go(1, pages.length) : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// Virada de página: a página gira no eixo Y a partir da lombada (lado
/// esquerdo ao sair, direito ao entrar) e escurece na dobra.
class _PageTurn extends StatelessWidget {
  final double position;
  final Widget child;

  const _PageTurn({required this.position, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = position.clamp(-1.0, 1.0);
    final leaving = p > 0;
    return Transform(
      alignment: leaving ? Alignment.centerLeft : Alignment.centerRight,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY((leaving ? -1 : 1) * p.abs() * math.pi / 2.6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          IgnorePointer(
            child: ColoredBox(color: AppColors.black.withValues(alpha: (p.abs() * 0.55).clamp(0.0, 0.55))),
          ),
        ],
      ),
    );
  }
}

/// Uma página: fundo do time (gradiente das cores + gramado), faixa com o
/// escudo e o progresso, e a grade de espaços/figurinhas.
class _TeamSpread extends StatelessWidget {
  final AlbumTeamPage page;
  final AlbumState state;

  const _TeamSpread({required this.page, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final team = state.teams[page.teamId];
    final primary = colorFromHex(team?.primaryColor ?? '') ?? AppColors.primary;
    final secondary = colorFromHex(team?.secondaryColor ?? '') ?? AppColors.primaryDark;
    final style = albumStyleOf(state, page.teamId);
    final collected = page.collected(state.album);
    final complete = page.isComplete(state.album);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [darken(primary, 0.12), darken(secondary, 0.3), darken(primary, 0.38)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: StripesPainter(color: AppColors.white.withValues(alpha: 0.035), width: 28)),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s48, AppSizes.s16, AppSizes.s100),
              children: [
                // Faixa do time.
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.s6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: 10)],
                      ),
                      child: TeamCrest(imageUrl: team?.imageUrl ?? '', size: AppSizes.s56),
                    ),
                    const SizedBox(width: AppSizes.s14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            page.team.toUpperCase(),
                            maxLines: 2,
                            style: AppTypography.display(color: AppColors.white).copyWith(
                              fontSize: AppSizes.s22,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: AppSizes.s6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.s4),
                            child: LinearProgressIndicator(
                              value: page.stickers.isEmpty ? 0 : collected / page.stickers.length,
                              minHeight: AppSizes.s6,
                              backgroundColor: AppColors.whiteMuted,
                              color: AppColors.googleYellow,
                            ),
                          ),
                          const SizedBox(height: AppSizes.s4),
                          Text(
                            l10n.albumPageProgress(collected, page.stickers.length),
                            style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (complete) ...[
                  const SizedBox(height: AppSizes.s12),
                  const Align(alignment: Alignment.centerRight, child: _CompleteStamp()),
                ],
                const SizedBox(height: AppSizes.s20),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSizes.s16,
                  crossAxisSpacing: AppSizes.s12,
                  childAspectRatio: 3 / 4,
                  children: [
                    for (final sticker in page.stickers)
                      state.album.has(sticker.id)
                          ? StickerCard(
                              sticker: sticker,
                              style: style,
                              count: state.album.countOf(sticker.id),
                              heroTag: 'sticker_${sticker.id}',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.stickerDetailPage,
                                arguments: {
                                  'cubit': context.read<AlbumCubit>(),
                                  'teamId': page.teamId,
                                  'stickerId': sticker.id,
                                },
                              ),
                            )
                          : EmptySlot(sticker: sticker),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carimbo "PÁGINA COMPLETA" (entra com escala e rotação).
class _CompleteStamp extends StatelessWidget {
  const _CompleteStamp();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 2.2, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.rotate(
        angle: -0.14,
        child: Transform.scale(scale: scale, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.googleYellow, width: AppSizes.s2),
          borderRadius: BorderRadius.circular(AppSizes.s6),
        ),
        child: Text(
          l10n.albumPageCompleteStamp,
          style: AppTypography.label(color: AppColors.googleYellow).copyWith(
            fontSize: AppSizes.s14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _Arrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.black.withValues(alpha: onTap == null ? 0.15 : 0.35),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: onTap == null ? AppColors.whiteMuted : AppColors.white),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    // Muitas páginas: só "3/12" em vez dos pontos.
    if (count > 9) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppSizes.s20),
        ),
        child: Text('${current + 1}/$count', style: AppTypography.label(color: AppColors.white)),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.s2),
            width: i == current ? AppSizes.s20 : AppSizes.s6,
            height: AppSizes.s6,
            decoration: BoxDecoration(
              color: i == current ? AppColors.googleYellow : AppColors.whiteMuted,
              borderRadius: BorderRadius.circular(AppSizes.s4),
            ),
          ),
      ],
    );
  }
}
