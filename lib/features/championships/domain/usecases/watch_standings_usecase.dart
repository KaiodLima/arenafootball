import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Classificação de um grupo, já ordenada por pontos e saldo de gols
/// (a ordenação vem da consulta).
class WatchStandingsUseCase {
  final IChampionshipsRepository _repository;

  WatchStandingsUseCase(this._repository);

  Stream<Either<Failure, List<StandingDTO>>> call({required String region, required String group, String? season}) =>
      _repository.watchStandings(region: region, group: group, season: season);
}
