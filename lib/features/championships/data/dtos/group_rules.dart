import 'package:equatable/equatable.dart';

/// Faixa de uma posição na classificação do grupo.
enum GroupZone { none, qualified, playoff, eliminated }

/// Regras do grupo (`grupos{ano}.regras`), definidas pelo organizador/admin
/// em "Formar grupos". Cada uma só aparece na tela quando está ativa: 0 /
/// vazio / falso = desligada. Grupo sem o campo: 2 classificados (o
/// comportamento antigo).
class GroupRules extends Equatable {
  /// Os N primeiros (faixa verde).
  final int qualified;

  /// Nome da próxima fase ("Semifinal"); vazio = texto genérico.
  final String nextPhase;

  /// Os N depois dos classificados (faixa amarela).
  final int playoff;

  /// Os N últimos (faixa vermelha).
  final int eliminated;

  /// Ida e volta (informativo; desligado = não mostra nada).
  final bool homeAndAway;

  static const int maxCount = 20;
  static const int maxPhaseLength = 30;
  static const GroupRules standard = GroupRules();

  const GroupRules({
    this.qualified = 2,
    this.nextPhase = '',
    this.playoff = 0,
    this.eliminated = 0,
    this.homeAndAway = false,
  });

  /// Alguma regra com representação visual ativa.
  bool get hasAny => qualified > 0 || playoff > 0 || eliminated > 0 || homeAndAway;

  /// Faixa da posição [position] (1 = 1º) num grupo de [total] times: verde,
  /// depois amarela, e vermelha nos últimos; cada faixa corta no total e a
  /// de cima vence quando elas se sobrepõem.
  GroupZone zoneOf(int position, int total) {
    if (position < 1 || position > total) return GroupZone.none;
    if (position <= qualified) return GroupZone.qualified;
    if (position <= qualified + playoff) return GroupZone.playoff;
    if (eliminated > 0 && position > total - eliminated) return GroupZone.eliminated;
    return GroupZone.none;
  }

  /// Faixas que aparecem num grupo de [total] times (para a legenda).
  Set<GroupZone> zonesIn(int total) => {
        for (var p = 1; p <= total; p++) zoneOf(p, total),
      }..remove(GroupZone.none);

  /// As faixas somadas passam do total de times (aviso na configuração).
  bool exceeds(int total) => total > 0 && qualified + playoff + eliminated > total;

  static int _count(Object? value, int fallback) {
    final n = value is num ? value.toInt() : fallback;
    return n.clamp(0, maxCount);
  }

  factory GroupRules.fromMap(Object? data) {
    if (data is! Map) return standard;
    final phase = data['proximaFase']?.toString().trim() ?? '';
    return GroupRules(
      qualified: _count(data['classificados'], 2),
      nextPhase: phase.length > maxPhaseLength ? phase.substring(0, maxPhaseLength) : phase,
      playoff: _count(data['repescagem'], 0),
      eliminated: _count(data['eliminados'], 0),
      homeAndAway: data['idaVolta'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'classificados': qualified,
        'proximaFase': nextPhase,
        'repescagem': playoff,
        'eliminados': eliminated,
        'idaVolta': homeAndAway,
      };

  GroupRules copyWith({int? qualified, String? nextPhase, int? playoff, int? eliminated, bool? homeAndAway}) =>
      GroupRules(
        qualified: qualified ?? this.qualified,
        nextPhase: nextPhase ?? this.nextPhase,
        playoff: playoff ?? this.playoff,
        eliminated: eliminated ?? this.eliminated,
        homeAndAway: homeAndAway ?? this.homeAndAway,
      );

  @override
  List<Object?> get props => [qualified, nextPhase, playoff, eliminated, homeAndAway];
}
