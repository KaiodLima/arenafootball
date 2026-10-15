import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';

/// Lista do admin: todos os campeonatos em tempo real, filtrados pela região
/// escolhida nos chips. A temporada mais recente aparece primeiro.
class ManageChampionshipsState extends Equatable {
  final List<ChampionshipDTO> championships;
  final String region;
  final bool loading;

  const ManageChampionshipsState({this.championships = const [], this.region = '', this.loading = true});

  List<ChampionshipDTO> get visible {
    final list = championships.where((c) => c.region == region).toList()..sort((a, b) => b.season.compareTo(a.season));
    return list;
  }

  ManageChampionshipsState copyWith({List<ChampionshipDTO>? championships, String? region, bool? loading}) {
    return ManageChampionshipsState(
      championships: championships ?? this.championships,
      region: region ?? this.region,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [championships, region, loading];
}

class ErrorManageChampionshipsState extends ManageChampionshipsState {
  final String errorMessage;

  ErrorManageChampionshipsState(ManageChampionshipsState from, {required this.errorMessage})
      : super(championships: from.championships, region: from.region, loading: false);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

class DeletedManageChampionshipsState extends ManageChampionshipsState {
  DeletedManageChampionshipsState(ManageChampionshipsState from)
      : super(championships: from.championships, region: from.region, loading: false);
}
