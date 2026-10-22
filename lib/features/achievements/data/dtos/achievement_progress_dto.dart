import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';

/// Contadores do usuário (`usuarios/{uid}/progresso/contadores`): um número
/// por métrica, a sequência atual de dias e o último dia de uso registrado.
class AchievementProgressDTO extends Equatable {
  final Map<AchievementMetric, int> counters;

  /// Dias seguidos até o último registro (zera se pular um dia).
  final int streak;

  /// Hora do servidor do último dia de uso registrado.
  final DateTime? lastVisit;

  const AchievementProgressDTO({this.counters = const {}, this.streak = 0, this.lastVisit});

  static const String streakField = 'sequenciaDias';
  static const String lastVisitField = 'ultimoAcesso';

  int valueOf(AchievementMetric metric) => counters[metric] ?? 0;

  factory AchievementProgressDTO.fromMap(Map<String, dynamic>? data) {
    int number(Object? value) => value is num ? value.toInt() : 0;
    final last = data?[lastVisitField];
    return AchievementProgressDTO(
      counters: {for (final metric in AchievementMetric.values) metric: number(data?[metric.key])},
      streak: number(data?[streakField]),
      lastVisit: last is Timestamp ? last.toDate() : null,
    );
  }

  /// Junta números calculados no app (time do coração, atleta...) enquanto
  /// o servidor não grava: fica o maior.
  AchievementProgressDTO withDerived(Map<AchievementMetric, int> derived) => AchievementProgressDTO(
        counters: {
          for (final metric in AchievementMetric.values)
            metric: [valueOf(metric), derived[metric] ?? 0].reduce((a, b) => a > b ? a : b),
        },
        streak: streak,
        lastVisit: lastVisit,
      );

  @override
  List<Object?> get props => [counters, streak, lastVisit];
}

/// Conquista desbloqueada (`usuarios/{uid}/conquistas/{id}`, gravada pelo servidor).
class AchievementUnlockDTO extends Equatable {
  final String achievementId;
  final DateTime? unlockedAt;

  /// O usuário já viu a comemoração.
  final bool seen;

  const AchievementUnlockDTO({required this.achievementId, this.unlockedAt, this.seen = false});

  factory AchievementUnlockDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final at = data['em'];
    return AchievementUnlockDTO(
      achievementId: doc.id,
      unlockedAt: at is Timestamp ? at.toDate() : null,
      seen: data['vista'] == true,
    );
  }

  @override
  List<Object?> get props => [achievementId, unlockedAt, seen];
}
