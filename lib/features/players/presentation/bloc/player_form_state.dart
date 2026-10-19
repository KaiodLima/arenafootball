import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Erro de validação do formulário, traduzido na página via l10n.
enum PlayerFormError { name, championship, team }

/// Dados do formulário de jogador. Sobrevive às transições
/// Editing → Submitting → Error/Success.
class PlayerFormData extends Equatable {
  static const int maxCount = 999;

  final String name;
  final int goals;
  final int assists;
  final List<String> regions;
  final String? selectedRegion;

  /// Times da região selecionada (temporada corrente), com escudo.
  final List<TeamDTO> teams;
  final String? selectedTeam;

  /// Foto opcional (enviada junto com o cadastro).
  final File? photo;

  /// Elenco atual do time escolhido (lista e aviso de duplicado).
  final List<PlayerDTO> squad;

  /// Competições da região e a escolhida: o atleta já entra inscrito nela
  /// pelo time (sem competições na região, só o time, como antes).
  final List<ChampionshipDTO> championships;
  final int? championshipId;

  const PlayerFormData({
    this.name = '',
    this.goals = 0,
    this.assists = 0,
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.selectedTeam,
    this.photo,
    this.squad = const [],
    this.championships = const [],
    this.championshipId,
  });

  ChampionshipDTO? get selectedChampionship {
    for (final c in championships) {
      if (c.championshipId == championshipId) return c;
    }
    return null;
  }

  /// Times que dá para escolher: os da competição (sem competições, todos).
  List<TeamDTO> get selectableTeams {
    final championship = selectedChampionship;
    if (championship == null) return championships.isEmpty ? teams : const [];
    return teams.where((t) => championship.hasTeam(id: t.id, name: t.name)).toList();
  }

  /// Regras do app antigo: nome com no mínimo 3 caracteres e time escolhido
  /// (e a competição, quando a região tem).
  PlayerFormError? get error {
    if (name.trim().length < 3) return PlayerFormError.name;
    if (championships.isNotEmpty && selectedChampionship == null) return PlayerFormError.championship;
    if (selectedTeam == null || selectedTeam!.isEmpty) return PlayerFormError.team;
    return null;
  }

  /// Jogador do elenco com o mesmo nome (sem diferenciar acento, caixa e
  /// espaços extras); nulo se não há.
  PlayerDTO? get duplicate {
    final key = _key(name);
    if (key.isEmpty) return null;
    for (final player in squad) {
      if (_key(player.name) == key) return player;
    }
    return null;
  }

  static String _key(String text) => foldForSearch(text.trim().replaceAll(RegExp(r'\s+'), ' '));

  /// Há algo que se perderia ao sair.
  bool get isDirty => name.trim().isNotEmpty || goals > 0 || assists > 0 || photo != null;

  String? crestOf(String? teamName) {
    for (final team in teams) {
      if (team.name == teamName) return team.imageUrl;
    }
    return null;
  }

  /// Id do time escolhido ('' se não achar na lista).
  String get selectedTeamId => TeamDirectory(teams).idOf(name: selectedTeam ?? '');

  PlayerDTO toPlayer() {
    final championship = selectedChampionship;
    return PlayerDTO(
      name: name.trim(),
      team: selectedTeam ?? '',
      teamId: selectedTeamId,
      goals: goals,
      assists: assists,
      enrollments: [
        if (championship != null)
          PlayerEnrollment(
            championshipId: championship.championshipId,
            teamId: selectedTeamId,
            team: selectedTeam ?? '',
            goals: goals,
            assists: assists,
          ),
      ],
    );
  }

  /// Troca a lista de times; seleciona o primeiro que dá para escolher
  /// (como o app antigo).
  PlayerFormData withTeams(List<TeamDTO> teams) {
    final next = PlayerFormData(
      name: name,
      goals: goals,
      assists: assists,
      regions: regions,
      selectedRegion: selectedRegion,
      teams: teams,
      photo: photo,
      championships: championships,
      championshipId: championshipId,
    );
    final selectable = next.selectableTeams;
    return next.copyWith(
        selectedTeam: selectable.isEmpty ? null : selectable.first.name, clearTeam: selectable.isEmpty);
  }

  /// Troca as competições (e a escolhida); o time fica se jogar nela.
  PlayerFormData withChampionships(List<ChampionshipDTO> championships, int? championshipId) {
    final next = PlayerFormData(
      name: name,
      goals: goals,
      assists: assists,
      regions: regions,
      selectedRegion: selectedRegion,
      teams: teams,
      selectedTeam: selectedTeam,
      photo: photo,
      squad: squad,
      championships: championships,
      championshipId: championshipId,
    );
    final selectable = next.selectableTeams;
    if (selectable.any((t) => t.name == selectedTeam)) return next;
    return next.copyWith(
        selectedTeam: selectable.isEmpty ? null : selectable.first.name, clearTeam: selectable.isEmpty);
  }

  /// Formulário limpo para o próximo cadastro, mantendo região, time e elenco.
  PlayerFormData cleared() => PlayerFormData(
        regions: regions,
        selectedRegion: selectedRegion,
        teams: teams,
        selectedTeam: selectedTeam,
        squad: squad,
        championships: championships,
        championshipId: championshipId,
      );

  PlayerFormData copyWith({
    String? name,
    int? goals,
    int? assists,
    List<String>? regions,
    String? selectedRegion,
    String? selectedTeam,
    File? photo,
    bool clearPhoto = false,
    List<PlayerDTO>? squad,
    bool clearTeam = false,
  }) {
    return PlayerFormData(
      name: name ?? this.name,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      teams: teams,
      selectedTeam: clearTeam ? null : (selectedTeam ?? this.selectedTeam),
      photo: clearPhoto ? null : (photo ?? this.photo),
      squad: squad ?? this.squad,
      championships: championships,
      championshipId: championshipId,
    );
  }

  @override
  List<Object?> get props => [
        name,
        goals,
        assists,
        regions,
        selectedRegion,
        teams,
        selectedTeam,
        photo?.path,
        squad,
        championships,
        championshipId
      ];
}

class PlayerFormState extends Equatable {
  final PlayerFormData form;

  const PlayerFormState({this.form = const PlayerFormData()});

  @override
  List<Object?> get props => [form];
}

class EditingPlayerFormState extends PlayerFormState {
  const EditingPlayerFormState({super.form});
}

class SubmittingPlayerFormState extends PlayerFormState {
  const SubmittingPlayerFormState({required super.form});
}

/// Jogador gravado; [form] já vem limpo para o próximo cadastro.
class SuccessPlayerFormState extends PlayerFormState {
  const SuccessPlayerFormState({required super.form});
}

class ErrorPlayerFormState extends PlayerFormState {
  final String errorMessage;

  const ErrorPlayerFormState({required super.form, required this.errorMessage});

  @override
  List<Object?> get props => [form, errorMessage];
}
