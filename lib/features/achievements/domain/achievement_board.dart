import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';

/// Uma conquista no quadro do usuário: o progresso e se já ganhou.
class AchievementEntry extends Equatable {
  final AchievementDTO achievement;
  final int current;
  final bool unlocked;
  final DateTime? unlockedAt;

  const AchievementEntry({required this.achievement, required this.current, required this.unlocked, this.unlockedAt});

  /// Progresso até a meta (0–1).
  double get progress => unlocked ? 1 : (current / achievement.goal).clamp(0.0, 1.0);

  /// Secreta e ainda bloqueada: não revela o que é.
  bool get hidden => achievement.secret && !unlocked;

  @override
  List<Object?> get props => [achievement, current, unlocked, unlockedAt];
}

/// Quadro de conquistas do usuário: catálogo ativo + contadores + desbloqueios.
/// Desbloqueada = o servidor gravou o desbloqueio ou o contador já chegou à
/// meta (o app mostra na hora, sem esperar a function).
class AchievementBoard extends Equatable {
  final List<AchievementEntry> entries;

  const AchievementBoard(this.entries);

  static const AchievementBoard empty = AchievementBoard([]);

  factory AchievementBoard.of({
    required List<AchievementDTO> catalog,
    required AchievementProgressDTO progress,
    Map<String, AchievementUnlockDTO> unlocks = const {},
  }) {
    final active = catalog.where((a) => a.active && a.metric != null).toList()
      ..sort((a, b) {
        final byOrder = a.order.compareTo(b.order);
        return byOrder != 0 ? byOrder : a.goal.compareTo(b.goal);
      });
    return AchievementBoard([
      for (final achievement in active)
        () {
          final current = progress.valueOf(achievement.metric!);
          final unlock = unlocks[achievement.id];
          return AchievementEntry(
            achievement: achievement,
            current: current,
            unlocked: unlock != null || current >= achievement.goal,
            unlockedAt: unlock?.unlockedAt,
          );
        }(),
    ]);
  }

  List<AchievementEntry> get unlocked => entries.where((e) => e.unlocked).toList();

  int get xp => unlocked.fold(0, (sum, e) => sum + e.achievement.points);

  FanLevel get level => FanLevel.of(xp);

  List<AchievementEntry> ofCategory(AchievementCategory? category) =>
      category == null ? entries : entries.where((e) => e.achievement.category == category).toList();

  /// Últimas desbloqueadas (com data), da mais nova para a mais antiga.
  List<AchievementEntry> recent({int limit = 8}) {
    final dated = unlocked.where((e) => e.unlockedAt != null).toList()
      ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
    return dated.take(limit).toList();
  }

  /// Melhores medalhas para a vitrine (carteirinha): maior nível, depois mais pontos.
  List<AchievementEntry> best({int limit = 3}) {
    final sorted = [...unlocked]..sort((a, b) {
        final byTier = b.achievement.tier.index.compareTo(a.achievement.tier.index);
        return byTier != 0 ? byTier : b.achievement.points.compareTo(a.achievement.points);
      });
    return sorted.take(limit).toList();
  }

  @override
  List<Object?> get props => [entries];
}

/// Registro do dia de uso: dias diferentes, sequência de dias seguidos e a
/// maior sequência. O dia é o de Brasília (UTC-3, sem horário de verão).
class DailyVisit {
  static DateTime _day(DateTime moment) {
    final brasilia = moment.toUtc().subtract(const Duration(hours: 3));
    return DateTime.utc(brasilia.year, brasilia.month, brasilia.day);
  }

  /// Campos a gravar hoje; nulo se o dia de [now] já foi registrado.
  static ({int activeDays, int streak, int bestStreak})? next(AchievementProgressDTO progress, DateTime now) {
    final last = progress.lastVisit;
    final today = _day(now);
    if (last != null && !_day(last).isBefore(today)) return null;
    final consecutive = last != null && today.difference(_day(last)).inDays == 1;
    final streak = consecutive ? progress.streak + 1 : 1;
    final best = progress.valueOf(AchievementMetric.bestStreak);
    return (
      activeDays: progress.valueOf(AchievementMetric.activeDays) + 1,
      streak: streak,
      bestStreak: streak > best ? streak : best,
    );
  }
}
