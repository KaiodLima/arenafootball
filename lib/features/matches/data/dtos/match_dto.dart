import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';

/// Início/fim marcado na mão pelo admin (`status`); vale mais que o horário.
enum MatchManualStatus {
  none(''),
  live('andamento'),

  /// Intervalo marcado pelo admin: relógio parado entre os tempos.
  halfTime('intervalo'),
  finished('encerrada'),

  /// Atrasou sem horário novo: pausada até o admin iniciar (sem relógio).
  waiting('aguardando');

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
  /// Campo do craque eleito (mapa {nome, idJogador, idTime, votos, percentual}).
  static const String electedField = 'craque';

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

  /// `horarioOriginal`: o 1º horário cadastrado, gravado quando o admin
  /// atrasa a partida ("Atrasou"); vazio = nunca atrasou.
  final String originalTime;
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

  /// `craque`: eleito pelos votos, gravado pelas functions quando a votação
  /// fecha (id em `jogadores{ano}` e nome); vazio = sem eleito ou antiga.
  final String electedPlayerId;
  final String electedPlayerName;

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

  /// Relógio de jogo (hora do servidor das ações do admin): `inicioEm`
  /// (iniciou), `intervaloEm` (intervalo), `segundoTempoEm` (2º tempo) e
  /// `statusEm` (última mudança; início das partidas antigas sem `inicioEm`).
  final DateTime? startedAt;
  final DateTime? halfTimeAt;
  final DateTime? secondHalfAt;
  final DateTime? statusAt;

  /// Súmula: cartões (`cartoes`), escalação (`escalacao`), árbitro
  /// (`arbitro`) e observações (`observacoes`); vazios em partidas sem súmula.
  final List<MatchBooking> bookings;
  final MatchLineup lineup;
  final String referee;
  final String notes;

  const MatchDTO({
    this.id = '',
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamId = '',
    this.awayTeamId = '',
    this.date = '',
    this.time = '',
    this.originalTime = '',
    this.venue = '',
    this.championshipId = 0,
    this.region = '',
    this.homeGoals = 0,
    this.awayGoals = 0,
    this.isVotingOpen = false,
    this.votingTitle = '',
    this.bestPlayer = '',
    this.electedPlayerId = '',
    this.electedPlayerName = '',
    this.votesCount = '',
    this.registeredAt,
    this.regionIds = const [],
    this.goals = const [],
    this.durationMinutes = defaultDurationMinutes,
    this.manualStatus = MatchManualStatus.none,
    this.startedAt,
    this.halfTimeAt,
    this.secondHalfAt,
    this.statusAt,
    this.bookings = const [],
    this.lineup = const MatchLineup(),
    this.referee = '',
    this.notes = '',
  });

  static const String bookingsField = 'cartoes';
  static const String lineupField = 'escalacao';

