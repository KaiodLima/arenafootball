import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_match_goals_cache_first_usecase.dart';

/// Situação dos gols de um jogo buscados sob demanda.
enum GoalsStatus { loading, loaded, failed }

class MatchGoals extends Equatable {
  final GoalsStatus status;
  final List<GoalEvent> goals;

  const MatchGoals(this.status, [this.goals = const []]);

  @override
  List<Object?> get props => [status, goals];
}

/// Cache dos gols dos jogos encerrados, por [GlobalMatch.detailsUrl]. Fica
/// separado da lista para que só a linha do jogo reconstrua ao carregar.
class MatchGoalsCubit extends Cubit<Map<String, MatchGoals>> {
  final GetMatchGoalsCacheFirstUseCase getMatchGoalsCacheFirstUseCase;

  MatchGoalsCubit(this.getMatchGoalsCacheFirstUseCase) : super(const {});

  /// Busca os gols de [match] se ainda não carregou (ou se falhou antes).
  Future<void> load(GlobalMatch match) async {
    final url = match.detailsUrl;
    final current = state[url];
    if (url.isEmpty || current?.status == GoalsStatus.loading || current?.status == GoalsStatus.loaded) return;

    emit({...state, url: const MatchGoals(GoalsStatus.loading)});
    // Cache local primeiro (ver `cacheFirst`): reabrir o jogo não refaz o scraping.
    await for (final response in getMatchGoalsCacheFirstUseCase(url)) {
      if (isClosed) return;
      emit({
        ...state,
        url: response.fold(
          (_) => const MatchGoals(GoalsStatus.failed),
          (goals) => MatchGoals(GoalsStatus.loaded, goals),
        ),
      });
    }
  }
}
