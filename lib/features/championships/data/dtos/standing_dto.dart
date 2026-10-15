import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';

/// Linha da classificação (`classificacao` / `classificacao{ano}`): os campos
/// do time + as estatísticas dele no grupo.
class StandingDTO extends Equatable {
  /// Id do doc = id do time (a linha é criada junto com o time).
  final String id;

  /// Nome do time (cópia para exibir).
  final String teamName;

  String get teamId => id;
  final String region;

  /// Escudo do time (`urlImagem`, copiado do time ao cadastrá-lo).
  final String imageUrl;

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
    this.imageUrl = '',
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

  /// Jogos disputados no grupo.
  int get games => wins + draws + losses;

  /// Aproveitamento (0–1): pontos ganhos sobre os possíveis (3 por jogo).
  double get performance => games == 0 ? 0 : points / (games * 3);

  static int _int(Object? value) => (value as num?)?.toInt() ?? 0;

  factory StandingDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return StandingDTO(
      id: doc.id,
      teamName: data['nome']?.toString() ?? '',
      region: RegionRegistry.nameFromDoc(data),
      imageUrl: data['urlImagem']?.toString() ?? '',
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
        ...RegionRegistry.fieldsFor(region),
        'urlImagem': imageUrl,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
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
        imageUrl,
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
