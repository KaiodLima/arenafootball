import 'package:equatable/equatable.dart';

/// Tipo do lance no card ao vivo da partida.
enum LiveEventType {
  goal('gol'),
  yellow('amarelo'),
  red('vermelho'),
  substitution('substituicao');

  final String key;

  const LiveEventType(this.key);

  static LiveEventType fromKey(String? key) =>
      LiveEventType.values.where((t) => t.key == key).firstOrNull ?? LiveEventType.goal;
}

/// Lance resumido do card ao vivo (`noticias/aovivo_<idPartida>`: o
/// `ultimo_lance` e a lista `lances`). Lado `casa`/`fora`.
class LiveEvent extends Equatable {
  final String id;
  final LiveEventType type;
  final bool home;
  final int? minute;

  /// Gol: autor (e garçom); cartão: o atleta. Vazio = gol sem autor.
  final String player;
  final String playerId;
  final String assistant;

  /// Substituição: quem entra e quem sai.
  final String playerIn;
  final String playerInId;
  final String playerOut;

  /// Vermelho que veio do 2º amarelo.
  final bool secondYellow;

  const LiveEvent({
    required this.id,
    required this.type,
    required this.home,
    this.minute,
    this.player = '',
    this.playerId = '',
    this.assistant = '',
    this.playerIn = '',
    this.playerInId = '',
    this.playerOut = '',
    this.secondYellow = false,
  });

  factory LiveEvent.fromMap(Map<String, dynamic> data) {
    String text(String key) => data[key]?.toString() ?? '';
    return LiveEvent(
      id: text('id'),
      type: LiveEventType.fromKey(text('tipo')),
      home: text('lado') != 'fora',
      minute: (data['minuto'] as num?)?.toInt(),
      player: text('jogador'),
      playerId: text('jogador_id'),
      assistant: text('assistencia'),
      playerIn: text('entra'),
      playerInId: text('entra_id'),
      playerOut: text('sai'),
      secondYellow: data['segundo_amarelo'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': type.key,
        'lado': home ? 'casa' : 'fora',
        if (minute != null) 'minuto': minute,
        if (player.isNotEmpty) 'jogador': player,
        if (playerId.isNotEmpty) 'jogador_id': playerId,
        if (assistant.isNotEmpty) 'assistencia': assistant,
        if (playerIn.isNotEmpty) 'entra': playerIn,
        if (playerInId.isNotEmpty) 'entra_id': playerInId,
        if (playerOut.isNotEmpty) 'sai': playerOut,
        if (secondYellow) 'segundo_amarelo': true,
      };

  static List<LiveEvent> listFrom(Object? raw) => raw is List
      ? [
          for (final item in raw)
            if (item is Map) LiveEvent.fromMap(Map<String, dynamic>.from(item)),
        ]
      : const [];

  @override
  List<Object?> get props =>
      [id, type, home, minute, player, playerId, assistant, playerIn, playerInId, playerOut, secondYellow];
}
