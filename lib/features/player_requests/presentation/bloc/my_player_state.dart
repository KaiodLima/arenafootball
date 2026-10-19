import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Atleta da conta logada (e o pedido "Sou jogador" dela). Diz por quais
/// times ela joga: pelo atleta, que pode estar em vários times (um por
/// competição); um pedido novo pendente não tira o time já aprovado.
class MyPlayerState extends Equatable {
  final PlayerDTO? player;
  final PlayerRequestDTO? request;

  const MyPlayerState({this.player, this.request});

  bool get _approved => request != null && request!.status == PlayerRequestStatus.approved;

  /// Times do atleta (vazio se não joga por nenhum).
  List<String> get teamNames {
    final names = player?.teamNames ?? const <String>[];
    if (names.isNotEmpty) return names;
    // Atleta ainda não lido (ou pedido de antes do vínculo pelo atleta).
    return _approved && request!.team.isNotEmpty ? [request!.team] : const [];
  }

  /// "Lava Jato" ou "Lava Jato e Volta" (nulo se não é jogador de nenhum).
  String? get teamName => teamNames.isEmpty ? null : teamNames.join(' e ');

  /// Id do time principal ('' se não é jogador ou time antigo sem id).
  String get teamId {
    if (teamName == null) return '';
    final p = player;
    if (p != null) return p.teamId;
    return request!.teamId;
  }

  /// Atleta da conta (para abrir o perfil).
  String? get playerId {
    if (player != null && teamNames.isNotEmpty) return player!.id;
    return _approved && request!.playerId.isNotEmpty ? request!.playerId : null;
  }

  /// Temporada do atleta (o perfil abre na coleção dela).
  String? get season {
    if (player != null && teamNames.isNotEmpty) return SeasonCollection.currentSeason;
    return _approved && request!.season.isNotEmpty ? request!.season : null;
  }

  @override
  List<Object?> get props => [player, request];
}
