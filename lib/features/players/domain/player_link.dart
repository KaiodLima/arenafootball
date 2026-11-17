import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

/// Situação do atleta numa competição do time de destino.
enum LinkSlot {
  /// Ainda não joga: pode inscrever.
  free,

  /// Já joga por este time.
  joined,

  /// Joga por outro time: só com "Transferir" (os números da competição ficam).
  otherTeam,
}

/// Filtro da busca do "Vincular atleta" pela conta de usuário.
enum LinkAccountFilter { all, withAccount, withoutAccount }

/// O que gravar ao vincular o atleta [player] ao time [teamId]/[team] (admin).
///
/// - [selected]: competições do time em que ele vai jogar; as que ele já joga
///   por outro time só entram com [transfers].
/// - Sem time principal, ou sem nenhuma competição escolhida, o time vira o
///   principal (senão o atleta não aparece no elenco geral); com time, só
///   com [makeMain].
/// - Atleta antigo (sem `inscricoes`, conta em todas as competições do time
///   principal): ao ganhar a 1ª inscrição real, as implícitas do time antigo
///   ([legacyChampionships]) viram reais, para ele não sumir de lá.
class PlayerLinkPlan extends Equatable {
  /// Inscrições a gravar (novas e transferidas; os números ficam como estão).
  final List<PlayerEnrollment> upserts;

  /// Grava o time de destino como principal (`time`/`idTime`).
  final bool setMain;

  /// `idsTimes` depois do vínculo.
  final List<String> teamIds;

  const PlayerLinkPlan({required this.upserts, required this.setMain, required this.teamIds});

  bool get isEmpty => upserts.isEmpty && !setMain;

  /// Situação do atleta em cada competição do time (pela inscrição real).
  static LinkSlot slotOf(PlayerDTO player, int championshipId, {required String teamId, required String team}) {
    if (player.playsIn(championshipId, teamId: teamId, teamName: team)) return LinkSlot.joined;
    final enrollment = player.enrollmentIn(championshipId);
    if (enrollment == null) return LinkSlot.free;
    return LinkSlot.otherTeam;
  }

  /// Candidatos da busca: sem os que já jogam pelo time, pela [query] (sem
  /// acento) e pela conta; sem time primeiro, depois pelo nome.
  static List<PlayerDTO> filterCandidates(
    List<PlayerDTO> candidates, {
    required String teamId,
    required String team,
    String query = '',
    LinkAccountFilter account = LinkAccountFilter.all,
  }) {
    final folded = foldForSearch(query.trim());
    return candidates
        .where((p) => !p.playsFor(teamId: teamId, teamName: team))
        .where((p) => folded.isEmpty || foldForSearch(p.name).contains(folded))
        .where((p) => switch (account) {
              LinkAccountFilter.all => true,
              LinkAccountFilter.withAccount => p.userId.isNotEmpty,
              LinkAccountFilter.withoutAccount => p.userId.isEmpty,
            })
        .toList()
      ..sort((a, b) {
        final aNoTeam = a.team.trim().isEmpty ? 0 : 1;
        final bNoTeam = b.team.trim().isEmpty ? 0 : 1;
        if (aNoTeam != bNoTeam) return aNoTeam.compareTo(bNoTeam);
        return foldForSearch(a.name).compareTo(foldForSearch(b.name));
      });
  }

  factory PlayerLinkPlan.of(
    PlayerDTO player, {
    required String teamId,
    required String team,
    Set<int> selected = const {},
    Set<int> transfers = const {},
    bool makeMain = false,
    List<int> legacyChampionships = const [],
  }) {
    bool isThisTeam(String id, String name) => sameTeam(idA: id, nameA: name, idB: teamId, nameB: team);
    final upserts = <PlayerEnrollment>[];
    for (final id in selected) {
      final enrollment = player.enrollmentIn(id);
      if (enrollment != null && isThisTeam(enrollment.teamId, enrollment.team)) continue;
      if (enrollment != null && !transfers.contains(id)) continue;
      upserts.add(PlayerEnrollment(championshipId: id, teamId: teamId, team: team));
    }
    // Atleta antigo ganhando inscrições: as implícitas do time principal ficam reais.
    if (player.isLegacy && upserts.isNotEmpty && player.teamId.isNotEmpty && !isThisTeam(player.teamId, player.team)) {
      for (final id in legacyChampionships) {
        if (upserts.any((e) => e.championshipId == id)) continue;
        upserts.add(PlayerEnrollment(championshipId: id, teamId: player.teamId, team: player.team));
      }
    }
    final noMain = player.team.trim().isEmpty && player.teamId.isEmpty;
    final alreadyMain = isThisTeam(player.teamId, player.team);
    final setMain = !alreadyMain && (makeMain || noMain || selected.isEmpty);
    final mainId = setMain ? teamId : player.teamId;
    final changed = {for (final e in upserts) e.championshipId};
    final teamIds = {
      if (mainId.isNotEmpty) mainId,
      for (final e in player.enrollments)
        if (!changed.contains(e.championshipId) && e.teamId.isNotEmpty) e.teamId,
      for (final e in upserts)
        if (e.teamId.isNotEmpty) e.teamId,
    }.toList();
    return PlayerLinkPlan(upserts: upserts, setMain: setMain, teamIds: teamIds);
  }

  @override
  List<Object?> get props => [upserts, setMain, teamIds];
}
