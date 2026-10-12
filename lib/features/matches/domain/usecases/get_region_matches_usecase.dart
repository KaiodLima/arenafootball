import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Partidas de uma região na temporada (de todos os campeonatos). Leitura
/// única, usada para sugestões e conflitos no cadastro de partida.
class GetRegionMatchesUseCase {
  final IMatchesRepository _repository;

  GetRegionMatchesUseCase(this._repository);

  Future<Either<Failure, List<MatchDTO>>> call({required String region, String? season}) async {
    final response = await _repository.watchMatches(season: season).first;
    return response.map((matches) => matches.where((m) => m.region == region).toList());
  }
}
