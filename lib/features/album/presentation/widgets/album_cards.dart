import 'dart:async';

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_layout.dart';
import 'package:arena_soccer/features/album/domain/album_pack_id.dart';
import 'package:arena_soccer/features/album/presentation/widgets/album_visuals.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cartão do pacotinho do dia: o pacote dourado inclinado com brilho e o
/// botão; já aberto, o pacote apagado e a contagem para o próximo.
class PackCard extends StatefulWidget {
  final bool available;
  final bool opening;
  final VoidCallback onOpen;

  /// Toque longo no cartão (a prévia da abertura, só o admin).
  final VoidCallback? onLongPress;

  /// Quando libera o próximo pacote (contagem); nulo = liberado.
  final DateTime? nextPackAt;

  const PackCard({
    super.key,
    required this.available,
    required this.opening,
    required this.onOpen,
    this.onLongPress,
    this.nextPackAt,
  });

  @override
  State<PackCard> createState() => _PackCardState();
}

class _PackCardState extends State<PackCard> {
  Timer? _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (mounted) setState(() => _left = AlbumPackId.leftUntil(widget.nextPackAt, DateTime.now()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static String _clock(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = widget.available;

    Widget pack = Transform.rotate(
      angle: -0.12,
      child: Container(
        width: AppSizes.s64,
        height: AppSizes.s80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: available
                ? const [AppColors.googleYellow, AppColors.teamOrange]
                : [AppColors.grey, AppColors.blueGreyLight],
          ),
          borderRadius: BorderRadius.circular(AppSizes.s10),
          border: Border.all(color: AppColors.white, width: AppSizes.s2),
          boxShadow: [
            if (available) BoxShadow(color: AppColors.googleYellow.withValues(alpha: 0.6), blurRadius: 18),
          ],
        ),
        child: Center(child: Image.asset('lib/assets/images/ic_logo.png', width: AppSizes.s40)),
      ),
    );
    if (available) pack = Shimmer(child: pack);

    final card = Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          pack,
          const SizedBox(width: AppSizes.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  available ? l10n.albumPackReady : l10n.albumPackDone,
                  style: AppTypography.title().copyWith(fontSize: AppSizes.s16),
                ),
                const SizedBox(height: AppSizes.s4),
                Text(
                  available ? l10n.albumPackReadyHint : l10n.albumNextPackIn(_clock(_left)),
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                if (available || widget.opening) ...[
                  const SizedBox(height: AppSizes.s10),
                  SizedBox(
                    height: AppSizes.s40,
                    child: FilledButton.icon(
                      onPressed: widget.opening ? null : widget.onOpen,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: AppColors.white,
                        shape: const StadiumBorder(),
                      ),
                      icon: widget.opening
                          ? const SizedBox.square(
                              dimension: AppSizes.s16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                            )
                          : const Icon(Icons.card_giftcard_rounded, size: AppSizes.s18),
                      label: Text(widget.opening ? l10n.albumPackOpeningShort : l10n.albumOpenPack),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
    return widget.onLongPress == null ? card : GestureDetector(onLongPress: widget.onLongPress, child: card);
  }
}

/// Cartão do índice: o escudo dentro do anel de progresso na cor do time, o
/// nome e "7/12"; página completa ganha o selo dourado e a borda brilhante.
class TeamIndexCard extends StatelessWidget {
  final AlbumTeamPage page;
  final UserAlbumDTO album;
  final String crestUrl;
  final Color accent;
  final VoidCallback onTap;

  const TeamIndexCard({
    super.key,
    required this.page,
    required this.album,
    required this.crestUrl,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final collected = page.collected(album);
    final total = page.stickers.length;
    final complete = page.isComplete(album);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.s16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s12, AppSizes.s8, AppSizes.s10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.s16),
            border: Border.all(
              color: complete ? AppColors.googleYellow : AppColors.greyLight,
              width: complete ? AppSizes.s2 : AppSizes.s1,
            ),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AlbumProgressRing(
                    value: total == 0 ? 0 : collected / total,
                    size: AppSizes.s64,
                    stroke: AppSizes.s4,
                    color: complete ? AppColors.googleYellow : accent,
                    track: AppColors.greyLight,
                    child: TeamCrest(imageUrl: crestUrl, size: AppSizes.s40),
                  ),
                  if (complete)
                    const Positioned(
                      right: -AppSizes.s4,
                      bottom: -AppSizes.s2,
                      child: CircleAvatar(
                        radius: AppSizes.s10,
                        backgroundColor: AppColors.googleYellow,
                        child: Icon(Icons.check_rounded, size: AppSizes.s14, color: AppColors.black),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.s8),
              Text(
                page.team,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
              ),
              Text(
                '$collected/$total',
                style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
