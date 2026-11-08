import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/themes/arena_palette.dart';

/// Estado vazio/erro das listas: ícone + mensagem centralizados.
class ArenaEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const ArenaEmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined});

  /// Variante de erro de carregamento.
  const ArenaEmptyState.error({super.key, required this.message}) : icon = Icons.cloud_off_rounded;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.s64,
              height: AppSizes.s64,
              decoration: BoxDecoration(color: ArenaPalette.of(context).primarySoft, shape: BoxShape.circle),
              child: Icon(icon, color: ArenaPalette.of(context).primaryDark, size: AppSizes.s30),
            ),
            const SizedBox(height: AppSizes.s16),
            Text(message, textAlign: TextAlign.center, style: AppTypography.subtitle()),
          ],
        ),
      ),
    );
  }
}
