import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';

/// Painel "Temporadas": a atual, as disponíveis e a opção de copiar os times
/// ao iniciar a próxima.
class SeasonsPanelState extends Equatable {
  final String current;
  final List<String> seasons;
  final bool copyTeams;

  const SeasonsPanelState({required this.current, required this.seasons, this.copyTeams = true});

  String get next => SeasonsConfigDTO.nextSeason(current);

  SeasonsPanelState copyWith({String? current, List<String>? seasons, bool? copyTeams}) => SeasonsPanelState(
        current: current ?? this.current,
        seasons: seasons ?? this.seasons,
        copyTeams: copyTeams ?? this.copyTeams,
      );

  @override
  List<Object?> get props => [current, seasons, copyTeams];
}

class ReadySeasonsPanelState extends SeasonsPanelState {
  const ReadySeasonsPanelState({required super.current, required super.seasons, super.copyTeams});
}

class StartingSeasonsPanelState extends SeasonsPanelState {
  StartingSeasonsPanelState(SeasonsPanelState from)
      : super(current: from.current, seasons: from.seasons, copyTeams: from.copyTeams);
}

/// Temporada nova iniciada: a página avisa e atualiza o seletor do app.
class StartedSeasonsPanelState extends SeasonsPanelState {
  const StartedSeasonsPanelState({required super.current, required super.seasons, super.copyTeams});
}

class ErrorSeasonsPanelState extends SeasonsPanelState {
  final String errorMessage;

  ErrorSeasonsPanelState(SeasonsPanelState from, {required this.errorMessage})
      : super(current: from.current, seasons: from.seasons, copyTeams: from.copyTeams);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
