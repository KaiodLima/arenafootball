import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// "Atrasou": a partida passa a começar em outro horário. O card, o relógio,
/// o bolão e as functions (card de votação, resultado, encerramento) seguem o
/// `horario`, então tudo acompanha; o 1º horário fica em `horarioOriginal`.
class DelayMatchUseCase {
  final IMatchesRepository _repository;

  DelayMatchUseCase(this._repository);

  /// Atalhos da folha (minutos a partir do horário atual).
  static const List<int> quickMinutes = [10, 15, 20, 30];

  /// "HH:mm" + [minutes], sem passar de 23:59; nulo se [time] não der para ler.
  static String? addMinutes(String time, int minutes) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first.trim());
    final minute = parts.length > 1 ? int.tryParse(parts[1].trim()) : 0;
    if (hour == null || minute == null) return null;
    final total = (hour * 60 + minute + minutes).clamp(0, 23 * 60 + 59);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(total ~/ 60)}:${two(total % 60)}';
  }

  /// Iniciada antes da hora (em andamento, sem intervalo nem 2º tempo) ou
  /// pausada: atrasar volta a partida para antes do jogo, no horário novo.
  static bool resetsClock(MatchDTO match) =>
      match.manualStatus == MatchManualStatus.waiting ||
      (match.manualStatus == MatchManualStatus.live && match.halfTimeAt == null && match.secondHalfAt == null);

  Future<Either<Failure, MatchDTO>> call({required MatchDTO match, required String newTime, String? season}) async {
    // Atrasou de novo: o original continua o primeiro.
    final original = match.originalTime.trim().isNotEmpty ? match.originalTime : match.time;
    final reset = resetsClock(match);
    final response = await _repository.delayMatch(
      matchId: match.id,
      newTime: newTime,
      originalTime: original,
      resetClock: reset,
      season: season,
    );
    return response.map((_) => match.withDelay(newTime, originalTime: original, resetClock: reset));
  }
}
