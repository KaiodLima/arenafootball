import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Erro de validação do formulário, traduzido na página via l10n.
enum PlayerFormError { name, team }

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
  });

  /// Regras do app antigo: nome com no mínimo 3 caracteres e time escolhido.
  PlayerFormError? get error {
    if (name.trim().length < 3) return PlayerFormError.name;
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

  PlayerDTO toPlayer() => PlayerDTO(
        name: name.trim(),
        team: selectedTeam ?? '',
        teamId: selectedTeamId,
        goals: goals,
        assists: assists,
      );

  /// Troca a lista de times; seleciona o primeiro (como o app antigo).
  PlayerFormData withTeams(List<TeamDTO> teams) => PlayerFormData(
        name: name,
        goals: goals,
        assists: assists,
        regions: regions,
        selectedRegion: selectedRegion,
        teams: teams,
        selectedTeam: teams.isEmpty ? null : teams.first.name,
        photo: photo,
      );

  /// Formulário limpo para o próximo cadastro, mantendo região, time e elenco.
  PlayerFormData cleared() => PlayerFormData(
        regions: regions,
        selectedRegion: selectedRegion,
        teams: teams,
        selectedTeam: selectedTeam,
        squad: squad,
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
  }) {
    return PlayerFormData(
      name: name ?? this.name,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      teams: teams,
      selectedTeam: selectedTeam ?? this.selectedTeam,
      photo: clearPhoto ? null : (photo ?? this.photo),
      squad: squad ?? this.squad,
    );
  }

  @override
  List<Object?> get props => [name, goals, assists, regions, selectedRegion, teams, selectedTeam, photo?.path, squad];
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
