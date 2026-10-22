import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championship_cache_first_usecase.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Cadastra uma partida. Como no app antigo: sempre na temporada corrente
/// (coleção `partidas` sem sufixo), placar 0 x 0 e votação fechada. O
/// `id_campeonato` vem do campeonato cadastrado da região na temporada; sem
/// cadastro, da tabela fixa do app antigo.
class CreateMatchUseCase {
  final IMatchesRepository _repository;
  final GetRegionChampionshipCacheFirstUseCase _getRegionChampionship;

  CreateMatchUseCase(this._repository, this._getRegionChampionship);

  static const String invalidTeamsCode = 'invalid-teams';

  /// Os dois times precisam de nome com no mínimo 3 caracteres.
  static bool isTeamValid(String? team) => team != null && team.trim().length >= 3;

  /// Número do campeonato de cada região (tabela fixa do app antigo, usada
  /// quando a região ainda não tem campeonato cadastrado).
  static int championshipIdFor(String region) {
    switch (region) {
      case 'Floresta':
        return 1;
      case 'Santo inacio':
        return 2;
      default:
        return 0;
    }
  }

  /// [friendly]: o admin escolheu "Sem campeonato" (amistoso): grava 0, sem
  /// procurar o da região nem usar a tabela fixa.
  Future<Either<Failure, void>> call(MatchDTO match, {bool friendly = false}) async {
    if (!isTeamValid(match.homeTeam) || !isTeamValid(match.awayTeam)) {
      return Left(ErrorWithMessage('Preencha todos os campos!!!', code: invalidTeamsCode));
    }
    return _repository.createMatch(
      MatchDTO(
        homeTeam: match.homeTeam,
        awayTeam: match.awayTeam,
        // Vínculo com os times pelo id (o nome é só cópia).
        homeTeamId: match.homeTeamId,
        awayTeamId: match.awayTeamId,
        date: match.date,
        time: match.time,
        venue: match.venue,
        region: match.region,
        regionIds: match.regionIds,
        durationMinutes: match.durationMinutes,
        // Escolhido no formulário; amistoso, nenhum; sem escolha, o da região.
        championshipId: friendly
            ? 0
            : match.championshipId > 0
                ? match.championshipId
                : await _championshipIdOf(match.region),
      ),
    );
  }

  Future<int> _championshipIdOf(String region) async {
    // Cache-first: fica com a última emissão (o remoto quando revalidou).
    final response = await _getRegionChampionship(region: region, season: SeasonCollection.currentSeason).last;
    final registered = response.fold((_) => null, (championship) => championship?.championshipId);
    return registered != null && registered > 0 ? registered : championshipIdFor(region);
  }
}
