import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
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

  /// Times oferecidos: os participantes do campeonato escolhido (ou todos da
  /// região, se ele não tiver times marcados).
  final List<TeamDTO> teams;

  /// Todos os times da região (base para filtrar por campeonato).
  final List<TeamDTO> regionTeams;

  /// Todos os times da temporada (campeonato intermunicipal: times de fora
  /// da região).
  final List<TeamDTO> seasonTeams;

  /// Campeonatos da região na temporada atual.
  final List<ChampionshipDTO> championships;

  /// `id_campeonato` escolhido; nulo = sem campeonato (amistoso, ou região
  /// sem campeonato cadastrado).
  final int? championshipId;
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
    this.regionTeams = const [],
    this.seasonTeams = const [],
    this.championships = const [],
    this.championshipId,
    this.homeTeam,
    this.awayTeam,
    this.date = '',
    this.time = '',
    this.venue = '',
    this.customVenue = false,
    this.existing = const [],
  });

  bool get sameTeam => homeTeam != null && homeTeam == awayTeam;

  /// O admin escolheu "Sem campeonato" (a região tem campeonatos).
  bool get isFriendly => championshipId == null && championships.isNotEmpty;

  /// Times do campeonato [id] (todos da região se ele não marcou nenhum).
  /// Intermunicipal: os dele de qualquer região.
  List<TeamDTO> teamsFor(int? id) {
    final championship = championships.where((c) => c.championshipId == id).firstOrNull;
    if (championship == null || championship.teams.isEmpty) return regionTeams;
    final base = championship.isIntermunicipal && seasonTeams.isNotEmpty ? seasonTeams : regionTeams;
    return base.where((t) => championship.hasTeam(id: t.id, name: t.name)).toList();
  }

  /// Ids das regiões dos dois times quando são diferentes (vazio = mesma
  /// região): a partida aparece nas duas.
  List<String> get regionIdsOfTeams {
    String regionIdOf(String? name) {
      for (final team in teams) {
        if (team.name == name) return RegionRegistry.idOf(team.region);
      }
      return '';
    }

    final ids = {regionIdOf(homeTeam), regionIdOf(awayTeam), RegionRegistry.idOf(selectedRegion ?? '')}..remove('');
    return ids.length > 1 ? ids.toList() : const [];
  }

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

  /// Id do time de nome [teamName] na lista carregada ('' se não achar).
  String teamIdOf(String? teamName) => TeamDirectory(teams).idOf(name: teamName ?? '');

  String? crestOf(String? teamName) {
    if (teamName == null) return null;
    for (final team in teams) {
      if (team.name == teamName) return team.imageUrl;
    }
    return null;
  }

  /// Cor principal ("#RRGGBB") do time de nome [teamName] ('' sem cor).
  String colorOf(String? teamName) {
    for (final team in teams) {
      if (team.name == teamName) return team.primaryColor;
    }
    return '';
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
        homeTeamId: teamIdOf(homeTeam),
        awayTeamId: teamIdOf(awayTeam),
        date: date,
        time: time,
        venue: venue.trim(),
        region: selectedRegion ?? '',
        championshipId: championshipId ?? 0,
        regionIds: regionIdsOfTeams,
      );

  MatchFormData copyWith({
    List<String>? regions,
    String? selectedRegion,
    List<TeamDTO>? teams,
    List<TeamDTO>? regionTeams,
    List<TeamDTO>? seasonTeams,
    List<ChampionshipDTO>? championships,
    int? Function()? championshipId,
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
      regionTeams: regionTeams ?? this.regionTeams,
      seasonTeams: seasonTeams ?? this.seasonTeams,
      championships: championships ?? this.championships,
      championshipId: championshipId != null ? championshipId() : this.championshipId,
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
  List<Object?> get props => [
        regions,
        selectedRegion,
        teams,
        regionTeams,
        seasonTeams,
        championships,
        championshipId,
        homeTeam,
        awayTeam,
        date,
        time,
        venue,
        customVenue,
        existing
      ];
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
