import 'package:flutter/material.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Status da partida na coluna da esquerda: ao vivo (pílula vermelha com o
/// ponto pulsando e o minuto), intervalo, encerrado, adiado ou o horário.
class MatchStatusBadge extends StatelessWidget {
  final GlobalMatch match;

  const MatchStatusBadge({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final small = AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12);

    switch (match.status) {
      case MatchStatus.live:
        return _Pill(
          color: AppColors.danger,
          leading: const _PulsingDot(),
          label: match.minute.isNotEmpty ? "${match.minute}'" : l10n.globalResultsLive,
        );
      case MatchStatus.halfTime:
        return _Pill(color: AppColors.warning, label: l10n.globalResultsHalfTime);
      case MatchStatus.postponed:
        return _Pill(color: AppColors.textSecondary, label: l10n.globalResultsPostponed);
      case MatchStatus.finished:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.globalResultsFinished, style: small),
            if (match.kickoff.isNotEmpty)
              Text(match.kickoff, style: small.copyWith(fontWeight: FontWeight.w400)),
          ],
        );
      case MatchStatus.scheduled:
        return Text(
          match.kickoff.isNotEmpty ? match.kickoff : '—',
          style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
        );
    }
  }
}

class _Pill extends StatelessWidget {
  final Color color;
  final String label;
  final Widget? leading;

  const _Pill({required this.color, required this.label, this.leading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppSizes.s10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: AppSizes.s4)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ponto vermelho que pulsa (jogo em andamento).
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.25,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: AppSizes.s8,
        height: AppSizes.s8,
        decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
      ),
    );
  }
}
