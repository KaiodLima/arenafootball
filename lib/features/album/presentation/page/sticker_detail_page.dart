import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_cubit.dart';
import 'package:arena_soccer/features/album/presentation/page/album_page.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_visuals.dart';
import 'package:arena_soccer/features/album/presentation/widgets/sticker_card.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/share_image_sheet.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Texto de compartilhar uma figurinha (termina com o link do app).
String stickerShareText(AppLocalizations l10n, StickerDTO sticker, String eventTitle) =>
    '${l10n.albumDetailShareText(sticker.number, sticker.name, eventTitle)}\n$appLink';

/// Detalhe da figurinha, no molde das cartas colecionáveis (Ultimate Team,
/// Sorare, Panini Digital): fundo com a foto desfocada e o brilho do time, a
/// carta grande que inclina com o dedo (o reflexo acompanha) e vira para o
/// verso no toque, o painel com as informações e as ações, e o "folhear"
/// pelas outras coladas da mesma página.
class StickerDetailPage extends StatefulWidget {
  final String teamId;
  final String stickerId;

  const StickerDetailPage({super.key, required this.teamId, required this.stickerId});

  @override
  State<StickerDetailPage> createState() => _StickerDetailPageState();
}

class _StickerDetailPageState extends State<StickerDetailPage> {
  PageController? _controller;
  int _index = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AlbumCubit, AlbumState>(
      builder: (context, state) {
        final pages = state.pages;
        final pageIndex = pages.indexWhere((p) => p.teamId == widget.teamId);
        final stickers = pageIndex < 0 ? const <StickerDTO>[] : pages[pageIndex].collectedStickers(state.album);
        if (stickers.isEmpty) {
          return const Scaffold(backgroundColor: AppColors.black, body: SizedBox.shrink());
        }
        if (_controller == null) {
          _index = math.max(0, stickers.indexWhere((s) => s.id == widget.stickerId));
          _controller = PageController(initialPage: _index);
        }
        final current = stickers[_index.clamp(0, stickers.length - 1)];
        final style = albumStyleOf(state, widget.teamId);
        final accent = style.accent;
        final crestUrl = state.teams[widget.teamId]?.imageUrl ?? '';
        final eventTitle = state.event?.title ?? '';

        return Scaffold(
          backgroundColor: AppColors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              _Backdrop(sticker: current, accent: accent),
              SafeArea(
                child: Column(
                  children: [
                    _TopBar(
                      title: l10n.albumStickerCaption(current.number, current.team),
                      subtitle: l10n.albumDetailPosition(_index + 1, stickers.length),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: stickers.length,
                        onPageChanged: (i) {
                          HapticFeedback.selectionClick();
                          setState(() => _index = i);
                        },
                        itemBuilder: (context, i) => Center(
                          child: _TiltCard(
                            sticker: stickers[i],
                            style: style,
                            accent: accent,
                            crestUrl: crestUrl,
                            eventTitle: eventTitle,
                            count: state.album.countOf(stickers[i].id),
                          ),
                        ),
                      ),
                    ),
                    _Dots(count: stickers.length, index: _index, color: accent),
                    _InfoPanel(
                      sticker: current,
                      style: style,
                      accent: accent,
                      crestUrl: crestUrl,
                      eventTitle: eventTitle,
                      count: state.album.countOf(current.id),
                      page: pageIndex + 1,
                      pages: pages.length,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Fundo: a foto da figurinha ampliada e bem desfocada, escurecida, com o
/// brilho radial na cor do time atrás da carta. Troca com fade ao folhear.
class _Backdrop extends StatelessWidget {
  final StickerDTO sticker;
  final Color accent;

  const _Backdrop({required this.sticker, required this.accent});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Stack(
        key: ValueKey(sticker.id),
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [darken(accent, 0.15), darken(accent, 0.45)],
              ),
            ),
          ),
          if (sticker.imageUrl.isNotEmpty)
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30, tileMode: TileMode.decal),
              child: Opacity(
                opacity: 0.55,
                child: CachedNetworkImage(
                  imageUrl: sticker.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          CustomPaint(painter: StripesPainter(color: AppColors.white.withValues(alpha: 0.03), diagonal: true)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.25),
                radius: 0.75,
                colors: [accent.withValues(alpha: 0.55), AppColors.black.withValues(alpha: 0.65)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TopBar({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s4, AppSizes.s16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s16),
                ),
                Text(subtitle, style: AppTypography.subtitle(color: AppColors.whiteSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carta grande: inclina em 3D seguindo o dedo (até 15°, volta com mola),
/// balança de leve parada, o reflexo e a sombra acompanham a inclinação e o
/// toque vira para o verso. O toque é lido por [Listener] (fora da disputa de
/// gestos), então deslizar para os lados continua folheando.
class _TiltCard extends StatefulWidget {
  final StickerDTO sticker;
  final StickerStyle style;
  final Color accent;
  final String crestUrl;
  final String eventTitle;
  final int count;

  const _TiltCard({
    required this.sticker,
    required this.style,
    required this.accent,
    required this.crestUrl,
    required this.eventTitle,
    required this.count,
  });

  @override
  State<_TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<_TiltCard> with TickerProviderStateMixin {
  static const double _maxAngle = 15 * math.pi / 180;

  late final AnimationController _flip =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
  late final AnimationController _spring =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(seconds: 6));

  /// Inclinação pelo dedo, -1 a 1 em cada eixo.
  Offset _touch = Offset.zero;
  Offset _released = Offset.zero;
  bool _touching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.of(context).disableAnimations && !_idle.isAnimating) _idle.repeat();
  }

  @override
  void dispose() {
    _flip.dispose();
    _spring.dispose();
    _idle.dispose();
    super.dispose();
  }

  void _follow(Offset local, Size size) {
    _spring.stop();
    setState(() {
      _touching = true;
      _touch = Offset(
        ((local.dx / size.width) * 2 - 1).clamp(-1.0, 1.0),
        ((local.dy / size.height) * 2 - 1).clamp(-1.0, 1.0),
      );
    });
  }

  void _release() {
    if (!_touching) return;
    _touching = false;
    _released = _touch;
    _spring.forward(from: 0);
  }

  void _toggleFlip() {
    HapticFeedback.lightImpact();
    _flip.isCompleted || _flip.velocity > 0 ? _flip.reverse() : _flip.forward();
  }

  Offset get _tilt {
    if (_touching) return _touch;
    final back = Offset.lerp(_released, Offset.zero, Curves.elasticOut.transform(_spring.value))!;
    final t = _idle.value * math.pi * 2;
    return back + Offset(math.sin(t) * 0.18, math.cos(t) * 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.of(context).size.width * 0.66, AppSizes.s300);
    final size = Size(width, width * 4 / 3);
    final heroTag = 'sticker_${widget.sticker.id}';

    return Listener(
      onPointerDown: (e) => _follow(e.localPosition, size),
      onPointerMove: (e) => _follow(e.localPosition, size),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: GestureDetector(
        onTap: _toggleFlip,
        child: AnimatedBuilder(
          animation: Listenable.merge([_flip, _spring, _idle]),
          builder: (context, _) {
            final tilt = _tilt;
            final flip = Curves.easeInOutCubic.transform(_flip.value) * math.pi;
            final showBack = flip > math.pi / 2;
            final face = showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: _StickerBack(
                      sticker: widget.sticker,
                      accent: widget.accent,
                      crestUrl: widget.crestUrl,
                      eventTitle: widget.eventTitle,
                      count: widget.count,
                      sheen: tilt.dx,
                    ),
                  )
                : StickerCard(sticker: widget.sticker, style: widget.style, heroTag: heroTag, sheen: tilt.dx);

            return SizedBox.fromSize(
              size: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Sombra no "chão", deslocada para o lado oposto da inclinação.
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(-tilt.dx * AppSizes.s16, AppSizes.s20 - tilt.dy * AppSizes.s8),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.s16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.55),
                              blurRadius: AppSizes.s40,
                              spreadRadius: -AppSizes.s10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateX(-tilt.dy * _maxAngle)
                        ..rotateY(tilt.dx * _maxAngle + flip),
                      child: face,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Verso da figurinha (estilo Panini): papel branco, cor do time com textura,
/// escudo, número grande, nome, tipo, o álbum e quantas a conta tem.
class _StickerBack extends StatelessWidget {
  final StickerDTO sticker;
  final Color accent;
  final String crestUrl;
  final String eventTitle;
  final int count;
  final double sheen;

  const _StickerBack({
    required this.sticker,
    required this.accent,
    required this.crestUrl,
    required this.eventTitle,
    required this.count,
    required this.sheen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crest = sticker.kind == StickerKind.crest;
    return Container(
      padding: const EdgeInsets.all(AppSizes.s4),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.s10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.s6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, darken(accent, 0.3)],
                ),
              ),
            ),
            CustomPaint(painter: StripesPainter(color: AppColors.white.withValues(alpha: 0.06), diagonal: true)),
            Padding(
              padding: const EdgeInsets.all(AppSizes.s16),
              child: Column(
                children: [
                  Text(
                    eventTitle.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.whiteSoft)
                        .copyWith(fontSize: AppSizes.s10, letterSpacing: 1.2),
                  ),
                  const Spacer(),
                  TeamCrest(imageUrl: crestUrl, size: AppSizes.s56),
                  const SizedBox(height: AppSizes.s8),
                  Text(
                    '${sticker.number}',
                    style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s56, height: 1),
                  ),
                  const SizedBox(height: AppSizes.s4),
                  Text(
                    sticker.name.toUpperCase(),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.white)
                        .copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                  ),
                  Text(
                    crest ? l10n.albumDetailCrest : l10n.albumDetailAthlete,
                    style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s4),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppSizes.s20),
                    ),
                    child: Text(
                      l10n.albumDetailYouHave(count),
                      style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                    ),
                  ),
                ],
              ),
            ),
            // Reflexo guiado pela inclinação, como na frente.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1.6 + sheen * 1.6, -1),
                    end: Alignment(0.4 + sheen * 1.6, 1),
                    colors: [AppColors.transparent, AppColors.white.withValues(alpha: 0.2), AppColors.transparent],
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

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  final Color color;

  const _Dots({required this.count, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    if (count < 2) return const SizedBox(height: AppSizes.s16);
    // Muitas coladas: só uma janela de 9 pontos em volta da atual.
    final start = (index - 4).clamp(0, math.max(0, count - 9));
    final end = math.min(count, start + 9);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = start; i < end; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: AppSizes.s2),
              width: i == index ? AppSizes.s20 : AppSizes.s6,
              height: AppSizes.s6,
              decoration: BoxDecoration(
                color: i == index ? AppColors.white : AppColors.whiteMuted,
                borderRadius: BorderRadius.circular(AppSizes.s4),
              ),
            ),
        ],
      ),
    );
  }
}

/// Painel claro embaixo: nome, time com o escudo, chips (número, tipo,
/// repetidas, página) e as ações. Sobe com fade ao abrir.
class _InfoPanel extends StatelessWidget {
  final StickerDTO sticker;
  final StickerStyle style;
  final Color accent;
  final String crestUrl;
  final String eventTitle;
  final int count;
  final int page;
  final int pages;

  const _InfoPanel({
    required this.sticker,
    required this.style,
    required this.accent,
    required this.crestUrl,
    required this.eventTitle,
    required this.count,
    required this.page,
    required this.pages,
  });

  void _share(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showShareImageSheet(
      context,
      title: l10n.albumDetailShare,
      fileName: 'figurinha_${sticker.number}',
      shareText: stickerShareText(l10n, sticker, eventTitle),
      preview: _SharePreview(sticker: sticker, style: style, eventTitle: eventTitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crest = sticker.kind == StickerKind.crest;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * AppSizes.s40), child: child),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(AppSizes.s12, 0, AppSizes.s12, AppSizes.s12),
        padding: const EdgeInsets.all(AppSizes.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: ValueKey(sticker.id),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TeamCrest(imageUrl: crestUrl, size: AppSizes.s44),
                  const SizedBox(width: AppSizes.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sticker.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
                        ),
                        Text(sticker.team, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.subtitle()),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.s12),
              Wrap(
                spacing: AppSizes.s8,
                runSpacing: AppSizes.s8,
                children: [
                  _Chip(icon: Icons.tag_rounded, label: '${sticker.number}', color: accent),
                  _Chip(
                    icon: crest ? Icons.shield_rounded : Icons.person_rounded,
                    label: crest ? l10n.albumDetailCrest : l10n.albumDetailAthlete,
                    color: accent,
                  ),
                  if (count > 1)
                    _Chip(icon: Icons.copy_rounded, label: l10n.albumDuplicates(count - 1), color: AppColors.warning),
                  _Chip(icon: Icons.menu_book_rounded, label: l10n.albumDetailPage(page, pages), color: accent),
                ],
              ),
              const SizedBox(height: AppSizes.s16),
              Row(
                children: [
                  if (sticker.playerId.isNotEmpty) ...[
                    Expanded(
                      child: ArenaButton.outlined(
                        title: l10n.albumDetailSeeAthlete,
                        function: () => openAthlete(context, {'playerId': sticker.playerId, 'name': sticker.name}),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s12),
                  ],
                  Expanded(
                    child: ArenaButton.primary(title: l10n.albumDetailShare, function: () => _share(context)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s14, color: darken(color, 0.1)),
          const SizedBox(width: AppSizes.s4),
          Text(
            label,
            style: AppTypography.label(color: darken(color, 0.15)).copyWith(fontSize: AppSizes.s12),
          ),
        ],
      ),
    );
  }
}

/// Imagem compartilhada: a figurinha sobre o fundo do time, com o álbum.
class _SharePreview extends StatelessWidget {
  final StickerDTO sticker;
  final StickerStyle style;
  final String eventTitle;

  const _SharePreview({required this.sticker, required this.style, required this.eventTitle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = style.accent;
    return Container(
      padding: const EdgeInsets.all(AppSizes.s24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [darken(accent, 0.05), darken(accent, 0.35)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eventTitle.toUpperCase(),
            style: AppTypography.label(color: AppColors.whiteSoft).copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: AppSizes.s16),
          SizedBox(width: AppSizes.s200, child: StickerCard(sticker: sticker, style: style, sheen: 0)),
          const SizedBox(height: AppSizes.s16),
          Text(sticker.name, style: AppTypography.title(color: AppColors.white)),
          Text(
            l10n.albumStickerCaption(sticker.number, sticker.team),
            style: AppTypography.subtitle(color: AppColors.whiteSoft),
          ),
        ],
      ),
    );
  }
}
