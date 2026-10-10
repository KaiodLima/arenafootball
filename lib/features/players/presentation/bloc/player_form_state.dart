import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Erro de validação do formulário, traduzido na página via l10n.
enum PlayerFormError { name, team }

/// Dados do formulário de jogador. Sobrevive às transições
/// Editing → Submitting → Error/Success.
class PlayerFormData extends Equatable {
  final String name;
  final String goals;
  final String assists;
  final List<String> regions;
  final String? selectedRegion;

  /// Nomes dos times da região selecionada (temporada corrente).
  final List<String> teams;
  final String? selectedTeam;

  const PlayerFormData({
    this.name = '',
    this.goals = '',
    this.assists = '',
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.selectedTeam,
  });

  /// Regras do app antigo: nome com no mínimo 3 caracteres e time escolhido.
  PlayerFormError? get error {
    if (name.trim().length < 3) return PlayerFormError.name;
    if (selectedTeam == null || selectedTeam!.isEmpty) return PlayerFormError.team;
    return null;
  }

  /// Gols/assistências vazios ou inválidos contam como zero.
  PlayerDTO toPlayer() => PlayerDTO(
        name: name.trim(),
        team: selectedTeam ?? '',
        goals: int.tryParse(goals.trim()) ?? 0,
        assists: int.tryParse(assists.trim()) ?? 0,
      );

  /// Troca a lista de times; seleciona o primeiro (como o app antigo).
  PlayerFormData withTeams(List<String> teams) => PlayerFormData(
        name: name,
        goals: goals,
        assists: assists,
        regions: regions,
        selectedRegion: selectedRegion,
        teams: teams,
        selectedTeam: teams.isEmpty ? null : teams.first,
      );

  /// Formulário limpo para o próximo cadastro, mantendo região e time.
  PlayerFormData cleared() =>
      PlayerFormData(regions: regions, selectedRegion: selectedRegion, teams: teams, selectedTeam: selectedTeam);

  PlayerFormData copyWith({
    String? name,
    String? goals,
    String? assists,
    List<String>? regions,
    String? selectedRegion,
    String? selectedTeam,
  }) {
    return PlayerFormData(
      name: name ?? this.name,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      teams: teams,
      selectedTeam: selectedTeam ?? this.selectedTeam,
    );
  }

  @override
  List<Object?> get props => [name, goals, assists, regions, selectedRegion, teams, selectedTeam];
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
