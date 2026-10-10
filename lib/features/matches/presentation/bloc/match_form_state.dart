import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/create_match_usecase.dart';

/// Dados do formulário de partida. Sobrevive às transições
/// Editing → Submitting → Error/Success.
class MatchFormData extends Equatable {
  final List<String> regions;
  final String? selectedRegion;
  final List<String> teams;
  final String? homeTeam;
  final String? awayTeam;
  final String date;
  final String time;
  final String venue;

  const MatchFormData({
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.homeTeam,
    this.awayTeam,
    this.date = '',
    this.time = '',
    this.venue = '',
  });

  bool get canSubmit =>
      selectedRegion != null && CreateMatchUseCase.isTeamValid(homeTeam) && CreateMatchUseCase.isTeamValid(awayTeam);

  /// Partida pronta para o UseCase (id, placar e campeonato são definidos lá).
  MatchDTO toMatch() => MatchDTO(
        homeTeam: homeTeam ?? '',
        awayTeam: awayTeam ?? '',
        date: date,
        time: time,
        venue: venue,
        region: selectedRegion ?? '',
      );

  MatchFormData copyWith({
    List<String>? regions,
    String? selectedRegion,
    List<String>? teams,
    String? homeTeam,
    String? awayTeam,
    String? date,
    String? time,
    String? venue,
    bool clearTeams = false,
  }) {
    return MatchFormData(
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      teams: teams ?? this.teams,
      homeTeam: clearTeams ? null : (homeTeam ?? this.homeTeam),
      awayTeam: clearTeams ? null : (awayTeam ?? this.awayTeam),
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
    );
  }

  @override
  List<Object?> get props => [regions, selectedRegion, teams, homeTeam, awayTeam, date, time, venue];
}

class MatchFormState extends Equatable {
  final MatchFormData form;

  const MatchFormState({this.form = const MatchFormData()});

  @override
  List<Object?> get props => [form];
}

class EditingMatchFormState extends MatchFormState {
  const EditingMatchFormState({super.form});
}

class SubmittingMatchFormState extends MatchFormState {
  const SubmittingMatchFormState({required super.form});
}

class SuccessMatchFormState extends MatchFormState {
  const SuccessMatchFormState({required super.form});
}

class ErrorMatchFormState extends MatchFormState {
  final String errorMessage;

  const ErrorMatchFormState({required super.form, required this.errorMessage});

  @override
  List<Object?> get props => [form, errorMessage];
}
