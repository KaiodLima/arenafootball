import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/players/presentation/widgets/squad_player_row.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Lance escolhido na folha: o atleta (nulo = gol sem autor), o garçom e o
/// minuto. Na substituição, [player] sai e [assistant] entra.
typedef PickedEvent = ({PlayerDTO? player, PlayerDTO? assistant, int? minute});

/// Atleta oferecido na folha, com o número da camisa da escalação.
typedef PickItem = ({PlayerDTO player, int? number, bool related});

/// Bloco da folha: os atletas de uma posição (nula = "Sem posição").
typedef PickSection = ({PlayerPosition? position, List<PickItem> items});

/// Atletas agrupados por posição na ordem do campo (goleiros → atacantes,
/// sem posição no fim); dentro do setor, pelo número da camisa e o nome.
List<PickSection> groupedForPicking(List<PlayerDTO> players, List<LineupEntry> lineup) {
  final entries = {for (final e in lineup) e.playerId: e};
  int order(PlayerDTO p) => PlayerPosition.fromKey(p.position)?.index ?? PlayerPosition.values.length;
  final byOrder = <int, List<PickItem>>{};
  for (final p in players) {
    byOrder.putIfAbsent(order(p), () => []).add(
      (player: p, number: entries[p.id]?.number, related: entries.containsKey(p.id)),
    );
  }
  final orders = byOrder.keys.toList()..sort();
  return [
    for (final o in orders)
      (
        position: o < PlayerPosition.values.length ? PlayerPosition.values[o] : null,
        items: byOrder[o]!
          ..sort((a, b) {
            final byNumber = (a.number ?? 999).compareTo(b.number ?? 999);
            return byNumber != 0 ? byNumber : a.player.name.toLowerCase().compareTo(b.player.name.toLowerCase());
          }),
      ),
  ];
}

/// Folha de lançamento (estilo súmula de árbitro): minuto grande com − e +
/// (já com o do relógio) e os atletas **em campo** ([onField]; nulo = sem
/// escalação, o elenco todo) em grade, agrupados por posição, com o número
/// da camisa. No gol, o 2º passo pergunta o garçom ("Sem assistência" em
/// destaque). Na [substitution], o 1º passo é quem sai (em campo) e o 2º
/// quem entra (fora de campo, sem quem já saiu: [substitutedOut]).
Future<PickedEvent?> showPlayerGridSheet(
  BuildContext context, {
  required String title,
  required Widget icon,
  required Color color,
  required List<PlayerDTO> squad,
  required List<LineupEntry> lineup,
  Set<String>? onField,
  Set<String> substitutedOut = const {},
  int? minute,
  bool goal = false,
  bool substitution = false,
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
      onField: onField,
      substitutedOut: substitutedOut,
      minute: minute,
      goal: goal,
      substitution: substitution,
    ),
  );
}

class _PlayerGridSheet extends StatefulWidget {
  final String title;
  final Widget icon;
  final Color color;
  final List<PlayerDTO> squad;
  final List<LineupEntry> lineup;
  final Set<String>? onField;
  final Set<String> substitutedOut;
  final int? minute;
  final bool goal;
  final bool substitution;

  const _PlayerGridSheet({
    required this.title,
    required this.icon,
    required this.color,
    required this.squad,
    required this.lineup,
    required this.onField,
    required this.substitutedOut,
    required this.minute,
    required this.goal,
    required this.substitution,
  });

  @override
  State<_PlayerGridSheet> createState() => _PlayerGridSheetState();
}

class _PlayerGridSheetState extends State<_PlayerGridSheet> {
  late int? _minute = widget.minute;

  /// Gol: autor escolhido (2º passo = o garçom). Substituição: quem sai
  /// (2º passo = quem entra).
  PlayerDTO? _first;
  bool _secondStep = false;

  void _bump(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      final next = (_minute ?? 0) + delta;
      _minute = next < 1 ? null : next;
    });
  }

  void _pick(PlayerDTO? player) {
    HapticFeedback.lightImpact();
    final twoSteps = widget.goal || widget.substitution;
    if (!twoSteps) {
      Navigator.pop(context, (player: player, assistant: null, minute: _minute));
      return;
    }
    if (!_secondStep) {
      // Gol sem autor não tem garçom.
      if (player == null) {
        Navigator.pop(context, (player: null, assistant: null, minute: _minute));
        return;
      }
      setState(() {
        _first = player;
        _secondStep = true;
      });
      return;
    }
    Navigator.pop(context, (player: _first, assistant: player, minute: _minute));
  }

  /// Quem aparece no passo atual.
  List<PlayerDTO> get _players {
    final onField = widget.onField;
    bool inField(PlayerDTO p) => onField == null || onField.contains(p.id);
    if (widget.substitution && _secondStep) {
      // Quem entra: fora de campo, sem quem já saiu nem quem acabou de sair.
      return widget.squad
          .where((p) =>
              p.id != _first?.id &&
              !widget.substitutedOut.contains(p.id) &&
              (onField == null || !onField.contains(p.id)))
          .toList();
    }
    return widget.squad.where((p) => inField(p) && !(_secondStep && p.id == _first?.id)).toList();
  }

  String _stepTitle(AppLocalizations l10n) {
    if (widget.substitution) return _secondStep ? l10n.reportWhoEnters : l10n.reportWhoLeaves;
    return _secondStep ? l10n.reportWhoAssisted : widget.title;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = groupedForPicking(_players, widget.lineup);
    final showEmpty = widget.goal;
    final emptyLabel = _secondStep ? l10n.reportNoAssist : l10n.reportGoalNoScorer;
    final subtitle = _secondStep && _first != null
        ? (widget.substitution ? l10n.reportLeaving(_first!.name) : l10n.reportGoalBy(_first!.name))
        : (widget.substitution ? widget.title : null);

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
                      Text(_stepTitle(l10n), style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                      if (subtitle != null)
                        Text(subtitle, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
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
                : CustomScrollView(
                    slivers: [
                      // Sem escalação: o elenco todo, com o lembrete.
                      if (widget.onField == null)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s10),
                          sliver: SliverToBoxAdapter(child: _Notice(label: l10n.reportLineupNeeded)),
                        ),
                      if (showEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s10),
                          sliver: SliverToBoxAdapter(
                            child: SizedBox(
                              height: AppSizes.s80,
                              child: _EmptyTile(label: emptyLabel, highlight: _secondStep, onTap: () => _pick(null)),
                            ),
                          ),
                        ),
                      if (sections.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.s24),
                            child: Text(l10n.reportNobodyToPick,
                                textAlign: TextAlign.center, style: AppTypography.subtitle()),
                          ),
                        ),
                      for (final section in sections) ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s4, AppSizes.s20, AppSizes.s8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              '${squadSectionTitle(l10n, section.position).toUpperCase()}  ·  ${section.items.length}',
                              style: AppTypography.label(color: AppColors.textSecondary)
                                  .copyWith(fontSize: AppSizes.s12, letterSpacing: 0.6),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s16),
                          sliver: SliverGrid.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: AppSizes.s10,
                              crossAxisSpacing: AppSizes.s10,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: section.items.length,
                            itemBuilder: (context, i) {
                              final item = section.items[i];
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
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String label;

  const _Notice({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSizes.s10),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.s12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: AppSizes.s18, color: AppColors.textPrimary),
            const SizedBox(width: AppSizes.s8),
            Expanded(child: Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12))),
          ],
        ),
      );
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
