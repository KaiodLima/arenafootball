import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arena_soccer/features/matches/domain/match_form_hints.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Data da partida: Hoje, Amanhã, próximo sábado/domingo e "Outra data"
/// (calendário). Uma data escolhida no calendário vira um chip selecionado.
class MatchDateChips extends StatelessWidget {
  /// Data atual do formulário ("dd/MM").
  final String selected;
  final ValueChanged<DateTime> onSelected;

  /// Só para teste.
  final DateTime? now;

  const MatchDateChips({super.key, required this.selected, required this.onSelected, this.now});

  Future<void> _pickOther(BuildContext context, DateTime today) async {
    _dropFocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365)),
    );
    // Ao fechar o diálogo o Flutter devolve o foco ao último campo (o de
    // local) e o teclado reabre: tira de novo.
    _dropFocus();
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final today = now ?? DateTime.now();
    final quick = MatchFormHints.quickDates(today);
    final quickKeys = quick.map(WatchMatchesUseCase.formatMatchDate).toList();

    String label(DateTime date, int index) {
      if (index == 0) return l10n.matchFormToday;
      if (index == 1) return l10n.matchFormTomorrow;
      // "sáb 18/10"
      final weekday = DateFormat.E(locale).format(date).replaceAll('.', '');
      return '$weekday ${WatchMatchesUseCase.formatMatchDate(date)}';
    }

    final custom = selected.isNotEmpty && !quickKeys.contains(selected);

    return Wrap(
      spacing: AppSizes.s8,
      runSpacing: AppSizes.s8,
      children: [
        for (var i = 0; i < quick.length; i++)
          ArenaChoiceChip(
            label: label(quick[i], i),
            selected: quickKeys[i] == selected,
            onTap: () => onSelected(quick[i]),
          ),
        ArenaChoiceChip(
          label: custom ? selected : l10n.matchFormOtherDate,
          icon: Icons.calendar_month_outlined,
          selected: custom,
          onTap: () => _pickOther(context, today),
        ),
      ],
    );
  }
}

/// Horário: os mais usados na região e "Outro horário" (relógio 24h).
class MatchTimeChips extends StatelessWidget {
  final List<String> frequent;
  final String selected;
  final ValueChanged<String> onSelected;

  const MatchTimeChips({super.key, required this.frequent, required this.selected, required this.onSelected});

  Future<void> _pickOther(BuildContext context) async {
    _dropFocus();
    final parts = selected.split(':');
    final initial = parts.length == 2
        ? TimeOfDay(hour: int.tryParse(parts[0]) ?? 16, minute: int.tryParse(parts[1]) ?? 0)
        : const TimeOfDay(hour: 16, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    _dropFocus();
    if (picked == null) return;
    String two(int n) => n.toString().padLeft(2, '0');
    onSelected('${two(picked.hour)}:${two(picked.minute)}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final custom = selected.isNotEmpty && !frequent.contains(selected);

    return Wrap(
      spacing: AppSizes.s8,
      runSpacing: AppSizes.s8,
      children: [
        for (final time in frequent)
          ArenaChoiceChip(label: time, selected: time == selected, onTap: () => onSelected(time)),
        ArenaChoiceChip(
          label: custom ? selected : l10n.matchFormOtherTime,
          icon: Icons.schedule_rounded,
          selected: custom,
          onTap: () => _pickOther(context),
        ),
      ],
    );
  }
}

void _dropFocus() => FocusManager.instance.primaryFocus?.unfocus();
