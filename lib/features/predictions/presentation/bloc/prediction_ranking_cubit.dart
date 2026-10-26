import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_prediction_ranking_usecase.dart';

/// Ranking do bolão da região escolhida: o top 50 e a linha da conta.
class PredictionRankingState extends Equatable {
  final String region;
  final List<PredictionRankingEntry> entries;
  final PredictionRankingEntry? mine;
  final int? myPosition;
  final bool loading;
  final String? errorMessage;

  const PredictionRankingState({
    this.region = '',
    this.entries = const [],
    this.mine,
    this.myPosition,
    this.loading = true,
    this.errorMessage,
  });

  /// Posição de quem está no índice [index] (empate em pontos e exatos divide).
  int positionAt(int index) {
    final entry = entries[index];
    return entries.indexWhere((e) => e.points == entry.points && e.exact == entry.exact) + 1;
  }

  @override
  List<Object?> get props => [region, entries, mine, myPosition, loading, errorMessage];
}

class PredictionRankingCubit extends Cubit<PredictionRankingState> {
  final GetPredictionRankingUseCase getPredictionRankingUseCase;

  PredictionRankingCubit(this.getPredictionRankingUseCase) : super(const PredictionRankingState());

  Future<void> load({required String region, String uid = '', String? season}) async {
    emit(PredictionRankingState(region: region));
    final regionId = RegionRegistry.idOf(region);
    if (regionId.isEmpty) {
      emit(PredictionRankingState(region: region, loading: false));
      return;
    }
    final response = await getPredictionRankingUseCase(regionId: regionId, uid: uid, season: season);
    if (isClosed || state.region != region) return;
    response.fold(
      (failure) => emit(PredictionRankingState(region: region, loading: false, errorMessage: failure.toString())),
      (ranking) => emit(PredictionRankingState(
        region: region,
        entries: ranking.top,
        mine: ranking.mine,
        myPosition: ranking.myPosition,
        loading: false,
      )),
    );
  }
}
