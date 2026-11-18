import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';

DateTime? _dateOf(Object? value) => value is Timestamp ? value.toDate() : (value is DateTime ? value : null);

/// Rodada do Fantasy (`fantasy/{id}/rodadas/{n}`, só as functions gravam).
class FantasyRoundDTO extends Equatable {
  final int number;
  final List<String> matchIds;
  final DateTime? closesAt;

  /// `aberta`, `fechada` ou `vazia` (sem partidas).
  final String status;

  const FantasyRoundDTO({required this.number, this.matchIds = const [], this.closesAt, this.status = ''});

  factory FantasyRoundDTO.fromMap(String id, Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};
    return FantasyRoundDTO(
      number: (map['numero'] as num?)?.toInt() ?? int.tryParse(id) ?? 0,
      matchIds: (map['idsPartidas'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      closesAt: _dateOf(map['fechaEm']),
      status: map['status']?.toString() ?? '',
    );
  }

  /// Ainda dá para montar/trocar a escalação.
  bool isOpenAt(DateTime now) => status == 'aberta' && closesAt != null && now.isBefore(closesAt!);

  @override
  List<Object?> get props => [number, matchIds, closesAt, status];
}

/// Participante do Fantasy (`fantasy/{id}/participantes/{uid}`).
class FantasyParticipantDTO extends Equatable {
  final String uid;
  final String name;
  final String photoUrl;
  final int firstRound;

  /// Pontos acumulados (só as functions gravam).
  final double points;

  const FantasyParticipantDTO({
    required this.uid,
    this.name = '',
    this.photoUrl = '',
    this.firstRound = 0,
    this.points = 0,
  });

  factory FantasyParticipantDTO.fromMap(String id, Map<String, dynamic> data) => FantasyParticipantDTO(
        uid: id,
        name: data['nome']?.toString() ?? '',
        photoUrl: data['urlImagem']?.toString() ?? '',
        firstRound: (data['rodadaInicial'] as num?)?.toInt() ?? 0,
        points: (data['pontos'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [uid, name, photoUrl, firstRound, points];
}

/// Escalação do participante na rodada (`rodadas/{n}/escalacoes/{uid}`).
class FantasyLineupDTO extends Equatable {
  final String uid;
  final String name;
  final String photoUrl;
  final FantasyLineup lineup;

  /// Cópia automática da rodada anterior (o dono troca até o prazo).
  final bool copied;

  const FantasyLineupDTO({
    required this.uid,
    this.name = '',
    this.photoUrl = '',
    this.lineup = const FantasyLineup(),
    this.copied = false,
  });

  factory FantasyLineupDTO.fromMap(String id, Map<String, dynamic> data) {
    final raw = (data['atletas'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? const {};
    final athletes = <FantasySlot, String>{
      for (final entry in raw.entries)
        if (FantasySlot.fromKey(entry.key) != null && entry.value.isNotEmpty)
          FantasySlot.fromKey(entry.key)!: entry.value,
    };
    return FantasyLineupDTO(
      uid: id,
      name: data['nome']?.toString() ?? '',
      photoUrl: data['urlImagem']?.toString() ?? '',
      lineup: FantasyLineup(athletes: athletes, captainId: data['capitao']?.toString() ?? ''),
      copied: data['copiada'] == true,
    );
  }

  /// O que o dono grava (sem `atualizadoEm`, posto pelo data source). Salvar
  /// tira a marca de cópia.
  Map<String, dynamic> toOwnerMap() => {
        'uid': uid,
        'nome': name,
        'urlImagem': photoUrl,
        'atletas': {for (final slot in FantasySlot.values) slot.key: lineup.idAt(slot) ?? ''},
        'idsAtletas': lineup.ids,
        'capitao': lineup.captainId,
        'copiada': false,
      };

  @override
  List<Object?> get props => [uid, name, photoUrl, lineup, copied];
}
