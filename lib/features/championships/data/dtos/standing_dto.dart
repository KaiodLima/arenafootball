import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Linha da classificação (`classificacao` / `classificacao{ano}`): os campos
/// do time + as estatísticas dele no grupo.
class StandingDTO extends Equatable {
  final String id;
  final String teamName;
  final String region;

  /// `fk_grupo`: descrição do grupo do time.
  final String group;
  final int wins;
  final int losses;
  final int draws;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  /// `saldo_gols` gravado (usado só na ordenação da consulta).
  final int storedGoalDifference;

  const StandingDTO({
    required this.id,
    required this.teamName,
    this.region = '',
    this.group = '',
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
    this.storedGoalDifference = 0,
  });

  /// Saldo exibido: calculado de gols feitos - sofridos, como no app antigo.
  int get goalDifference => goalsFor - goalsAgainst;

  static int _int(Object? value) => (value as num?)?.toInt() ?? 0;

  factory StandingDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return StandingDTO(
      id: doc.id,
      teamName: data['nome']?.toString() ?? '',
      region: data['fk_competicao']?.toString() ?? '',
      group: data['fk_grupo']?.toString() ?? '',
      wins: _int(data['vitorias']),
      losses: _int(data['derrotas']),
      draws: _int(data['empates']),
      goalsFor: _int(data['gols_feitos']),
      goalsAgainst: _int(data['gols_sofridos']),
      points: _int(data['pontos']),
      storedGoalDifference: _int(data['saldo_gols']),
    );
  }

  Map<String, dynamic> toMap() => {
        'nome': teamName,
        'fk_competicao': region,
        'fk_grupo': group,
        'vitorias': wins,
        'derrotas': losses,
        'empates': draws,
        'gols_feitos': goalsFor,
        'gols_sofridos': goalsAgainst,
        'pontos': points,
        'saldo_gols': storedGoalDifference,
      };

  StandingDTO copyWith({
    String? id,
    String? teamName,
    String? region,
    String? group,
    int? wins,
    int? losses,
    int? draws,
    int? goalsFor,
    int? goalsAgainst,
    int? points,
    int? storedGoalDifference,
  }) {
    return StandingDTO(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      region: region ?? this.region,
      group: group ?? this.group,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      points: points ?? this.points,
      storedGoalDifference: storedGoalDifference ?? this.storedGoalDifference,
    );
  }

  @override
  List<Object?> get props => [
        id,
        teamName,
        region,
        group,
        wins,
        losses,
        draws,
        goalsFor,
        goalsAgainst,
        points,
        storedGoalDifference,
      ];
}
