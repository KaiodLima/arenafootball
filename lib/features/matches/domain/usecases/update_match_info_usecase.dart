import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Dados da partida editados pela engrenagem ("Editar partida").
typedef MatchInfoEdit = ({String date, String time, int durationMinutes, String venue});

/// "Editar partida": grava só data, horário, duração e local (o que o admin
/// e o organizador da competição podem mudar depois do cadastro). Devolve a
/// partida com os dados novos; sem mudança, não grava.
class UpdateMatchInfoUseCase {
  final IMatchesRepository _repository;

  UpdateMatchInfoUseCase(this._repository);

  Future<Either<Failure, MatchDTO>> call({required MatchDTO match, required MatchInfoEdit info, String? season}) async {
    final updated = match.copyWith(
      date: info.date.trim(),
      time: info.time.trim(),
      durationMinutes: info.durationMinutes,
      venue: info.venue.trim(),
    );
    final same = updated.date == match.date &&
        updated.time == match.time &&
        updated.durationMinutes == match.durationMinutes &&
        updated.venue == match.venue;
    if (same) return Right(match);
    final response = await _repository.updateMatchInfo(
      matchId: match.id,
      date: updated.date,
      time: updated.time,
      durationMinutes: updated.durationMinutes,
      venue: updated.venue,
      season: season,
    );
    return response.map((_) => updated);
  }
}
