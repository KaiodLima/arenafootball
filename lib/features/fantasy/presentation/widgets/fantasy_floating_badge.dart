import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_badge_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Abre o Fantasy: um só = direto na escalação; vários = a folha para escolher.
Future<void> openFantasyFrom(BuildContext context, List<FantasyConfigDTO> fantasies) async {
  if (fantasies.isEmpty) return;
  final picked = fantasies.length == 1 ? fantasies.single : await _pickFantasy(context, fantasies);
  if (picked == null || !context.mounted) return;
  await Navigator.pushNamed(context, AppRoutes.fantasyLineupPage, arguments: picked.toChampionship());
}

Future<FantasyConfigDTO?> _pickFantasy(BuildContext context, List<FantasyConfigDTO> fantasies) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<FantasyConfigDTO>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: AppSizes.s16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s8),
              child: Text(l10n.fantasyTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s20)),
            ),
            for (final f in fantasies)
              ListTile(
                key: ValueKey('fantasy-pick-${f.championshipDocId}'),
                leading: TeamCrest(imageUrl: f.imageUrl, size: AppSizes.s40),
                title: Text(f.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  f.currentRound > 0 ? l10n.fantasyBadgeRoundOpen(f.currentRound) : l10n.fantasyBadgeNoRound,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context, f),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Selo flutuante do Arena Fantasy na home (conta logada + Fantasy ativo na
/// região): o mini campinho com a braçadeira "C". Com rodada aberta chama
/// atenção (halo dourado, flutua, chacoalha, "Escalar!"); sem, fica discreto.
/// Arrastável como o do álbum (começa embaixo à direita; o do álbum fica à
/// esquerda); ao soltar, gruda na borda. O toque abre o Fantasy.
class FantasyFloatingBadge extends StatefulWidget {
  const FantasyFloatingBadge({super.key});

  @override
  State<FantasyFloatingBadge> createState() => _FantasyFloatingBadgeState();
}

class _FantasyFloatingBadgeState extends State<FantasyFloatingBadge> with TickerProviderStateMixin {
  static const double _width = AppSizes.s72;
  static const double _height = AppSizes.s100;
  static const double _margin = AppSizes.s8;

  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  late final AnimationController _snap = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  Offset? _position;
  bool _dragging = false;
  bool _open = false;
  Timer? _shakeTimer;

  @override
  void initState() {
    super.initState();
    context.read<FantasyBadgeCubit>().follow(SeasonCollection.currentSeason);
    _snap.addListener(() {
      final t = Curves.easeOutBack.transform(_snap.value);
      setState(() => _position = Offset.lerp(_from, _to, t));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = !MediaQuery.of(context).disableAnimations;
    if (animate && !_idle.isAnimating) _idle.repeat(reverse: true);
    _shakeTimer ??= animate
        ? Timer.periodic(const Duration(seconds: 5), (_) {
            if (mounted && _open) _shake.forward(from: 0);
          })
        : null;
  }

  @override
  void dispose() {
    _shakeTimer?.cancel();
    _idle.dispose();
    _shake.dispose();
    _snap.dispose();
    super.dispose();
  }

  void _release(Offset current, Offset max) {
    _dragging = false;
    _from = current;
    _to = Offset(current.dx + _width / 2 < (max.dx + _width) / 2 ? _margin : max.dx - _margin, current.dy);
    _snap.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loggedIn = context.select<SessionCubit, bool>((cubit) => cubit.state.isAuthenticated);
    final region = context.select<RegionCubit, String>((cubit) => cubit.state.selectedRegion);
    return BlocBuilder<FantasyBadgeCubit, FantasyBadgeState>(
      builder: (context, state) {
        final fantasies = state.forRegion(region);
        if (!loggedIn || fantasies.isEmpty) return const SizedBox.shrink();
        final open = fantasies.any((f) => f.currentRound > 0);
        _open = open;
        return LayoutBuilder(
          builder: (context, constraints) {
            final max = Offset(constraints.maxWidth - _width, constraints.maxHeight - _height - AppSizes.s16);
            Offset clamp(Offset o) => Offset(o.dx.clamp(0, max.dx), o.dy.clamp(0, max.dy));
            final position = clamp(_position ?? Offset(max.dx - _margin, max.dy - AppSizes.s16));
            return Stack(
              children: [
                Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: GestureDetector(
                    key: const ValueKey('fantasy-badge'),
                    onPanStart: (_) {
                      _snap.stop();
                      _dragging = true;
                    },
                    onPanUpdate: (details) => setState(() => _position = clamp(position + details.delta)),
                    onPanEnd: (_) => _release(position, max),
                    onTap: () => openFantasyFrom(context, fantasies),
                    child: Semantics(
                      button: true,
                      label: l10n.fantasyTitle,
                      child: SizedBox(
                        width: _width,
                        height: _height,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_idle, _shake]),
                          builder: (context, _) {
                            final idle = open && !_dragging ? _idle.value : 0.0;
                            final shake = open ? math.sin(_shake.value * math.pi * 6) * (1 - _shake.value) * 0.16 : 0.0;
                            return Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topCenter,
                              children: [
                                if (open)
                                  Positioned(
                                    top: AppSizes.s6,
                                    child: Container(
                                      width: AppSizes.s56,
                                      height: AppSizes.s64,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppSizes.s12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.gold.withValues(alpha: 0.35 + idle * 0.3),
                                            blurRadius: AppSizes.s20 + idle * AppSizes.s10,
                                            spreadRadius: AppSizes.s2 + idle * AppSizes.s4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: AppSizes.s4 - idle * AppSizes.s4,
                                  child: Transform.rotate(
                                    angle: 0.12 + shake,
                                    child: AnimatedScale(
                                      scale: open ? 1 : 0.88,
                                      duration: const Duration(milliseconds: 250),
                                      child: const _MiniPitch(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: _Pill(open: open, label: open ? l10n.fantasyBadgePlay : l10n.fantasyBadgeIdle),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Mini campinho: gramado com as linhas, estádio no centro e a braçadeira "C".
class _MiniPitch extends StatelessWidget {
  const _MiniPitch();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.s56,
      height: AppSizes.s72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryStrong],
              ),
              borderRadius: BorderRadius.circular(AppSizes.s8),
              border: Border.all(color: AppColors.white, width: AppSizes.s2),
              boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.25), blurRadius: AppSizes.s6)],
            ),
            child: const CustomPaint(painter: _MiniPitchPainter(), child: SizedBox.expand()),
          ),
          const Center(child: Icon(Icons.stadium_rounded, color: AppColors.white, size: AppSizes.s24)),
          Positioned(
            right: -AppSizes.s6,
            top: -AppSizes.s6,
            child: Container(
              width: AppSizes.s22,
              height: AppSizes.s22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: AppSizes.s2),
              ),
              child: Text(
                AppLocalizations.of(context).fantasyCaptainShort,
                style: AppTypography.label(color: AppColors.primaryDark)
                    .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPitchPainter extends CustomPainter {
  const _MiniPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final mid = size.height / 2;
    canvas.drawLine(Offset(AppSizes.s4, mid), Offset(size.width - AppSizes.s4, mid), line);
    canvas.drawCircle(Offset(size.width / 2, mid), size.width * 0.22, line);
    final areaWidth = size.width * 0.5;
    final areaHeight = size.height * 0.14;
    canvas.drawRect(Rect.fromLTWH((size.width - areaWidth) / 2, AppSizes.s4, areaWidth, areaHeight), line);
    canvas.drawRect(
      Rect.fromLTWH((size.width - areaWidth) / 2, size.height - AppSizes.s4 - areaHeight, areaWidth, areaHeight),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pílula embaixo: "Escalar!" (branca) ou "Fantasy" (escura).
class _Pill extends StatelessWidget {
  final bool open;
  final String label;

  const _Pill({required this.open, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = open ? AppColors.primaryDark : AppColors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(
        color: open ? AppColors.white : AppColors.primaryDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSizes.s10),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.2), blurRadius: AppSizes.s4)],
      ),
      child: Text(
        label,
        style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900),
      ),
    );
  }
}