  static DateTime? _time(Object? value) => value is Timestamp ? value.toDate() : null;

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
      originalTime: data['horarioOriginal']?.toString() ?? '',
      venue: data['local']?.toString() ?? '',
      championshipId: _int(data['id_campeonato']),
      region: RegionRegistry.nameFromDoc(data),
      homeGoals: _int(data['golTimeCasa']),
      awayGoals: _int(data['golTimeFora']),
      isVotingOpen: data['votacao'] == 'true',
      votingTitle: data['tituloVotacao']?.toString() ?? '',
      bestPlayer: data['melhorJogador']?.toString() ?? '',
      electedPlayerId: (data[electedField] as Map?)?['idJogador']?.toString() ?? '',
      electedPlayerName: (data[electedField] as Map?)?['nome']?.toString() ?? '',
      votesCount: data['quantidadeVotos']?.toString() ?? '',
      registeredAt: registeredAt is Timestamp ? registeredAt.toDate() : null,
      regionIds: (data[regionIdsField] as List?)?.map((id) => id.toString()).toList() ?? const [],
      goals: MatchGoal.listFrom(data[goalsField]),
      durationMinutes: _int(data['duracao']) > 0 ? _int(data['duracao']) : defaultDurationMinutes,
      manualStatus: MatchManualStatus.fromKey(data['status']?.toString()),
      startedAt: _time(data['inicioEm']),
      halfTimeAt: _time(data['intervaloEm']),
      secondHalfAt: _time(data['segundoTempoEm']),
      statusAt: _time(data['statusEm']),
      bookings: MatchBooking.listFrom(data[bookingsField]),
      lineup: MatchLineup.fromMap(data[lineupField]),
      referee: data['arbitro']?.toString() ?? '',
      notes: data['observacoes']?.toString() ?? '',
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
        if (originalTime.isNotEmpty) 'horarioOriginal': originalTime,
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
        if (bookings.isNotEmpty) bookingsField: [for (final b in bookings) b.toMap()],
        if (!lineup.isEmpty) lineupField: lineup.toMap(),
        if (referee.isNotEmpty) 'arbitro': referee,
        if (notes.isNotEmpty) 'observacoes': notes,
      };

  MatchDTO copyWith({
    String? id,
    String? homeTeam,
    String? awayTeam,
    String? homeTeamId,
    String? awayTeamId,
    String? date,
    String? time,
    String? originalTime,
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
    DateTime? startedAt,
    DateTime? halfTimeAt,
    DateTime? secondHalfAt,
    DateTime? statusAt,
    List<MatchBooking>? bookings,
    MatchLineup? lineup,
    String? referee,
    String? notes,
  }) {
    return MatchDTO(
      id: id ?? this.id,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      date: date ?? this.date,
      time: time ?? this.time,
      originalTime: originalTime ?? this.originalTime,
      venue: venue ?? this.venue,
      championshipId: championshipId ?? this.championshipId,
      region: region ?? this.region,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
      isVotingOpen: isVotingOpen ?? this.isVotingOpen,
      votingTitle: votingTitle ?? this.votingTitle,
      bestPlayer: bestPlayer ?? this.bestPlayer,
      electedPlayerId: electedPlayerId,
      electedPlayerName: electedPlayerName,
      votesCount: votesCount ?? this.votesCount,
      registeredAt: registeredAt ?? this.registeredAt,
      regionIds: regionIds ?? this.regionIds,
      goals: goals ?? this.goals,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      manualStatus: manualStatus ?? this.manualStatus,
      startedAt: startedAt ?? this.startedAt,
      halfTimeAt: halfTimeAt ?? this.halfTimeAt,
      secondHalfAt: secondHalfAt ?? this.secondHalfAt,
      statusAt: statusAt ?? this.statusAt,
      bookings: bookings ?? this.bookings,
      lineup: lineup ?? this.lineup,
      referee: referee ?? this.referee,
      notes: notes ?? this.notes,
    );
  }

  /// "Iniciar partida" de novo: relógio zerado a partir de [startedAt]
  /// (sem intervalo nem 2º tempo).
  MatchDTO withRestartedClock(DateTime startedAt) => MatchDTO(
        id: id,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        date: date,
        time: time,
        originalTime: originalTime,
        venue: venue,
        championshipId: championshipId,
        region: region,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        isVotingOpen: isVotingOpen,
        votingTitle: votingTitle,
        bestPlayer: bestPlayer,
        electedPlayerId: electedPlayerId,
        electedPlayerName: electedPlayerName,
        votesCount: votesCount,
        registeredAt: registeredAt,
        regionIds: regionIds,
        goals: goals,
        durationMinutes: durationMinutes,
        manualStatus: MatchManualStatus.live,
        startedAt: startedAt,
        statusAt: statusAt,
        bookings: bookings,
        lineup: lineup,
        referee: referee,
        notes: notes,
      );

  /// Atrasou: novo horário [newTime] (guardando o 1º em [originalTime]) e,
  /// com [resetClock], volta para antes do jogo (sem status nem relógio).
  MatchDTO withDelay(String newTime, {required String originalTime, required bool resetClock}) => MatchDTO(
        id: id,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        date: date,
        time: newTime,
        originalTime: originalTime,
        venue: venue,
        championshipId: championshipId,
        region: region,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        isVotingOpen: isVotingOpen,
        votingTitle: votingTitle,
        bestPlayer: bestPlayer,
        electedPlayerId: electedPlayerId,
        electedPlayerName: electedPlayerName,
        votesCount: votesCount,
        registeredAt: registeredAt,
        regionIds: regionIds,
        goals: goals,
        durationMinutes: durationMinutes,
        manualStatus: resetClock ? MatchManualStatus.none : manualStatus,
        startedAt: resetClock ? null : startedAt,
        halfTimeAt: resetClock ? null : halfTimeAt,
        secondHalfAt: resetClock ? null : secondHalfAt,
        statusAt: resetClock ? null : statusAt,
        bookings: bookings,
        lineup: lineup,
        referee: referee,
        notes: notes,
      );

  /// Começa depois do horário cadastrado (o admin marcou "Atrasou").
  bool get delayed => originalTime.trim().isNotEmpty && originalTime.trim() != time.trim();

  @override
  List<Object?> get props => [
        id,
        homeTeam,
        awayTeam,
        homeTeamId,
        awayTeamId,
        date,
        time,
        originalTime,
        venue,
        championshipId,
        region,
        homeGoals,
        awayGoals,
        isVotingOpen,
        votingTitle,
        bestPlayer,
        electedPlayerId,
        electedPlayerName,
        votesCount,
        registeredAt,
        regionIds,
        goals,
        durationMinutes,
        manualStatus,
        startedAt,
        halfTimeAt,
        secondHalfAt,
        statusAt,
        bookings,
        lineup,
        referee,
        notes,
      ];
}
