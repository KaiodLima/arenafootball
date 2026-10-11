import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_state.dart';

/// Artilharia / líderes de assistência de uma região na temporada. O quesito
/// pode ser trocado na mesma tela com [setType]; cada quesito é lido uma vez e
/// guardado, então voltar para o anterior é instantâneo.
class StatsRankingCubit extends Cubit<StatsRankingState> {
  final GetStatsRankingUseCase getStatsRankingUseCase;
  String _region = '';
  String _season = '';

  /// Descarta respostas antigas quando o usuário troca de quesito rápido.
  int _request = 0;
  final Map<StatsRankingType, StatsRanking> _cache = {};

  StatsRankingCubit(this.getStatsRankingUseCase) : super(const LoadingStatsRankingState());

  Future<void> load({required StatsRankingType type, required String region, required String season}) async {
    if (region != _region || season != _season) _cache.clear();
    _region = region;
    _season = season;
    final request = ++_request;
    final cached = _cache[type];
    if (cached != null) {
      emit(SuccessStatsRankingState(type: type, entries: cached.entries, crests: cached.crests));
      return;
    }
    // Lista do outro quesito não serve enquanto carrega (os números mudariam
    // de sentido); os escudos, sim.
    emit(LoadingStatsRankingState(type: type, crests: state.crests));
    final response = await getStatsRankingUseCase(type: type, region: region, season: season);
    if (isClosed || request != _request) return;
    response.fold(
      (failure) => emit(ErrorStatsRankingState(
        errorMessage: failure.toString(),
        type: type,
        crests: state.crests,
      )),
      (ranking) {
        _cache[type] = ranking;
        emit(SuccessStatsRankingState(type: type, entries: ranking.entries, crests: ranking.crests));
      },
    );
  }

  void setType(StatsRankingType type) {
    if (type == state.type && state is! ErrorStatsRankingState) return;
    load(type: type, region: _region, season: _season);
  }
}
