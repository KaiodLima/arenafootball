import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_state.dart';

/// Artilharia / líderes de assistência de uma região na temporada.
class StatsRankingCubit extends Cubit<StatsRankingState> {
  final GetStatsRankingUseCase getStatsRankingUseCase;

  StatsRankingCubit(this.getStatsRankingUseCase) : super(const LoadingStatsRankingState());

  Future<void> load({required StatsRankingType type, required String region, required String season}) async {
    emit(LoadingStatsRankingState(players: state.players));
    final response = await getStatsRankingUseCase(type: type, region: region, season: season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorStatsRankingState(errorMessage: failure.toString(), players: state.players)),
      (players) => emit(SuccessStatsRankingState(players: players)),
    );
  }
}
