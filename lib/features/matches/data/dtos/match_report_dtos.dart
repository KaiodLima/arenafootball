import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';

/// Tipo do cartão.
enum BookingType {
  yellow('amarelo'),
  red('vermelho');

  final String key;

  const BookingType(this.key);

  static BookingType fromKey(String? key) => key == red.key ? red : yellow;
}

/// Cartão da súmula (`partidas{ano}.cartoes[]`): lado, atleta, tipo e minuto.
/// [secondYellow]: o vermelho que veio do 2º amarelo.
class MatchBooking extends Equatable {
  final String id;
  final MatchSide side;
  final BookingType type;
  final String playerId;
  final String playerName;
  final int? minute;
  final bool secondYellow;

  const MatchBooking({
    required this.id,
    required this.side,
    required this.type,
    this.playerId = '',
    this.playerName = '',
    this.minute,
    this.secondYellow = false,
  });

  static final Random _random = Random();

  static String newId() =>
      'c${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_random.nextInt(1 << 20).toRadixString(36)}';

  factory MatchBooking.fromMap(Map<String, dynamic> data) {
    String text(String key) => data[key]?.toString() ?? '';
    return MatchBooking(
      id: text('id'),
      side: MatchSide.fromKey(text('lado')),
      type: BookingType.fromKey(text('tipo')),
      playerId: text('idJogador'),
      playerName: text('jogador'),
      minute: (data['minuto'] as num?)?.toInt(),
      secondYellow: data['segundoAmarelo'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'lado': side.key,
        'tipo': type.key,
        'idJogador': playerId,
        'jogador': playerName,
        if (minute != null) 'minuto': minute,
        if (secondYellow) 'segundoAmarelo': true,
      };

  static List<MatchBooking> listFrom(Object? raw) => raw is List
      ? [
          for (final item in raw)
            if (item is Map) MatchBooking.fromMap(Map<String, dynamic>.from(item)),
        ]
      : const [];

  @override
  List<Object?> get props => [id, side, type, playerId, playerName, minute, secondYellow];
}

/// Atleta relacionado para a partida (`partidas{ano}.escalacao.casa|fora[]`).
class LineupEntry extends Equatable {
  final String playerId;
  final String playerName;
  final bool starter;

  /// Número da camisa (nulo = sem número).
  final int? number;

  const LineupEntry({required this.playerId, required this.playerName, this.starter = true, this.number});

  factory LineupEntry.fromMap(Map<String, dynamic> data) => LineupEntry(
        playerId: data['idJogador']?.toString() ?? '',
        playerName: data['jogador']?.toString() ?? '',
        starter: data['titular'] != false,
        number: (data['numero'] as num?)?.toInt(),
      );

  Map<String, dynamic> toMap() => {
        'idJogador': playerId,
        'jogador': playerName,
        'titular': starter,
        if (number != null) 'numero': number,
      };

  LineupEntry copyWith({bool? starter, int? Function()? number}) => LineupEntry(
        playerId: playerId,
        playerName: playerName,
        starter: starter ?? this.starter,
        number: number != null ? number() : this.number,
      );

  @override
  List<Object?> get props => [playerId, playerName, starter, number];
}

/// Escalação dos dois lados (vazia = não lançada: o detalhe mostra o elenco).
class MatchLineup extends Equatable {
  final List<LineupEntry> home;
  final List<LineupEntry> away;

  const MatchLineup({this.home = const [], this.away = const []});

  bool get isEmpty => home.isEmpty && away.isEmpty;

  List<LineupEntry> of(MatchSide side) => side == MatchSide.home ? home : away;

  MatchLineup withSide(MatchSide side, List<LineupEntry> entries) =>
      side == MatchSide.home ? MatchLineup(home: entries, away: away) : MatchLineup(home: home, away: entries);

  static List<LineupEntry> _list(Object? raw) => raw is List
      ? [
          for (final item in raw)
            if (item is Map) LineupEntry.fromMap(Map<String, dynamic>.from(item)),
        ]
      : const [];

  factory MatchLineup.fromMap(Object? raw) {
    if (raw is! Map) return const MatchLineup();
    return MatchLineup(home: _list(raw[MatchSide.home.key]), away: _list(raw[MatchSide.away.key]));
  }

  Map<String, dynamic> toMap() => {
        MatchSide.home.key: [for (final e in home) e.toMap()],
        MatchSide.away.key: [for (final e in away) e.toMap()],
      };

  @override
  List<Object?> get props => [home, away];
}
