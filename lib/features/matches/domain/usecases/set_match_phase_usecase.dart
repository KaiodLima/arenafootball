import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Ações do admin no andamento da partida (relógio de jogo).
enum MatchPhase {
  /// "Iniciar partida": 1º tempo a partir de agora (zera intervalo e 2º tempo).
  start,

  /// "Intervalo": fim do 1º tempo, relógio parado.
  halfTime,

  /// "Iniciar 2º tempo": o relógio volta a partir da metade da duração.
  secondHalf,

  /// "Encerrar partida".
  finish,
}

/// Admin muda a fase da partida na mão: grava o `status` e a hora do
/// servidor no campo do relógio da fase.
class SetMatchPhaseUseCase {
  final IMatchesRepository _repository;

  SetMatchPhaseUseCase(this._repository);

  static const String startedField = 'inicioEm';
  static const String halfTimeField = 'intervaloEm';
  static const String secondHalfField = 'segundoTempoEm';

  Future<Either<Failure, MatchDTO>> call({required MatchDTO match, required MatchPhase phase, String? season}) async {
    final (status, stamp, clear) = switch (phase) {
      MatchPhase.start => (MatchManualStatus.live, startedField, const [halfTimeField, secondHalfField]),
      MatchPhase.halfTime => (MatchManualStatus.halfTime, halfTimeField, const <String>[]),
      MatchPhase.secondHalf => (MatchManualStatus.live, secondHalfField, const <String>[]),
      MatchPhase.finish => (MatchManualStatus.finished, null, const <String>[]),
    };
    final response = await _repository.setManualStatus(
      matchId: match.id,
      status: status,
      stampField: stamp,
      clearFields: clear,
      season: season,
    );
    // Hora local até o stream trazer a do servidor.
    final now = DateTime.now();
    return response.map((_) => switch (phase) {
          MatchPhase.start => match.withRestartedClock(now),
          MatchPhase.halfTime => match.copyWith(manualStatus: status, halfTimeAt: now),
          MatchPhase.secondHalf => match.copyWith(manualStatus: status, secondHalfAt: now),
          MatchPhase.finish => match.copyWith(manualStatus: status),
        });
  }
}
