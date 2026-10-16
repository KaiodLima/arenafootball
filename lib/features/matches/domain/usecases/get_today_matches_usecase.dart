import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';

/// Partidas de hoje de uma região na temporada (de todos os campeonatos),
/// ordenadas pelo horário. Leitura única (não fica ouvindo).
class GetTodayMatchesUseCase {
  final IMatchesRepository _repository;

  GetTodayMatchesUseCase(this._repository);

  Future<Either<Failure, List<MatchDTO>>> call({required String region, String? season, DateTime? now}) async {
    final today = WatchMatchesUseCase.formatMatchDate(now ?? DateTime.now());
    final response = await _repository.watchMatches(season: season, region: region).first;
    // Região já filtrada no servidor; o filtro abaixo é só uma rede de segurança.
    return response.map(
      (matches) => matches.where((m) => m.region == region && m.date == today).toList()
        ..sort((a, b) => a.time.compareTo(b.time)),
    );
  }
}
