import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Imagem que vai para as redes: logo do Arena, a data, a carteirinha e o
/// rodapé com o nome do app (como o card de dica do Relove). Largura fixa
/// para o "print" sair sempre igual, independente da tela.
class FanCardShareImage extends StatelessWidget {
  static const double width = 360;

  final Widget card;
  final DateTime date;

  const FanCardShareImage({super.key, required this.card, required this.date});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s16),
      // Sem cantos arredondados: viram transparência no PNG.
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('lib/assets/images/ic_logo.png', height: AppSizes.s40),
          const SizedBox(height: AppSizes.s4),
          Text(
            DateFormat.yMMMMd(locale).format(date),
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
          const SizedBox(height: AppSizes.s14),
          card,
          const SizedBox(height: AppSizes.s14),
          Text(
            l10n.fanCardShareFooter,
            textAlign: TextAlign.center,
            style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
          ),
        ],
      ),
    );
  }
}
