import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_global_results_usecase.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/global_results_state.dart';

class GlobalResultsCubit extends Cubit<GlobalResultsState> {
  final GetGlobalResultsUseCase getGlobalResultsUseCase;

  GlobalResultsCubit(this.getGlobalResultsUseCase) : super(const LoadingGlobalResultsState());

  Future<void> load(ResultsDay day) async {
    emit(LoadingGlobalResultsState(day: day));
    final response = await getGlobalResultsUseCase(day);
    // Ignora a resposta se o usuário trocou de dia enquanto carregava.
    if (state.day != day) return;
    response.fold(
      (failure) => emit(ErrorGlobalResultsState(day: day, errorMessage: failure.toString())),
      (matches) => emit(SuccessGlobalResultsState(day: day, matches: matches)),
    );
  }
}
