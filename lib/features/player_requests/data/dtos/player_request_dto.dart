import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Situação do pedido. A chave é o valor gravado em `status`.
enum PlayerRequestStatus {
  pending('pendente'),
  approved('aprovada'),
  rejected('rejeitada'),

  /// Estava aprovado e o admin tirou do elenco (o atleta e os números ficam).
  removed('removido');

  final String key;

  const PlayerRequestStatus(this.key);

  static PlayerRequestStatus fromKey(String? key) {
    for (final status in values) {
      if (status.key == key) return status;
    }
    return pending;
  }
}

/// Posição em campo. A chave é o valor gravado em `posicao` (pedido e jogador).
enum PlayerPosition {
  goalkeeper('goleiro'),
  defender('zagueiro'),
  fullBack('lateral'),
  midfielder('meia'),
  forward('atacante');

  final String key;

  const PlayerPosition(this.key);

  static PlayerPosition? fromKey(String? key) {
    for (final position in values) {
      if (position.key == key) return position;
    }
    return null;
  }
}

/// Documento de `solicitacoes_jogador/{uid}`: pedido de um usuário para
/// entrar no elenco de um time. Um por usuário (id do doc = uid).
class PlayerRequestDTO extends Equatable {
  /// uid de quem pediu (também é o id do documento).
  final String userId;
  final String userName;
  final String email;

  /// Nome de jogador (pode ser apelido).
  final String name;

  /// Nome do time (cópia para exibir).
  final String team;

  /// `idTime`: id do time pedido; vazio em pedidos antigos (vale o nome).
  final String teamId;
  final String region;
  final String season;
  final PlayerPosition? position;
  final String message;
  final String imageUrl;
  final PlayerRequestStatus status;

  /// Motivo da rejeição (opcional).
  final String reason;

  /// Jogador criado na aprovação.
  final String playerId;
  final DateTime? createdAt;

  const PlayerRequestDTO({
    required this.userId,
    this.userName = '',
    this.email = '',
    required this.name,
    required this.team,
    this.teamId = '',
    required this.region,
    required this.season,
    this.position,
    this.message = '',
    this.imageUrl = '',
    this.status = PlayerRequestStatus.pending,
    this.reason = '',
    this.playerId = '',
    this.createdAt,
  });

  bool get isPending => status == PlayerRequestStatus.pending;

  factory PlayerRequestDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    String text(String key) => data[key]?.toString() ?? '';
    return PlayerRequestDTO(
      userId: doc.id,
      userName: text('nome_usuario'),
      email: text('email'),
      name: text('nome'),
      team: text('time'),
      teamId: text('idTime'),
      region: text('regiao'),
      season: text('temporada'),
      position: PlayerPosition.fromKey(text('posicao')),
      message: text('mensagem'),
      imageUrl: text('urlImagem'),
      status: PlayerRequestStatus.fromKey(text('status')),
      reason: text('motivo'),
      playerId: text('idJogador'),
      // Escrita local ainda sem o horário do servidor: fica nulo até confirmar.
      createdAt: (data['data'] as Timestamp?)?.toDate(),
    );
  }

  /// Campos que o próprio usuário grava ao enviar (as regras aceitam só estes).
  Map<String, dynamic> toSubmitMap() => {
        'uid': userId,
        'nome_usuario': userName,
        'email': email,
        'nome': name,
        'time': team,
        'idTime': teamId,
        'regiao': region,
        'temporada': season,
        'posicao': position?.key ?? '',
        'mensagem': message,
        'urlImagem': imageUrl,
        'status': PlayerRequestStatus.pending.key,
      };

  PlayerRequestDTO copyWith({
    String? name,
    String? team,
    String? teamId,
    String? region,
    String? season,
    PlayerPosition? position,
    String? message,
    String? imageUrl,
    PlayerRequestStatus? status,
    String? reason,
    String? playerId,
  }) {
    return PlayerRequestDTO(
      userId: userId,
      userName: userName,
      email: email,
      name: name ?? this.name,
      team: team ?? this.team,
      teamId: teamId ?? this.teamId,
      region: region ?? this.region,
      season: season ?? this.season,
      position: position ?? this.position,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      playerId: playerId ?? this.playerId,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        email,
        name,
        team,
        teamId,
        region,
        season,
        position,
        message,
        imageUrl,
        status,
        reason,
        playerId,
        createdAt,
      ];
}
