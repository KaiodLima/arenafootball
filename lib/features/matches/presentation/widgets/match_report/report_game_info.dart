import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/date_time_chips.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Aba Jogo da súmula, em grupos com ícone (padrão "Ajustes"): Quando (data,
/// horário e duração com − e +), Onde, Arbitragem, Votação e Observações.
class ReportGameInfo extends StatefulWidget {
  final MatchDTO match;
  final bool busy;
  final void Function({String? date, String? time, int? durationMinutes, String? venue, String? referee, String? notes})
      onChanged;
  final VoidCallback onToggleVoting;

  const ReportGameInfo({
    super.key,
    required this.match,
    required this.busy,
    required this.onChanged,
    required this.onToggleVoting,
  });

  @override
  State<ReportGameInfo> createState() => _ReportGameInfoState();
}

class _ReportGameInfoState extends State<ReportGameInfo> {
  static const _frequentTimes = ['15:00', '16:00', '19:00', '20:00', '21:00'];

  late final _venue = TextEditingController(text: widget.match.venue);
  late final _referee = TextEditingController(text: widget.match.referee);
  late final _notes = TextEditingController(text: widget.match.notes);

  @override
  void dispose() {
    _venue.dispose();
    _referee.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final match = widget.match;
    String two(int n) => n.toString().padLeft(2, '0');
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s120),
      children: [
        _Group(
          icon: Icons.event_rounded,
          title: l10n.reportWhen,
          children: [
            MatchDateChips(
              selected: match.date,
              onSelected: (date) => widget.onChanged(date: '${two(date.day)}/${two(date.month)}'),
            ),
            const SizedBox(height: AppSizes.s12),
            MatchTimeChips(
              frequent: _frequentTimes,
              selected: match.time,
              onSelected: (time) => widget.onChanged(time: time),
            ),
            const SizedBox(height: AppSizes.s12),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: AppSizes.s20),
                const SizedBox(width: AppSizes.s8),
                Expanded(
                    child: Text(l10n.matchReportDuration, style: AppTypography.label(color: AppColors.textPrimary))),
                IconButton.filledTonal(
                  onPressed: match.durationMinutes > 10
                      ? () => widget.onChanged(durationMinutes: match.durationMinutes - 5)
                      : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: AppSizes.s56,
                  child: Text(
                    "${match.durationMinutes}'",
                    textAlign: TextAlign.center,
                    style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => widget.onChanged(durationMinutes: match.durationMinutes + 5),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ],
        ),
        _Group(
          icon: Icons.place_rounded,
          title: l10n.reportWhere,
          children: [
            ArenaTextField(
              controller: _venue,
              labelText: l10n.matchReportVenue,
              onChaged: (value) => widget.onChanged(venue: value),
            ),
          ],
        ),
        _Group(
          icon: Icons.sports_rounded,
          title: l10n.reportRefereeing,
          children: [
            ArenaTextField(
              controller: _referee,
              labelText: l10n.matchReportReferee,
              onChaged: (value) => widget.onChanged(referee: value),
            ),
          ],
        ),
        _Group(
          icon: Icons.how_to_vote_rounded,
          title: l10n.reportVoting,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: match.isVotingOpen,
              onChanged: widget.busy ? null : (_) => widget.onToggleVoting(),
              title: Text(
                match.isVotingOpen ? l10n.reportVotingOpen : l10n.reportVotingClosed,
                style: AppTypography.label(color: AppColors.textPrimary),
              ),
              subtitle:
                  Text(l10n.matchReportVotingHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            ),
          ],
        ),
        _Group(
          icon: Icons.notes_rounded,
          title: l10n.matchReportNotes,
          children: [
            ArenaTextField(
              controller: _notes,
              hintText: l10n.reportNotesHint,
              maxLines: 5,
              onChaged: (value) => widget.onChanged(notes: value),
            ),
          ],
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Group({required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.s16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                ),
                child: Icon(icon, color: AppColors.primary, size: AppSizes.s18),
              ),
              const SizedBox(width: AppSizes.s10),
              Text(title, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16)),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          ...children,
        ],
      ),
    );
  }
}
