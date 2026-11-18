import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Campinho da escalação: gramado com as linhas e as 5 vagas (ATA no alto,
/// MEI e LIVRE lado a lado, ZAG e GOL embaixo). Vaga vazia = "+"; preenchida =
/// foto, nome e time, com a braçadeira "C" (toque escolhe o capitão).
class FantasyPitch extends StatelessWidget {
  final FantasyLineup lineup;
  final Map<String, FantasyAthleteDTO> athletes;
  final bool editable;
  final ValueChanged<FantasySlot> onSlotTap;
  final ValueChanged<String> onCaptainTap;

  const FantasyPitch({
    super.key,
    required this.lineup,
    required this.athletes,
    required this.editable,
    required this.onSlotTap,
    required this.onCaptainTap,
  });

  static const Map<FantasySlot, Alignment> _positions = {
    FantasySlot.forward: Alignment(0, -0.82),
    FantasySlot.midfielder: Alignment(-0.55, -0.2),
    FantasySlot.flex: Alignment(0.55, -0.2),
    FantasySlot.defender: Alignment(0, 0.4),
    FantasySlot.goalkeeper: Alignment(0, 0.92),
  };

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.78,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primaryMedium, AppColors.primaryDark],
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: CustomPaint(painter: _PitchPainter())),
            for (final slot in FantasySlot.values)
              Align(
                alignment: _positions[slot]!,
                child: _PitchSlot(
                  slot: slot,
                  athlete: athletes[lineup.idAt(slot) ?? ''],
                  athleteId: lineup.idAt(slot),
                  captain: lineup.idAt(slot) != null && lineup.idAt(slot) == lineup.captainId,
                  editable: editable,
                  onTap: () => onSlotTap(slot),
                  onCaptainTap: onCaptainTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PitchSlot extends StatelessWidget {
  final FantasySlot slot;
  final FantasyAthleteDTO? athlete;
  final String? athleteId;
  final bool captain;
  final bool editable;
  final VoidCallback onTap;
  final ValueChanged<String> onCaptainTap;

  const _PitchSlot({
    required this.slot,
    required this.athlete,
    required this.athleteId,
    required this.captain,
    required this.editable,
    required this.onTap,
    required this.onCaptainTap,
  });

  static const double _size = AppSizes.s56;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filled = athleteId != null;
    final photo = athlete?.photoUrl ?? '';
    final name = athlete?.name.trim().split(RegExp(r'\s+')).last ?? '';
    return SizedBox(
      width: AppSizes.s100,
      child: GestureDetector(
        key: ValueKey('fantasy-slot-${slot.key}'),
        onTap: editable || filled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.surface : AppColors.whiteMuted,
                    border: Border.all(
                      color: captain ? AppColors.gold : AppColors.white,
                      width: captain ? AppSizes.s4 : AppSizes.s2,
                    ),
                    boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s6)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: !filled
                      ? Icon(editable ? Icons.add_rounded : Icons.person_outline_rounded, color: AppColors.white)
                      : photo.isEmpty
                          ? const Icon(Icons.person_rounded, color: AppColors.textSecondary, size: AppSizes.s32)
                          : CachedNetworkImage(
                              imageUrl: photo,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.person_rounded, color: AppColors.textSecondary),
                            ),
                ),
                if (filled)
                  Positioned(
                    right: -AppSizes.s4,
                    top: -AppSizes.s4,
                    child: GestureDetector(
                      key: ValueKey('fantasy-captain-${slot.key}'),
                      onTap: editable ? () => onCaptainTap(athleteId!) : null,
                      child: Container(
                        width: AppSizes.s24,
                        height: AppSizes.s24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: captain ? AppColors.gold : AppColors.primaryDark.withValues(alpha: 0.85),
                          border: Border.all(color: AppColors.white, width: 1.5),
                        ),
                        child: Text(
                          l10n.fantasyCaptainShort,
                          style: AppTypography.label(color: captain ? AppColors.primaryDark : AppColors.whiteSoft)
                              .copyWith(fontSize: AppSizes.s12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.s4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s2),
              decoration: BoxDecoration(
                color: slot == FantasySlot.flex ? AppColors.gold : AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.s4),
              ),
              child: Text(
                fantasySlotLabel(l10n, slot),
                style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s10),
              ),
            ),
            if (filled) ...[
              const SizedBox(height: AppSizes.s2),
              Text(
                name.isEmpty ? '—' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
              ),
              if ((athlete?.team ?? '').isNotEmpty)
                Text(
                  athlete!.team,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s10),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Linhas do campo: contorno, meio-campo, círculo central e as áreas.
class _PitchPainter extends CustomPainter {
  const _PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stripe = Paint()..color = AppColors.white.withValues(alpha: 0.04);
    const stripes = 8;
    for (var i = 0; i < stripes; i += 2) {
      canvas.drawRect(Rect.fromLTWH(0, size.height * i / stripes, size.width, size.height / stripes), stripe);
    }
    final line = Paint()
      ..color = AppColors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const m = 10.0;
    final field = Rect.fromLTWH(m, m, size.width - 2 * m, size.height - 2 * m);
    canvas.drawRect(field, line);
    canvas.drawLine(Offset(field.left, field.center.dy), Offset(field.right, field.center.dy), line);
    canvas.drawCircle(field.center, size.width * 0.14, line);
    final areaWidth = field.width * 0.56;
    final areaHeight = field.height * 0.14;
    canvas.drawRect(Rect.fromLTWH(field.center.dx - areaWidth / 2, field.top, areaWidth, areaHeight), line);
    canvas.drawRect(
      Rect.fromLTWH(field.center.dx - areaWidth / 2, field.bottom - areaHeight, areaWidth, areaHeight),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
