import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cartão da troca de repetidas (aba Repetidas): quantas por pacotinho,
/// quantas trocas sobram hoje e o "Escolher para trocar".
class AlbumTradeCard extends StatelessWidget {
  /// Repetidas diferentes por pacotinho.
  final int size;

  /// Repetidas diferentes que a conta tem.
  final int distinctDuplicates;

  /// Trocas que sobram hoje.
  final int tradesLeft;
  final bool opening;
  final VoidCallback onStart;

  const AlbumTradeCard({
    super.key,
    required this.size,
    required this.distinctDuplicates,
    required this.tradesLeft,
    required this.opening,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enough = distinctDuplicates >= size;
    final status = tradesLeft <= 0
        ? l10n.albumTradeNoneLeft
        : enough
            ? l10n.albumTradeLeft(tradesLeft)
            : l10n.albumTradeNeedMore(distinctDuplicates, size);
    return Container(
      key: const ValueKey('album-trade-card'),
      padding: const EdgeInsets.all(AppSizes.s14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryMedium]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, color: AppColors.gold, size: AppSizes.s28),
              const SizedBox(width: AppSizes.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.albumTradeText(size), style: AppTypography.label(color: AppColors.white)),
                    const SizedBox(height: AppSizes.s2),
                    Text(
                      status,
                      key: const ValueKey('album-trade-status'),
                      style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s10),
          FilledButton.icon(
            key: const ValueKey('album-trade-start'),
            onPressed: enough && tradesLeft > 0 && !opening ? onStart : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.primaryDark,
              disabledBackgroundColor: AppColors.white.withValues(alpha: 0.2),
              disabledForegroundColor: AppColors.whiteSoft,
            ),
            icon: const Icon(Icons.touch_app_rounded, size: AppSizes.s18),
            label: Text(l10n.albumTradeChoose),
          ),
        ],
      ),
    );
  }
}

/// Barra do modo de seleção da troca: "K de N", automático, cancelar e trocar.
class AlbumTradeBar extends StatelessWidget {
  final int selected;
  final int size;
  final bool opening;
  final VoidCallback onCancel;
  final VoidCallback onAuto;
  final VoidCallback onTrade;

  const AlbumTradeBar({
    super.key,
    required this.selected,
    required this.size,
    required this.opening,
    required this.onCancel,
    required this.onAuto,
    required this.onTrade,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Material(
        color: AppColors.primaryDark,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s8, AppSizes.s8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.albumTradeSelected(selected, size),
                      key: const ValueKey('album-trade-count'),
                      style: AppTypography.label(color: AppColors.white),
                    ),
                    GestureDetector(
                      key: const ValueKey('album-trade-auto'),
                      onTap: opening ? null : onAuto,
                      child: Text(
                        l10n.albumTradeAuto,
                        style: AppTypography.label(color: AppColors.gold).copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                key: const ValueKey('album-trade-cancel'),
                onPressed: opening ? null : onCancel,
                style: TextButton.styleFrom(foregroundColor: AppColors.white),
                child: Text(l10n.commonCancel),
              ),
              const SizedBox(width: AppSizes.s4),
              FilledButton.icon(
                key: const ValueKey('album-trade-confirm'),
                onPressed: selected == size && !opening ? onTrade : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.primaryDark,
                ),
                icon: const Icon(Icons.swap_horiz_rounded, size: AppSizes.s18),
                label: Text(l10n.albumTradeAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figurinha da aba Repetidas no modo de seleção: toque marca/desmarca;
/// marcada = borda dourada e o selo "−1".
class AlbumTradeSelectable extends StatelessWidget {
  final String stickerId;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const AlbumTradeSelectable({
    super.key,
    required this.stickerId,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('album-trade-pick-$stickerId'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: selected ? 1 : 0.55,
            child: child,
          ),
          if (selected)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.s8),
                    border: Border.all(color: AppColors.gold, width: 3),
                  ),
                ),
              ),
            ),
          if (selected)
            Positioned(
              left: -AppSizes.s4,
              top: -AppSizes.s6,
              child: Container(
                key: ValueKey('album-trade-mark-$stickerId'),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s2),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
                child: Text(
                  '−1',
                  style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
