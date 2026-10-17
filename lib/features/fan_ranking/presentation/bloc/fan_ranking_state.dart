import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';

/// Tela "Ranking de torcidas": o ranking da temporada (todas as regiões) e a
/// região escolhida nos chips; a lista da região sai daqui, sem ler de novo.
class FanRankingState extends Equatable {
  final FanRankingDTO? ranking;
  final String region;
  final bool loading;
  final String? errorMessage;

  const FanRankingState({this.ranking, this.region = '', this.loading = true, this.errorMessage});

  /// Times da região escolhida, na ordem do ranking.
  List<FanRankingEntry> get entries => ranking?.entriesOf(region) ?? const [];

  /// Torcedores contados na região (base das barras).
  int get regionFans => entries.fold(0, (sum, entry) => sum + entry.fans);

  /// Posição (1 = primeiro) do time na região; nulo se não estiver.
  /// Empate divide a posição (mesmo número de torcedores = mesma posição).
  int? positionOf({String teamId = '', String teamName = ''}) {
    final list = entries;
    final index = list.indexWhere((e) => e.isTeam(id: teamId, teamName: teamName));
    if (index < 0) return null;
    return positionAt(index);
  }

  /// Posição de quem está no índice [index] da lista (empates dividem).
  int positionAt(int index) {
    final list = entries;
    final fans = list[index].fans;
    return list.indexWhere((e) => e.fans == fans) + 1;
  }

  FanRankingState copyWith({
    FanRankingDTO? ranking,
    String? region,
    bool? loading,
    String? Function()? errorMessage,
  }) {
    return FanRankingState(
      ranking: ranking ?? this.ranking,
      region: region ?? this.region,
      loading: loading ?? this.loading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [ranking, region, loading, errorMessage];
}
