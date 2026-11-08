import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';

/// Quem gerencia a partida (engrenagem: súmula, etapas, "Atrasou", placar,
/// card de gol, votação): o admin, em qualquer partida; o organizador, nas das
/// competições dele (`id_campeonato` entre [organizerChampionshipIds]).
/// Apagar a partida segue só com o admin.
bool canManageMatch(MatchDTO match, {required bool isAdmin, required Iterable<int> organizerChampionshipIds}) =>
    isAdmin || (match.championshipId > 0 && organizerChampionshipIds.contains(match.championshipId));
