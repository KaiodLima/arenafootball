import 'package:flutter/material.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Sobre a competição: descrição, premiação, regras e atalho para os grupos.
/// O campeonato já vem carregado da aba (stream), sem nova leitura.
class ChampionshipDetailsPage extends StatelessWidget {
  final ChampionshipDTO championship;

  const ChampionshipDetailsPage({super.key, required this.championship});

  void _openGroups(BuildContext context) {
    // Como no app antigo: os grupos são os da temporada do campeonato (`ano`).
    final season = championship.season.isNotEmpty ? championship.season : SeasonCollection.currentSeason;
    Navigator.pushNamed(
      context,
      AppRoutes.groupsPage,
      arguments: {'region': championship.region, 'season': season},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const bodyStyle = TextStyle(fontSize: AppSizes.s14, fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.championshipsDetailsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.s12),
                child: Text(
                  championship.title,
                  style: const TextStyle(fontSize: AppSizes.s16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.s8),
              child: Text(championship.description, style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.s8),
              child: Text(
                l10n.championshipsPrizes(
                  championship.firstPrize,
                  championship.secondPrize,
                  championship.thirdPrize,
                  championship.topScorerPrize,
                  championship.goalkeeperPrize,
                ),
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.s8),
              child: Text(
                l10n.championshipsRules(championship.rules),
                style: bodyStyle,
                textAlign: TextAlign.justify,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.s8),
              child: ArenaButton.primary(
                title: l10n.championshipsGroupsButton,
                function: () => _openGroups(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
