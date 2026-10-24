import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

abstract class IPlayersRepository {
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers(
      {String teamId = '', required String teamName, String? season});

  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season});

  /// Os [limit] jogadores com mais [field] (`PlayerDTO.goalsField` ou
  /// `assistsField`) entre os times [teamIds], em ordem decrescente.
  Future<Either<Failure, List<PlayerDTO>>> getTopPlayers({
    required List<String> teamIds,
    required String field,
    int limit = 50,
    String? season,
  });

  /// Os [limit] jogadores com mais [field] na competição [championshipId].
  Future<Either<Failure, List<PlayerDTO>>> getTopPlayersInChampionship({
    required int championshipId,
    required String field,
    int limit = 50,
    String? season,
  });

  Stream<Either<Failure, PlayerDTO?>> watchPlayer({required String id, String? season});

  /// Atleta vinculado à conta (nulo se não tem).
  Stream<Either<Failure, PlayerDTO?>> watchPlayerOfUser({required String userId, String? season});

  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season});

  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season});

  Future<Either<Failure, void>> deletePlayer(PlayerDTO player, {String? season});

  /// Tira do elenco: com [championshipId], só da competição.
  Future<Either<Failure, void>> removeFromSquad(PlayerDTO player, {int? championshipId, String? season});

  /// Inscrições do atleta pelo time nas competições [selected].
  Future<Either<Failure, void>> setChampionships(
    PlayerDTO player, {
    required String teamId,
    required String team,
    required Set<int> selected,
    required List<int> teamChampionships,
    String? season,
  });

  /// Inscreve o atleta numa competição (time da [enrollment]).
  Future<Either<Failure, void>> enroll(PlayerDTO player, PlayerEnrollment enrollment, {String? season});

  /// Soma gols/assistências ao jogador (atômico); com [enrollment], também na
  /// competição dela; [friendly] soma só na contagem de amistosos.
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    PlayerEnrollment? enrollment,
    bool friendly = false,
    String? season,
  });

  /// Manutenção: acerta o Geral e grava os amistosos contados nas partidas;
  /// devolve quantos atletas mudaram.
  Future<Either<Failure, int>> repairTotals(Map<String, ({int goals, int assists})> friendlyCounts, {String? season});
}
