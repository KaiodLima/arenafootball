import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/fan_ranking/domain/usecases/get_fan_ranking_cache_first_usecase.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/bloc/fan_ranking_state.dart';

/// Ranking de torcidas da temporada atual. Uma leitura (com cache) traz todas
/// as regiões; trocar de região só filtra.
class FanRankingCubit extends Cubit<FanRankingState> {
  final GetFanRankingCacheFirstUseCase getFanRankingCacheFirstUseCase;

  FanRankingCubit(this.getFanRankingCacheFirstUseCase) : super(const FanRankingState());

  Future<void> load({required String season, required String region, bool force = false}) async {
    emit(state.copyWith(region: region, loading: true, errorMessage: () => null));
    await for (final response in getFanRankingCacheFirstUseCase(season: season, force: force)) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(state.copyWith(loading: false, errorMessage: () => failure.toString())),
        (ranking) => emit(state.copyWith(ranking: ranking, loading: false, errorMessage: () => null)),
      );
    }
    if (!isClosed && state.loading) emit(state.copyWith(loading: false));
  }

  void selectRegion(String region) {
    if (region != state.region) emit(state.copyWith(region: region));
  }
}
