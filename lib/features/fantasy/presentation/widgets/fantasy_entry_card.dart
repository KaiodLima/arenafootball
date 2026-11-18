import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card "Arena Fantasy" na Visão geral do campeonato: só com o Fantasy ativo
/// (lê o doc de configuração; cache do Firestore). Abre "Montar meu time".
class FantasyEntryCard extends StatefulWidget {
  final ChampionshipDTO championship;

  const FantasyEntryCard({super.key, required this.championship});

  @override
  State<FantasyEntryCard> createState() => _FantasyEntryCardState();
}

class _FantasyEntryCardState extends State<FantasyEntryCard> {
  late final Stream<Either<Failure, FantasyConfigDTO>>? _config =
      sl.isRegistered<WatchFantasyConfigUseCase>() ? sl<WatchFantasyConfigUseCase>()(widget.championship) : null;

  @override
  Widget build(BuildContext context) {
    final stream = _config;
    if (stream == null || widget.championship.id.isEmpty) return const SizedBox.shrink();
    return StreamBuilder<Either<Failure, FantasyConfigDTO>>(
      stream: stream,
      builder: (context, snapshot) {
        final config = snapshot.data?.fold((_) => null, (c) => c);
        if (config == null || !config.active) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.only(top: AppSizes.s16),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              key: const ValueKey('fantasy-entry'),
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              onTap: () => Navigator.pushNamed(context, AppRoutes.fantasyLineupPage, arguments: widget.championship),
              child: Ink(
                padding: const EdgeInsets.all(AppSizes.s16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryStrong]),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stadium_rounded, color: AppColors.gold, size: AppSizes.s36),
                    const SizedBox(width: AppSizes.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.fantasyTitle,
                            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                          ),
                          const SizedBox(height: AppSizes.s2),
                          Text(
                            config.currentRound > 0
                                ? l10n.fantasyEntryRound(config.currentRound)
                                : l10n.fantasyEntrySubtitle,
                            style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      l10n.fantasyEntryAction,
                      style: AppTypography.label(color: AppColors.gold).copyWith(fontSize: AppSizes.s14),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
