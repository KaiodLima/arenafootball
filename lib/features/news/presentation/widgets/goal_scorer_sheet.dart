import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Quem fez o gol e quem deu o passe (ambos nulos = o admin pulou).
class GoalScorerResult {
  final PlayerDTO? scorer;
  final PlayerDTO? assistant;

  const GoalScorerResult({this.scorer, this.assistant});
}

/// Painel aberto ao marcar um gol para [team]: passo 1 escolhe o autor no
/// elenco do time; passo 2, quem deu o passe (o mesmo elenco, sem o autor).
/// Fechar sem concluir devolve `null`.
Future<GoalScorerResult?> showGoalScorerSheet(
  BuildContext context, {
  required String team,
  required String? crest,
  required List<PlayerDTO> squad,
  PlayerDTO? initialScorer,
  PlayerDTO? initialAssistant,
}) {
  return showModalBottomSheet<GoalScorerResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _GoalScorerSheet(
      team: team,
      crest: crest,
      squad: squad,
      initialScorer: initialScorer,
      initialAssistant: initialAssistant,
    ),
  );
}

class _GoalScorerSheet extends StatefulWidget {
  final String team;
  final String? crest;
  final List<PlayerDTO> squad;
  final PlayerDTO? initialScorer;
  final PlayerDTO? initialAssistant;

  const _GoalScorerSheet({
    required this.team,
    required this.crest,
    required this.squad,
    required this.initialScorer,
    required this.initialAssistant,
  });

  @override
  State<_GoalScorerSheet> createState() => _GoalScorerSheetState();
}

class _GoalScorerSheetState extends State<_GoalScorerSheet> {
  PlayerDTO? _scorer;
  String _query = '';

  /// Passo 2 (assistência) depois que o autor foi escolhido. Reabrindo para
  /// editar, sempre começa no autor; o atual vem destacado.
  bool get _choosingAssist => _scorer != null;

  void _pickScorer(PlayerDTO player) => setState(() {
        _scorer = player;
        _query = '';
      });

  void _finish(PlayerDTO? assistant) => Navigator.pop(context, GoalScorerResult(scorer: _scorer, assistant: assistant));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final term = foldForSearch(_query.trim());
    final scorer = _scorer;
    final options = widget.squad
        .where((p) => scorer == null || p.id != scorer.id)
        .where((p) => term.isEmpty || foldForSearch(p.name).contains(term))
        .toList();
    final highlighted = _choosingAssist ? widget.initialAssistant?.id : widget.initialScorer?.id;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s4),
              child: Row(
                children: [
                  TeamCrest(imageUrl: widget.crest, size: AppSizes.s28),
                  const SizedBox(width: AppSizes.s8),
                  Expanded(
                    child: Text(
                      l10n.goalOfTeam(widget.team).toUpperCase(),
                      style: AppTypography.label(color: AppColors.textSecondary)
                          .copyWith(fontSize: AppSizes.s12, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Padding(
                key: ValueKey(_choosingAssist),
                padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s4, AppSizes.s20, AppSizes.s12),
                child: Row(
                  children: [
                    if (scorer != null) ...[
                      PlayerAvatar(player: scorer, size: AppSizes.s32),
                      const SizedBox(width: AppSizes.s8),
                    ],
                    Expanded(
                      child: Text(
                        _choosingAssist ? l10n.goalWhoAssistedQ(scorer!.name) : l10n.goalWhoScoredQ,
                        style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
              child: ArenaSearchField(
                key: ValueKey('search-$_choosingAssist'),
                hint: l10n.goalSearchPlayer,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: AppSizes.s4),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: ListView.builder(
                  key: ValueKey('list-$_choosingAssist'),
                  padding: const EdgeInsets.only(bottom: AppSizes.s8),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final player = options[index];
                    final isHighlighted = player.id == highlighted;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
                      leading: PlayerAvatar(player: player, size: AppSizes.s44),
                      title: Text(
                        player.name,
                        style: AppTypography.body().copyWith(
                          fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          StatPill(icon: Icons.sports_soccer_rounded, value: player.goals),
                          const SizedBox(width: AppSizes.s6),
                          StatPill(icon: Icons.assistant_rounded, value: player.assists),
                        ],
                      ),
                      trailing: isHighlighted
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => _choosingAssist ? _finish(player) : _pickScorer(player),
                    );
                  },
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s4, AppSizes.s12, AppSizes.s8),
                child: Row(
                  children: [
                    if (_choosingAssist)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _scorer = null;
                          _query = '';
                        }),
                        icon: const Icon(Icons.chevron_left_rounded),
                        label: Text(l10n.goalBack),
                      ),
                    const Spacer(),
                    if (_choosingAssist)
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () => _finish(null),
                        child: Text(l10n.goalNoAssist),
                      )
                    else
                      TextButton(
                        onPressed: () => Navigator.pop(context, const GoalScorerResult()),
                        child: Text(l10n.goalSkip),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
