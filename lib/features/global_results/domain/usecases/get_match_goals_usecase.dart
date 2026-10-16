import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_global_results_usecase.dart';

/// Gols de um jogo encerrado, lidos da página de análise do jogo ([url] =
/// [GlobalMatch.detailsUrl]). A lista do dia só traz os autores dos jogos em
/// destaque; os demais são buscados sob demanda.
class GetMatchGoalsUseCase {
  final IGlobalResultsRepository _repository;

  GetMatchGoalsUseCase(this._repository);

  Future<Either<Failure, List<GoalEvent>>> call(String url) async {
    final response = await scrape(url);
    return response.map(GetGlobalResultsUseCase.goalsOf);
  }

  /// Gols crus do site (o que vai para o cache local).
  Future<Either<Failure, List<ScrapedGoalDTO>>> scrape(String url) => _repository.getMatchGoals(url);
}
