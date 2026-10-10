import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Documento das coleções `partidas` / `partidas{ano}`.
class MatchDTO extends Equatable {
  /// Id do documento (gravado também em `id_partida`).
  final String id;
  final String homeTeam;
  final String awayTeam;

  /// Data no formato "dd/MM" digitado pelo admin (é texto, não Timestamp).
  final String date;
  final String time;
  final String venue;

  /// `id_campeonato`: número do campeonato da região.
  final int championshipId;
  final String region;
  final int homeGoals;
  final int awayGoals;

  /// `votacao`: gravado como string "true"/"false".
  final bool isVotingOpen;
  final String votingTitle;
  final String bestPlayer;

  /// `quantidadeVotos`: gravado como string.
  final String votesCount;

  /// `dataRegistro`: momento do cadastro (ordenação da lista).
  final DateTime? registeredAt;

  const MatchDTO({
    this.id = '',
    required this.homeTeam,
    required this.awayTeam,
    this.date = '',
    this.time = '',
    this.venue = '',
    this.championshipId = 0,
    this.region = '',
    this.homeGoals = 0,
    this.awayGoals = 0,
    this.isVotingOpen = false,
    this.votingTitle = '',
    this.bestPlayer = '',
    this.votesCount = '',
    this.registeredAt,
  });

  static int _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  factory MatchDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final registeredAt = data['dataRegistro'];
    return MatchDTO(
      // Edição e exclusão sempre pelo id do documento.
      id: doc.id,
      homeTeam: data['timeC']?.toString() ?? '',
      awayTeam: data['timeF']?.toString() ?? '',
      date: data['data']?.toString() ?? '',
      time: data['horario']?.toString() ?? '',
      venue: data['local']?.toString() ?? '',
      championshipId: _int(data['id_campeonato']),
      region: data['fk_competicao']?.toString() ?? '',
      homeGoals: _int(data['golTimeCasa']),
      awayGoals: _int(data['golTimeFora']),
      isVotingOpen: data['votacao'] == 'true',
      votingTitle: data['tituloVotacao']?.toString() ?? '',
      bestPlayer: data['melhorJogador']?.toString() ?? '',
      votesCount: data['quantidadeVotos']?.toString() ?? '',
      registeredAt: registeredAt is Timestamp ? registeredAt.toDate() : null,
    );
  }

  /// Documento completo. `dataRegistro` só entra quando conhecido (no
  /// cadastro o DataSource grava o horário do servidor).
  Map<String, dynamic> toMap() => {
        'id_partida': id,
        'timeC': homeTeam,
        'timeF': awayTeam,
        'data': date,
        'horario': time,
        'local': venue,
        'id_campeonato': championshipId,
        'fk_competicao': region,
        'golTimeCasa': homeGoals,
        'golTimeFora': awayGoals,
        'votacao': isVotingOpen.toString(),
        'tituloVotacao': votingTitle,
        'melhorJogador': bestPlayer,
        'quantidadeVotos': votesCount,
        if (registeredAt != null) 'dataRegistro': Timestamp.fromDate(registeredAt!),
      };

  MatchDTO copyWith({
    String? id,
    String? homeTeam,
    String? awayTeam,
    String? date,
    String? time,
    String? venue,
    int? championshipId,
    String? region,
    int? homeGoals,
    int? awayGoals,
    bool? isVotingOpen,
    String? votingTitle,
    String? bestPlayer,
    String? votesCount,
    DateTime? registeredAt,
  }) {
    return MatchDTO(
      id: id ?? this.id,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      championshipId: championshipId ?? this.championshipId,
      region: region ?? this.region,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
      isVotingOpen: isVotingOpen ?? this.isVotingOpen,
      votingTitle: votingTitle ?? this.votingTitle,
      bestPlayer: bestPlayer ?? this.bestPlayer,
      votesCount: votesCount ?? this.votesCount,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        homeTeam,
        awayTeam,
        date,
        time,
        venue,
        championshipId,
        region,
        homeGoals,
        awayGoals,
        isVotingOpen,
        votingTitle,
        bestPlayer,
        votesCount,
        registeredAt,
      ];
}
