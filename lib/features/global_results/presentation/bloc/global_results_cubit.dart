import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_global_results_cache_first_usecase.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/global_results_state.dart';

/// Resultados pelo mundo do dia escolhido, com busca e filtro "ao vivo".
class GlobalResultsCubit extends Cubit<GlobalResultsState> {
  final GetGlobalResultsCacheFirstUseCase getGlobalResultsCacheFirstUseCase;

  GlobalResultsCubit(this.getGlobalResultsCacheFirstUseCase) : super(const LoadingGlobalResultsState());

  /// Troca de dia: mostra o carregando e zera o filtro ao vivo (a busca fica).
  Future<void> load(ResultsDay day) async {
    emit(LoadingGlobalResultsState(day: day, query: state.query));
    await _fetch(day);
  }

  /// Puxar para atualizar: recarrega o mesmo dia (ignora o cache local)
  /// mantendo a lista na tela.
  Future<void> refresh() => _fetch(state.day, force: true);

  /// Cache local primeiro (ver `cacheFirst`): o dia reaberto em poucos
  /// minutos aparece sem esperar o scraping.
  Future<void> _fetch(ResultsDay day, {bool force = false}) async {
    await for (final response in getGlobalResultsCacheFirstUseCase(day, force: force)) {
      // Ignora a resposta se o usuário trocou de dia enquanto carregava.
      if (isClosed || state.day != day) return;
      _apply(day, response);
    }
  }

  void _apply(ResultsDay day, Either<Failure, List<GlobalMatch>> response) {
    response.fold(
      (failure) => emit(ErrorGlobalResultsState(
        day: day,
        errorMessage: failure.toString(),
        matches: state.matches,
        query: state.query,
        liveOnly: state.liveOnly,
      )),
      (matches) => emit(SuccessGlobalResultsState(
        day: day,
        matches: matches,
        query: state.query,
        // Sem jogos ao vivo, o filtro esvaziaria a tela.
        liveOnly: state.liveOnly && matches.any((m) => m.isLive),
      )),
    );
  }

  void setQuery(String query) => _emitView(query: query);

  void toggleLive() => _emitView(liveOnly: !state.liveOnly);

  void _emitView({String? query, bool? liveOnly}) {
    final s = state;
    if (s is LoadingGlobalResultsState) {
      emit(LoadingGlobalResultsState(day: s.day, query: query ?? s.query));
    } else if (s is ErrorGlobalResultsState) {
      emit(ErrorGlobalResultsState(
        day: s.day,
        errorMessage: s.errorMessage,
        matches: s.matches,
        query: query ?? s.query,
        liveOnly: liveOnly ?? s.liveOnly,
      ));
    } else {
      emit(SuccessGlobalResultsState(
        day: s.day,
        matches: s.matches,
        query: query ?? s.query,
        liveOnly: liveOnly ?? s.liveOnly,
      ));
    }
  }
}
