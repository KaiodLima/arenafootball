import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_info_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/date_time_chips.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Editar partida" (engrenagem do card/detalhe): data, horário, duração e
/// local, com os times no topo (só leitura). Devolve os dados ao salvar
/// (nulo = fechou sem salvar).
Future<MatchInfoEdit?> showEditMatchInfoSheet(
  BuildContext context, {
  required MatchDTO match,
  String? homeCrest,
  String? awayCrest,
}) =>
    showModalBottomSheet<MatchInfoEdit>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _EditMatchInfoSheet(match: match, homeCrest: homeCrest, awayCrest: awayCrest),
    );

class _EditMatchInfoSheet extends StatefulWidget {
  final MatchDTO match;
  final String? homeCrest;
  final String? awayCrest;

  const _EditMatchInfoSheet({required this.match, this.homeCrest, this.awayCrest});

  @override
  State<_EditMatchInfoSheet> createState() => _EditMatchInfoSheetState();
}

class _EditMatchInfoSheetState extends State<_EditMatchInfoSheet> {
  static const _frequentTimes = ['15:00', '16:00', '19:00', '20:00', '21:00'];

  late String _date = widget.match.date;
  late String _time = widget.match.time;
  late int _duration = widget.match.durationMinutes;
  late final _venue = TextEditingController(text: widget.match.venue);

  /// A data mantém o formato da partida: com ano se ela tinha ano.
  String _format(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    final withYear = widget.match.date.split('/').length > 2;
    return withYear ? '${two(date.day)}/${two(date.month)}/${date.year}' : '${two(date.day)}/${two(date.month)}';
  }

  @override
  void dispose() {
    _venue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final match = widget.match;
    Widget team(String name, String? crest) => Expanded(
          child: Column(
            children: [
              TeamCrest(imageUrl: crest, size: AppSizes.s36),
              const SizedBox(height: AppSizes.s4),
              Text(
                name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
              ),
            ],
          ),
        );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.matchEditInfoTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s20)),
            const SizedBox(height: AppSizes.s2),
            Text(l10n.matchEditInfoSubtitle, style: AppTypography.subtitle()),
            const SizedBox(height: AppSizes.s16),
            Row(
              children: [
                team(match.homeTeam, widget.homeCrest),
                Text('×', style: AppTypography.title(color: AppColors.textSecondary)),
                team(match.awayTeam, widget.awayCrest),
              ],
            ),
            const SizedBox(height: AppSizes.s16),
            Text(l10n.reportWhen, style: AppTypography.label(color: AppColors.textPrimary)),
            const SizedBox(height: AppSizes.s8),
            MatchDateChips(selected: _date, onSelected: (date) => setState(() => _date = _format(date))),
            const SizedBox(height: AppSizes.s12),
            MatchTimeChips(
              frequent: _frequentTimes,
              selected: _time,
              onSelected: (time) => setState(() => _time = time),
            ),
            const SizedBox(height: AppSizes.s12),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: AppSizes.s20),
                const SizedBox(width: AppSizes.s8),
                Expanded(
                    child: Text(l10n.matchReportDuration, style: AppTypography.label(color: AppColors.textPrimary))),
                IconButton.filledTonal(
                  onPressed: _duration > 10 ? () => setState(() => _duration -= 5) : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: AppSizes.s56,
                  child: Text(
                    "$_duration'",
                    textAlign: TextAlign.center,
                    style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _duration += 5),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.s16),
            Text(l10n.reportWhere, style: AppTypography.label(color: AppColors.textPrimary)),
            const SizedBox(height: AppSizes.s8),
            ArenaTextField(controller: _venue, labelText: l10n.matchReportVenue),
            const SizedBox(height: AppSizes.s20),
            ArenaButton.primary(
              title: l10n.playersPhotoSave,
              function: () => Navigator.pop(
                context,
                (date: _date, time: _time, durationMinutes: _duration, venue: _venue.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
