import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

String playerPositionLabel(AppLocalizations l10n, PlayerPosition position) => switch (position) {
      PlayerPosition.goalkeeper => l10n.playerPositionGoalkeeper,
      PlayerPosition.defender => l10n.playerPositionDefender,
      PlayerPosition.fullBack => l10n.playerPositionFullBack,
      PlayerPosition.midfielder => l10n.playerPositionMidfielder,
      PlayerPosition.forward => l10n.playerPositionForward,
    };

/// "12/10/2026 às 14:30" no idioma do app; vazio sem data.
String playerRequestDate(BuildContext context, DateTime? date) {
  if (date == null) return '';
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).add_Hm().format(date);
}

/// Selo colorido com a situação do pedido.
class PlayerRequestStatusBadge extends StatelessWidget {
  final PlayerRequestStatus status;

  const PlayerRequestStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color, icon) = switch (status) {
      PlayerRequestStatus.pending => (l10n.playerRequestStatusPending, AppColors.warning, Icons.schedule_rounded),
      PlayerRequestStatus.approved => (l10n.playerRequestStatusApproved, AppColors.primary, Icons.check_circle_rounded),
      PlayerRequestStatus.rejected => (l10n.playerRequestStatusRejected, AppColors.danger, Icons.cancel_rounded),
      PlayerRequestStatus.removed => (l10n.playerRequestStatusRemoved, AppColors.textSecondary, Icons.logout_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s14, color: color),
          const SizedBox(width: AppSizes.s4),
          Text(label, style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
