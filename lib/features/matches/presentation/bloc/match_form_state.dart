import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_form_hints.dart';
import 'package:arena_soccer/features/matches/domain/usecases/create_match_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Primeiro dado que falta para cadastrar (erro mostrado na tela).
enum MatchFormMissing { teams, sameTeam, date, time }

/// Dados do formulário de partida. Sobrevive às transições
/// Editing → Submitting → Error/Success.
class MatchFormData extends Equatable {
  final List<String> regions;
  final String? selectedRegion;
  final List<TeamDTO> teams;
  final String? homeTeam;
  final String? awayTeam;

  /// "dd/MM", como gravado nas partidas.
  final String date;

  /// "HH:mm".
  final String time;
  final String venue;

  /// O admin está digitando um local novo (fora das sugestões).
  final bool customVenue;

  /// Partidas já cadastradas na região (sugestões e conflitos).
  final List<MatchDTO> existing;

  const MatchFormData({
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.homeTeam,
    this.awayTeam,
    this.date = '',
    this.time = '',
    this.venue = '',
    this.customVenue = false,
    this.existing = const [],
  });

  bool get sameTeam => homeTeam != null && homeTeam == awayTeam;

  MatchFormMissing? get missing {
    if (!CreateMatchUseCase.isTeamValid(homeTeam) || !CreateMatchUseCase.isTeamValid(awayTeam)) {
      return MatchFormMissing.teams;
    }
    if (sameTeam) return MatchFormMissing.sameTeam;
    if (date.isEmpty) return MatchFormMissing.date;
    if (time.isEmpty) return MatchFormMissing.time;
    return null;
  }

  bool get canSubmit => selectedRegion != null && missing == null;

  String? crestOf(String? teamName) {
    if (teamName == null) return null;
    for (final team in teams) {
      if (team.name == teamName) return team.imageUrl;
    }
    return null;
  }

  List<String> get frequentTimes => MatchFormHints.frequentTimes(existing);

  List<String> get frequentVenues => MatchFormHints.frequentVenues(existing);

  List<MatchConflict> get conflicts => MatchFormHints.conflicts(
        existing,
        home: homeTeam,
        away: awayTeam,
        date: date,
        time: time,
        venue: venue,
      );

  /// Partida pronta para o UseCase (id, placar e campeonato são definidos lá).
  MatchDTO toMatch() => MatchDTO(
        homeTeam: homeTeam ?? '',
        awayTeam: awayTeam ?? '',
        date: date,
        time: time,
        venue: venue.trim(),
        region: selectedRegion ?? '',
      );

  MatchFormData copyWith({
    List<String>? regions,
    String? selectedRegion,
    List<TeamDTO>? teams,
    String? homeTeam,
    String? awayTeam,
    String? date,
    String? time,
    String? venue,
    bool? customVenue,
    List<MatchDTO>? existing,
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
      customVenue: customVenue ?? this.customVenue,
      existing: existing ?? this.existing,
    );
  }

  @override
  List<Object?> get props =>
      [regions, selectedRegion, teams, homeTeam, awayTeam, date, time, venue, customVenue, existing];
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
