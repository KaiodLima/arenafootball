import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Lance escolhido na folha: o atleta (nulo = gol sem autor), o garçom e o minuto.
typedef PickedEvent = ({PlayerDTO? player, PlayerDTO? assistant, int? minute});

/// Atletas na ordem da súmula: titulares (pelo número), reservas e o resto do
/// elenco; com o número da camisa de quem está na escalação.
List<({PlayerDTO player, int? number, bool related})> orderedForPicking(
  List<PlayerDTO> squad,
  List<LineupEntry> lineup,
) {
  final entries = {for (final e in lineup) e.playerId: e};
  int rank(PlayerDTO p) {
    final e = entries[p.id];
    if (e == null) return 2;
    return e.starter ? 0 : 1;
  }

  final list = [...squad]..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      final na = entries[a.id]?.number ?? 999;
      final nb = entries[b.id]?.number ?? 999;
      if (na != nb) return na.compareTo(nb);
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  return [for (final p in list) (player: p, number: entries[p.id]?.number, related: entries.containsKey(p.id))];
}

/// Folha de lançamento (estilo súmula de árbitro): minuto grande com − e +
/// (já com o do relógio) e os atletas em grade com o número da camisa. No
/// gol, o 2º passo pergunta o garçom ("Sem assistência" em destaque).
Future<PickedEvent?> showPlayerGridSheet(
  BuildContext context, {
  required String title,
  required Widget icon,
  required Color color,
  required List<PlayerDTO> squad,
  required List<LineupEntry> lineup,
  int? minute,
  bool goal = false,
}) {
  return showModalBottomSheet<PickedEvent>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _PlayerGridSheet(
      title: title,
      icon: icon,
      color: color,
      squad: squad,
      lineup: lineup,
      minute: minute,
      goal: goal,
    ),
  );
}

class _PlayerGridSheet extends StatefulWidget {
  final String title;
  final Widget icon;
  final Color color;
  final List<PlayerDTO> squad;
  final List<LineupEntry> lineup;
  final int? minute;
  final bool goal;

  const _PlayerGridSheet({
    required this.title,
    required this.icon,
    required this.color,
    required this.squad,
    required this.lineup,
    required this.minute,
    required this.goal,
  });

  @override
  State<_PlayerGridSheet> createState() => _PlayerGridSheetState();
}

class _PlayerGridSheetState extends State<_PlayerGridSheet> {
  late int? _minute = widget.minute;

  /// Gol: autor escolhido (2º passo = o garçom).
  PlayerDTO? _scorer;
  bool _choosingAssist = false;

  void _bump(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      final next = (_minute ?? 0) + delta;
      _minute = next < 1 ? null : next;
    });
  }

  void _pick(PlayerDTO? player) {
    HapticFeedback.lightImpact();
    if (!widget.goal) {
      Navigator.pop(context, (player: player, assistant: null, minute: _minute));
      return;
    }
    if (!_choosingAssist) {
      // Gol sem autor não tem garçom.
      if (player == null) {
        Navigator.pop(context, (player: null, assistant: null, minute: _minute));
        return;
      }
      setState(() {
        _scorer = player;
        _choosingAssist = true;
      });
      return;
    }
    Navigator.pop(context, (player: _scorer, assistant: player, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final players = orderedForPicking(widget.squad, widget.lineup)
        .where((p) => !_choosingAssist || p.player.id != _scorer?.id)
        .toList();
    final emptyLabel = _choosingAssist ? l10n.reportNoAssist : l10n.reportGoalNoScorer;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
            child: Row(
              children: [
                widget.icon,
                const SizedBox(width: AppSizes.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _choosingAssist ? l10n.reportWhoAssisted : widget.title,
                        style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
                      ),
                      if (_choosingAssist)
                        Text(
                          l10n.reportGoalBy(_scorer!.name),
                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                        ),
                    ],
                  ),
                ),
                _MinuteStepper(minute: _minute, onBump: _bump),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.s12),
          Expanded(
            child: widget.squad.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSizes.s24),
                    child: Column(
                      children: [
                        Text(l10n.matchReportNoSquad, textAlign: TextAlign.center, style: AppTypography.subtitle()),
                        if (widget.goal) ...[
                          const SizedBox(height: AppSizes.s16),
                          _WideTile(label: l10n.reportGoalNoScorer, onTap: () => _pick(null)),
                        ],
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: AppSizes.s10,
                      crossAxisSpacing: AppSizes.s10,
                      childAspectRatio: 0.82,
                    ),
                    // O 1º quadrado: "sem autor" (gol) ou "sem assistência".
                    itemCount: players.length + (widget.goal ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (widget.goal && i == 0) {
                        return _EmptyTile(label: emptyLabel, highlight: _choosingAssist, onTap: () => _pick(null));
                      }
                      final item = players[i - (widget.goal ? 1 : 0)];
                      return _PlayerTile(
                        player: item.player,
                        number: item.number,
                        related: item.related,
                        color: widget.color,
                        onTap: () => _pick(item.player),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MinuteStepper extends StatelessWidget {
  final int? minute;
  final ValueChanged<int> onBump;

  const _MinuteStepper({required this.minute, required this.onBump});

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, int delta) => InkResponse(
          onTap: () => onBump(delta),
          radius: AppSizes.s20,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.s6),
            child: Icon(icon, size: AppSizes.s18, color: AppColors.primaryDark),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.remove_rounded, -1),
          SizedBox(
            width: AppSizes.s44,
            child: Text(
              minute == null ? "–'" : "$minute'",
              textAlign: TextAlign.center,
              style: AppTypography.title(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s20),
            ),
          ),
          button(Icons.add_rounded, 1),
        ],
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final PlayerDTO player;
  final int? number;
  final bool related;
  final Color color;
  final VoidCallback onTap;

  const _PlayerTile({
    required this.player,
    required this.number,
    required this.related,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: related ? color.withValues(alpha: 0.08) : AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.s16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.s8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PlayerAvatar(player: player, size: AppSizes.s48),
                  if (number != null)
                    Positioned(
                      right: -AppSizes.s6,
                      bottom: -AppSizes.s4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s1),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(AppSizes.s8),
                          border: Border.all(color: AppColors.white, width: AppSizes.s2),
                        ),
                        child: Text(
                          '$number',
                          style: AppTypography.label(color: AppColors.white)
                              .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.s8),
              Text(
                player.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  final String label;
  final bool highlight;
  final VoidCallback onTap;

  const _EmptyTile({required this.label, required this.highlight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlight ? AppColors.gold.withValues(alpha: 0.25) : AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.s16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.s8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                highlight ? Icons.do_not_disturb_alt_rounded : Icons.help_outline_rounded,
                size: AppSizes.s36,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: AppSizes.s8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WideTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.sports_soccer_rounded),
        label: Text(label),
      );
}
