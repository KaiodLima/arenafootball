import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_rules.dart';

/// Tabela de pontos do Arena Fantasy (editável pelo admin): a padrão em
/// `config/pontuacao_fantasy.tabela` e a própria do campeonato em
/// `fantasy/{id}.pontuacao`. Mesmos campos e faixas do `scoringTable` das
/// functions (`functions/src/fantasy_scoring.ts`); o que falta ou é inválido
/// fica com o padrão de [FantasyScoringRules].
class FantasyScoringTable extends Equatable {
  final num base;
  final num goal;
  final num assist;
  final num win;
  final num draw;
  final num loss;
  final num yellow;
  final num red;
  final Map<FantasySlot, num> conceded;
  final Map<FantasySlot, num> cleanSheet;
  final Map<FantasySlot, num> teamGoal;

  /// Faixa aceita: −20 a 20, em passos de 0,5 (as regras do Firestore conferem).
  static const num limit = 20;
  static const num step = 0.5;

  /// Vagas que pontuam pela posição (a LIVRE usa a do atleta).
  static const positions = [FantasySlot.goalkeeper, FantasySlot.defender, FantasySlot.midfielder, FantasySlot.forward];

  const FantasyScoringTable({
    this.base = FantasyScoringRules.base,
    this.goal = FantasyScoringRules.goal,
    this.assist = FantasyScoringRules.assist,
    this.win = FantasyScoringRules.win,
    this.draw = FantasyScoringRules.draw,
    this.loss = FantasyScoringRules.loss,
    this.yellow = FantasyScoringRules.yellow,
    this.red = FantasyScoringRules.red,
    this.conceded = FantasyScoringRules.conceded,
    this.cleanSheet = FantasyScoringRules.cleanSheet,
    this.teamGoal = FantasyScoringRules.teamGoal,
  });

  /// Os padrões (os do código).
  static const defaults = FantasyScoringTable();

  static bool validValue(Object? value) =>
      value is num && value.isFinite && value.abs() <= limit && (value * 2) == (value * 2).roundToDouble();

  factory FantasyScoringTable.fromMap(Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};
    num pick(String field, num fallback) => validValue(map[field]) ? map[field] as num : fallback;
    Map<FantasySlot, num> group(String field, Map<FantasySlot, num> fallback) {
      final raw = map[field];
      final values = raw is Map ? raw : const {};
      return {
        for (final slot in positions)
          slot: validValue(values[slot.key]) ? values[slot.key] as num : (fallback[slot] ?? 0),
      };
    }

    return FantasyScoringTable(
      base: pick('base', FantasyScoringRules.base),
      goal: pick('gol', FantasyScoringRules.goal),
      assist: pick('assistencia', FantasyScoringRules.assist),
      win: pick('vitoria', FantasyScoringRules.win),
      draw: pick('empate', FantasyScoringRules.draw),
      loss: pick('derrota', FantasyScoringRules.loss),
      yellow: pick('amarelo', FantasyScoringRules.yellow),
      red: pick('vermelho', FantasyScoringRules.red),
      conceded: group('golsSofridos', FantasyScoringRules.conceded),
      cleanSheet: group('semSofrerGols', FantasyScoringRules.cleanSheet),
      teamGoal: group('golEquipe', FantasyScoringRules.teamGoal),
    );
  }

  Map<String, dynamic> toMap() => {
        'base': base,
        'gol': goal,
        'assistencia': assist,
        'vitoria': win,
        'empate': draw,
        'derrota': loss,
        'amarelo': yellow,
        'vermelho': red,
        'golsSofridos': {for (final slot in positions) slot.key: conceded[slot] ?? 0},
        'semSofrerGols': {for (final slot in positions) slot.key: cleanSheet[slot] ?? 0},
        'golEquipe': {for (final slot in positions) slot.key: teamGoal[slot] ?? 0},
      };

  /// Valor do lance [rule] (ver [FantasyScoreRule]).
  num valueOf(FantasyScoreRule rule) => switch (rule) {
        FantasyScoreRule.base => base,
        FantasyScoreRule.goal => goal,
        FantasyScoreRule.assist => assist,
        FantasyScoreRule.win => win,
        FantasyScoreRule.draw => draw,
        FantasyScoreRule.loss => loss,
        FantasyScoreRule.yellow => yellow,
        FantasyScoreRule.red => red,
      };

  /// Valor por posição do quesito [rule].
  num positionValue(FantasyPositionRule rule, FantasySlot slot) => switch (rule) {
        FantasyPositionRule.conceded => conceded[slot] ?? 0,
        FantasyPositionRule.cleanSheet => cleanSheet[slot] ?? 0,
        FantasyPositionRule.teamGoal => teamGoal[slot] ?? 0,
      };

  /// Troca um valor (o editor do admin), preso à faixa.
  FantasyScoringTable withValue(FantasyScoreRule rule, num value) {
    final v = _clamp(value);
    return FantasyScoringTable(
      base: rule == FantasyScoreRule.base ? v : base,
      goal: rule == FantasyScoreRule.goal ? v : goal,
      assist: rule == FantasyScoreRule.assist ? v : assist,
      win: rule == FantasyScoreRule.win ? v : win,
      draw: rule == FantasyScoreRule.draw ? v : draw,
      loss: rule == FantasyScoreRule.loss ? v : loss,
      yellow: rule == FantasyScoreRule.yellow ? v : yellow,
      red: rule == FantasyScoreRule.red ? v : red,
      conceded: conceded,
      cleanSheet: cleanSheet,
      teamGoal: teamGoal,
    );
  }

  FantasyScoringTable withPositionValue(FantasyPositionRule rule, FantasySlot slot, num value) {
    Map<FantasySlot, num> change(Map<FantasySlot, num> source, FantasyPositionRule which) =>
        which == rule ? {...source, slot: _clamp(value)} : source;
    return FantasyScoringTable(
      base: base,
      goal: goal,
      assist: assist,
      win: win,
      draw: draw,
      loss: loss,
      yellow: yellow,
      red: red,
      conceded: change(conceded, FantasyPositionRule.conceded),
      cleanSheet: change(cleanSheet, FantasyPositionRule.cleanSheet),
      teamGoal: change(teamGoal, FantasyPositionRule.teamGoal),
    );
  }

  static num _clamp(num value) {
    final rounded = (value * 2).round() / 2;
    final clamped = rounded.clamp(-limit, limit);
    return clamped == clamped.roundToDouble() ? clamped.round() : clamped;
  }

  @override
  List<Object?> get props => [base, goal, assist, win, draw, loss, yellow, red, conceded, cleanSheet, teamGoal];
}

/// Lances com um valor só (tabela "Pontuação").
enum FantasyScoreRule { base, goal, assist, win, draw, loss, yellow, red }

/// Quesitos por posição (tabela "Por posição").
enum FantasyPositionRule { conceded, cleanSheet, teamGoal }
