import 'package:equatable/equatable.dart';

/// Fase eliminatória da partida (`fase` em `partidas{ano}`).
enum MatchStage {
  roundOf16('oitavas'),
  quarterFinal('quartas'),
  semiFinal('semifinal'),
  thirdPlace('terceiro'),
  finalMatch('final'),
  other('outra');

  final String key;

  const MatchStage(this.key);

  static MatchStage? fromKey(Object? key) {
    for (final stage in values) {
      if (stage.key == key) return stage;
    }
    return null;
  }
}

/// Fase da partida: um grupo do campeonato (conta na tabela dele) ou o
/// mata-mata (não conta em grupo nenhum; selo da fase). Partida sem fase
/// (antiga) não tem [MatchRound]: as functions seguem a regra implícita.
class MatchRound extends Equatable {
  static const String groupIdField = 'idGrupo';
  static const String groupNameField = 'grupo';
  static const String outsideGroupsField = 'foraDosGrupos';
  static const String stageField = 'fase';

  /// Doc do grupo (`grupos{ano}`); vazio no mata-mata.
  final String groupId;

  /// Nome do grupo (cópia para exibir).
  final String groupName;

  /// Fase eliminatória; nula na fase de grupos.
  final MatchStage? stage;

  const MatchRound.group({required this.groupId, required this.groupName}) : stage = null;

  const MatchRound.knockout(MatchStage this.stage)
      : groupId = '',
        groupName = '';

  bool get isGroup => stage == null && groupId.isNotEmpty;

  bool get isKnockout => stage != null;

  /// Lido do doc da partida; nulo sem os campos.
  static MatchRound? fromMap(Map<String, dynamic> data) {
    if (data[outsideGroupsField] == true) {
      return MatchRound.knockout(MatchStage.fromKey(data[stageField]) ?? MatchStage.other);
    }
    final groupId = data[groupIdField]?.toString() ?? '';
    if (groupId.isEmpty) return null;
    return MatchRound.group(groupId: groupId, groupName: data[groupNameField]?.toString() ?? '');
  }

  /// Campos gravados no cadastro.
  Map<String, Object> toMap() => isKnockout
      ? {outsideGroupsField: true, stageField: stage!.key}
      : {groupIdField: groupId, groupNameField: groupName};

  @override
  List<Object?> get props => [groupId, groupName, stage];
}
