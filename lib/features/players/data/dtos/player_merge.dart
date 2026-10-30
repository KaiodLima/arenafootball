import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

/// Atleta inscrito numa competição por um time e pedido por outro: na mesma
/// temporada, um atleta joga por um time só em cada competição.
typedef EnrollmentConflict = ({int championshipId, String currentTeam, String otherTeam});

/// Junta dois cadastros da mesma pessoa na temporada (a conta já tinha um
/// atleta e reivindicou outro) seguindo as inscrições por competição: cada
/// competição fica com o seu time e os seus números.
class PlayerMerge {
  const PlayerMerge._();

  /// Conflito ao inscrever [player] em [championshipId] pelo time
  /// [teamId]/[team]: já inscrito ali por **outro** time. Só as inscrições
  /// reais contam (a implícita do atleta antigo não bloqueia).
  static EnrollmentConflict? conflictIn(PlayerDTO player, int championshipId, String teamId, String team) {
    for (final e in player.enrollments) {
      if (e.championshipId != championshipId) continue;
      if (sameTeam(idA: e.teamId, nameA: e.team, idB: teamId, nameB: team)) return null;
      return (championshipId: championshipId, currentTeam: e.team, otherTeam: team);
    }
    return null;
  }

  /// [target] (o que fica, com a conta) recebe o [source] (o que some):
  /// inscrições do [source] que o [target] não tem entram com o time e os
  /// números delas; na mesma competição pelo mesmo time os números somam; por
  /// times diferentes = conflito (nada é juntado). Geral e amistosos somam.
  static ({PlayerDTO? merged, EnrollmentConflict? conflict}) merge({
    required PlayerDTO target,
    required PlayerDTO source,
  }) {
    final byId = {for (final e in target.enrollments) e.championshipId: e};
    for (final e in source.enrollments) {
      final current = byId[e.championshipId];
      if (current == null) {
        byId[e.championshipId] = e;
      } else if (sameTeam(idA: current.teamId, nameA: current.team, idB: e.teamId, nameB: e.team)) {
        byId[e.championshipId] = current.copyWith(goals: current.goals + e.goals, assists: current.assists + e.assists);
      } else {
        return (
          merged: null,
          conflict: (championshipId: e.championshipId, currentTeam: current.team, otherTeam: e.team),
        );
      }
    }
    final enrollments = byId.values.toList()..sort((a, b) => a.championshipId.compareTo(b.championshipId));
    final legacy = target.isLegacy && source.isLegacy;
    return (
      merged: target.copyWith(
        goals: target.goals + source.goals,
        assists: target.assists + source.assists,
        friendlyGoals: target.friendlyGoals + source.friendlyGoals,
        friendlyAssists: target.friendlyAssists + source.friendlyAssists,
        enrollments: enrollments,
        hasEnrollmentField: !legacy,
      ),
      conflict: null,
    );
  }

  /// Acrescenta a inscrição [enrollment] (sem números) se o atleta ainda não
  /// está nessa competição; já inscrito (pelo mesmo time) = igual.
  static PlayerDTO withEnrollment(PlayerDTO player, PlayerEnrollment enrollment) {
    if (player.enrollments.any((e) => e.championshipId == enrollment.championshipId)) return player;
    final enrollments = [...player.enrollments, enrollment.copyWith(goals: 0, assists: 0)]
      ..sort((a, b) => a.championshipId.compareTo(b.championshipId));
    return player.copyWith(enrollments: enrollments, hasEnrollmentField: true);
  }

  /// Lista `gols` de uma partida com o atleta [from] trocado por [to] (autor
  /// e assistência), mantendo os outros campos; nula se nada muda.
  static List<Map<String, dynamic>>? repointGoals(Object? raw, String from, String to) {
    if (raw is! List || from.isEmpty) return null;
    var changed = false;
    final list = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final goal = Map<String, dynamic>.from(item);
      for (final field in const ['idJogador', 'idAssistencia']) {
        if (goal[field]?.toString() == from) {
          goal[field] = to;
          changed = true;
        }
      }
      list.add(goal);
    }
    return changed ? list : null;
  }
}
