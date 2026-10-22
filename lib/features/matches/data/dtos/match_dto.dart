import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';

/// Início/fim marcado na mão pelo admin (`status`); vale mais que o horário.
enum MatchManualStatus {
  none(''),
  live('andamento'),
  finished('encerrada');

  final String key;

  const MatchManualStatus(this.key);

  static MatchManualStatus fromKey(String? key) =>
      values.firstWhere((s) => s.key.isNotEmpty && s.key == key, orElse: () => none);
}

/// Documento das coleções `partidas` / `partidas{ano}`.
class MatchDTO extends Equatable {
  /// Campo com as regiões da partida entre regiões (consulta por região).
  static const String regionIdsField = 'idsRegioes';

  /// Campo com os gols da partida (autor e assistência).
  static const String goalsField = 'gols';

  /// Duração de partida sem o campo `duracao` (cadastros antigos).
  static const int defaultDurationMinutes = 90;

  /// Id do documento (gravado também em `id_partida`).
  final String id;

  /// Nomes dos times (cópia para exibir; o vínculo é pelos ids).
  final String homeTeam;
  final String awayTeam;

  /// `idTimeC` / `idTimeF`: ids dos times; vazios em partidas antigas (antes
  /// da migração), quando vale o nome.
  final String homeTeamId;
  final String awayTeamId;

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

  /// `idsRegioes`: regiões dos dois times quando são de regiões diferentes
  /// (campeonato intermunicipal): a partida aparece na aba TABELAS das duas.
  final List<String> regionIds;

  /// `gols`: os gols com autor/assistência (vazio em partidas antigas: o
  /// placar fica só em [homeGoals]/[awayGoals]).
  final List<MatchGoal> goals;

  /// `duracao` em minutos: o fim é o horário + a duração.
  final int durationMinutes;

  /// `status`: iniciada/encerrada na mão pelo admin.
  final MatchManualStatus manualStatus;

  const MatchDTO({
    this.id = '',
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamId = '',
    this.awayTeamId = '',
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
    this.regionIds = const [],
    this.goals = const [],
    this.durationMinutes = defaultDurationMinutes,
    this.manualStatus = MatchManualStatus.none,
  });

  static int _int(Object? value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  factory MatchDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final registeredAt = data['dataRegistro'];
    return MatchDTO(
      // Edição e exclusão sempre pelo id do documento.
      id: doc.id,
      homeTeam: data['timeC']?.toString() ?? '',
      awayTeam: data['timeF']?.toString() ?? '',
      homeTeamId: data['idTimeC']?.toString() ?? '',
      awayTeamId: data['idTimeF']?.toString() ?? '',
      date: data['data']?.toString() ?? '',
      time: data['horario']?.toString() ?? '',
      venue: data['local']?.toString() ?? '',
      championshipId: _int(data['id_campeonato']),
      region: RegionRegistry.nameFromDoc(data),
      homeGoals: _int(data['golTimeCasa']),
      awayGoals: _int(data['golTimeFora']),
      isVotingOpen: data['votacao'] == 'true',
      votingTitle: data['tituloVotacao']?.toString() ?? '',
      bestPlayer: data['melhorJogador']?.toString() ?? '',
      votesCount: data['quantidadeVotos']?.toString() ?? '',
      registeredAt: registeredAt is Timestamp ? registeredAt.toDate() : null,
      regionIds: (data[regionIdsField] as List?)?.map((id) => id.toString()).toList() ?? const [],
      goals: MatchGoal.listFrom(data[goalsField]),
      durationMinutes: _int(data['duracao']) > 0 ? _int(data['duracao']) : defaultDurationMinutes,
      manualStatus: MatchManualStatus.fromKey(data['status']?.toString()),
    );
  }

  /// Documento completo. `dataRegistro` só entra quando conhecido (no
  /// cadastro o DataSource grava o horário do servidor).
  Map<String, dynamic> toMap() => {
        'id_partida': id,
        'timeC': homeTeam,
        'timeF': awayTeam,
        'idTimeC': homeTeamId,
        'idTimeF': awayTeamId,
        'data': date,
        'horario': time,
        'local': venue,
        'id_campeonato': championshipId,
        ...RegionRegistry.fieldsFor(region),
        'golTimeCasa': homeGoals,
        'golTimeFora': awayGoals,
        'votacao': isVotingOpen.toString(),
        'tituloVotacao': votingTitle,
        'melhorJogador': bestPlayer,
        'quantidadeVotos': votesCount,
        if (registeredAt != null) 'dataRegistro': Timestamp.fromDate(registeredAt!),
        if (regionIds.isNotEmpty) regionIdsField: regionIds,
        if (goals.isNotEmpty) goalsField: [for (final g in goals) g.toMap()],
        'duracao': durationMinutes,
        if (manualStatus != MatchManualStatus.none) 'status': manualStatus.key,
      };

  MatchDTO copyWith({
    String? id,
    String? homeTeam,
    String? awayTeam,
    String? homeTeamId,
    String? awayTeamId,
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
    List<String>? regionIds,
    List<MatchGoal>? goals,
    int? durationMinutes,
    MatchManualStatus? manualStatus,
  }) {
    return MatchDTO(
      id: id ?? this.id,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
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
      regionIds: regionIds ?? this.regionIds,
      goals: goals ?? this.goals,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      manualStatus: manualStatus ?? this.manualStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        homeTeam,
        awayTeam,
        homeTeamId,
        awayTeamId,
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
        regionIds,
        goals,
        durationMinutes,
        manualStatus,
      ];
}
