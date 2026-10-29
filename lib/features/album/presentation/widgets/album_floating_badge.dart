import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_event_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Selo flutuante do álbum de figurinhas na home (só com o evento ativo e a
/// conta logada). Arrastável; "pulsa" com o aviso "1 pacote!" quando o pacote
/// de hoje está disponível. O toque abre o álbum.
class AlbumFloatingBadge extends StatefulWidget {
  const AlbumFloatingBadge({super.key});

  @override
  State<AlbumFloatingBadge> createState() => _AlbumFloatingBadgeState();
}

class _AlbumFloatingBadgeState extends State<AlbumFloatingBadge> with SingleTickerProviderStateMixin {
  static const double _size = AppSizes.s60;

  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat(reverse: true);

  /// Posição (canto superior esquerdo do selo) dentro da área da home; nula =
  /// a posição inicial, embaixo à esquerda.
  Offset? _position;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AlbumEventCubit, AlbumEventState>(
      builder: (context, state) {
        if (!state.visible) return const SizedBox.shrink();
        return LayoutBuilder(
          builder: (context, constraints) {
            final max = Offset(constraints.maxWidth - _size, constraints.maxHeight - _size - AppSizes.s24);
            final position = _position ?? Offset(AppSizes.s16, max.dy - AppSizes.s16);
            Offset clamp(Offset o) => Offset(o.dx.clamp(0, max.dx), o.dy.clamp(0, max.dy));

            return Stack(
              children: [
                Positioned(
                  left: clamp(position).dx,
                  top: clamp(position).dy,
                  child: GestureDetector(
                    onPanUpdate: (details) => setState(() => _position = clamp(position + details.delta)),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.albumPage),
                    child: Semantics(
                      button: true,
                      label: l10n.albumTitle,
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, child) => Transform.scale(
                          scale: state.packAvailable ? 1 + _pulse.value * 0.08 : 1,
                          child: child,
                        ),
                        child: _Badge(packAvailable: state.packAvailable, label: l10n.albumPackBadge),
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

class _Badge extends StatelessWidget {
  final bool packAvailable;
  final String label;

  const _Badge({required this.packAvailable, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _AlbumFloatingBadgeState._size,
      height: _AlbumFloatingBadgeState._size + AppSizes.s10,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: _AlbumFloatingBadgeState._size,
            height: _AlbumFloatingBadgeState._size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.googleYellow, AppColors.teamOrange],
              ),
              border: Border.all(color: AppColors.white, width: AppSizes.s2),
              boxShadow: [
                BoxShadow(color: AppColors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.collections_bookmark_rounded, color: AppColors.primaryDark, size: AppSizes.s30),
          ),
          if (packAvailable)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s2),
                decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppSizes.s10)),
                child: Text(
                  label,
                  style: AppTypography.label(color: AppColors.white)
                      .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
