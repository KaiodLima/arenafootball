import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';

/// Abre o regulamento (PDF) no visualizador do aparelho; avisa se não der.
Future<void> openChampionshipRules(BuildContext context, ChampionshipDTO championship) async {
  final l10n = AppLocalizations.of(context);
  final uri = Uri.tryParse(championship.rulesUrl);
  var opened = false;
  try {
    if (uri != null && championship.rulesUrl.isNotEmpty) {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    AppLogger.e('openChampionshipRules', name: 'ChampionshipRules', error: e);
  }
  if (!opened && context.mounted) {
    showSnackBar(context: context, message: l10n.championshipRulesOpenError, isSuccess: false);
  }
}
