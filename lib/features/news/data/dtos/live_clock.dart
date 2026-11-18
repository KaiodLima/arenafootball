import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';

/// Relógio da partida copiado no card ao vivo (`relogio`): o que o
/// `MatchClock` precisa para o minuto corrido no feed. Gravado pelo app a
/// cada lance e pelas functions a cada mudança de fase/horário.
class LiveClock extends Equatable {
  final String date;
  final String time;
  final int durationMinutes;

  /// `status` da partida (andamento/intervalo/encerrada/aguardando; vazio = pelo horário).
  final String status;
  final DateTime? startedAt;
  final DateTime? halfTimeAt;
  final DateTime? secondHalfAt;
  final DateTime? statusAt;

  const LiveClock({
    this.date = '',
    this.time = '',
    this.durationMinutes = MatchDTO.defaultDurationMinutes,
    this.status = '',
    this.startedAt,
    this.halfTimeAt,
    this.secondHalfAt,
    this.statusAt,
  });

  /// Da partida (ao montar o card).
  factory LiveClock.of(MatchDTO match) => LiveClock(
        date: match.date,
        time: match.time,
        durationMinutes: match.durationMinutes,
        status: match.manualStatus.key,
        startedAt: match.startedAt,
        halfTimeAt: match.halfTimeAt,
        secondHalfAt: match.secondHalfAt,
        statusAt: match.statusAt,
      );

  static DateTime? _date(Object? value) => switch (value) {
        Timestamp() => value.toDate(),
        int() => DateTime.fromMillisecondsSinceEpoch(value),
        _ => null,
      };

  /// Do doc (Timestamp) ou do cache (milissegundos); nulo sem o campo.
  static LiveClock? fromMap(Object? value) {
    if (value is! Map) return null;
    final duration = (value['duracao'] as num?)?.toInt() ?? 0;
    return LiveClock(
      date: value['data']?.toString() ?? '',
      time: value['horario']?.toString() ?? '',
      durationMinutes: duration > 0 ? duration : MatchDTO.defaultDurationMinutes,
      status: value['status']?.toString() ?? '',
      startedAt: _date(value['inicioEm']),
      halfTimeAt: _date(value['intervaloEm']),
      secondHalfAt: _date(value['segundoTempoEm']),
      statusAt: _date(value['statusEm']),
    );
  }

  Map<String, dynamic> _fields(Object Function(DateTime) stamp) => {
        'data': date,
        'horario': time,
        'duracao': durationMinutes,
        'status': status,
        if (startedAt != null) 'inicioEm': stamp(startedAt!),
        if (halfTimeAt != null) 'intervaloEm': stamp(halfTimeAt!),
        if (secondHalfAt != null) 'segundoTempoEm': stamp(secondHalfAt!),
        if (statusAt != null) 'statusEm': stamp(statusAt!),
      };

  Map<String, dynamic> toMap() => _fields(Timestamp.fromDate);

  Map<String, dynamic> toCache() => _fields((d) => d.millisecondsSinceEpoch);

  /// Partida mínima para o `MatchClock`.
  MatchDTO toMatch() => MatchDTO(
        homeTeam: '',
        awayTeam: '',
        date: date,
        time: time,
        durationMinutes: durationMinutes,
        manualStatus: MatchManualStatus.fromKey(status),
        startedAt: startedAt,
        halfTimeAt: halfTimeAt,
        secondHalfAt: secondHalfAt,
        statusAt: statusAt,
      );

  @override
  List<Object?> get props => [date, time, durationMinutes, status, startedAt, halfTimeAt, secondHalfAt, statusAt];
}
