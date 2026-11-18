import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';

/// Configuração do Arena Fantasy de um campeonato (`fantasy/{idDocCampeonato}`).
/// Sem o doc = desligado com os padrões. O admin grava a chave, os parâmetros
/// e as cópias do campeonato; `rodadaAtual`, `participantes` e `campeao` só
/// as functions gravam.
class FantasyConfigDTO extends Equatable {
  /// Id do doc do campeonato (= id do doc do Fantasy).
  final String championshipDocId;
  final int championshipId;
  final String season;
  final String title;
  final String imageUrl;
  final String region;
  final List<String> regionIds;
  final bool active;
  final int minMinutes;
  final int minDefenseMinutes;
  final double captainMultiplier;

  /// Gravados pelas functions (só leitura no app).
  final int currentRound;
  final int participants;

  static const String collection = 'fantasy';

  const FantasyConfigDTO({
    required this.championshipDocId,
    this.championshipId = 0,
    this.season = '',
    this.title = '',
    this.imageUrl = '',
    this.region = '',
    this.regionIds = const [],
    this.active = false,
    this.minMinutes = FantasyLimits.defaultMinMinutes,
    this.minDefenseMinutes = FantasyLimits.defaultMinDefenseMinutes,
    this.captainMultiplier = FantasyLimits.defaultCaptain,
    this.currentRound = 0,
    this.participants = 0,
  });

  /// Configuração nova do [championship] (desligada, com os padrões).
  factory FantasyConfigDTO.forChampionship(ChampionshipDTO championship) =>
      const FantasyConfigDTO(championshipDocId: '').withChampionship(championship);

  /// Lido do doc [data] (nulo = padrões), com as cópias do [championship]
  /// quando ele vier (o campeonato manda: nome/logo podem ter mudado).
  factory FantasyConfigDTO.fromMap(String id, Map<String, dynamic>? data, {ChampionshipDTO? championship}) {
    final map = data ?? const <String, dynamic>{};
    int asInt(Object? value, int fallback) => value is num ? value.toInt() : fallback;
    final config = FantasyConfigDTO(
      championshipDocId: id,
      championshipId: asInt(map['idCampeonato'], 0),
      season: map['temporada']?.toString() ?? '',
      title: map['titulo']?.toString() ?? '',
      imageUrl: map['urlImagem']?.toString() ?? '',
      region: RegionRegistry.nameFromDoc(map),
      regionIds: (map['idsRegioes'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      active: map['ativo'] == true,
      minMinutes: asInt(map['minMinutos'], FantasyLimits.defaultMinMinutes),
      minDefenseMinutes: asInt(map['minMinutosDefesa'], FantasyLimits.defaultMinDefenseMinutes),
      captainMultiplier: (map['capitao'] as num?)?.toDouble() ?? FantasyLimits.defaultCaptain,
      currentRound: asInt(map['rodadaAtual'], 0),
      participants: asInt(map['participantes'], 0),
    );
    return championship == null ? config : config.withChampionship(championship);
  }

  /// Copia os dados do campeonato (id, número, temporada, nome, logo, regiões).
  FantasyConfigDTO withChampionship(ChampionshipDTO championship) => copyWith(
        championshipDocId: championship.id,
        championshipId: championship.championshipId,
        season: championship.season,
        title: championship.title,
        imageUrl: championship.imageUrl,
        region: championship.region,
        regionIds: championship.regionIds,
      );

  /// Os parâmetros com os valores padrão (a chave e as cópias ficam).
  FantasyConfigDTO withDefaults() => copyWith(
        minMinutes: FantasyLimits.defaultMinMinutes,
        minDefenseMinutes: FantasyLimits.defaultMinDefenseMinutes,
        captainMultiplier: FantasyLimits.defaultCaptain,
      );

  /// O que o admin grava (sem `atualizadoEm`, posto pelo data source).
  Map<String, dynamic> toAdminMap() => {
        'idCampeonato': championshipId,
        'temporada': season,
        'titulo': title,
        'urlImagem': imageUrl,
        ...RegionRegistry.fieldsFor(region),
        'idsRegioes': regionIds,
        'ativo': active,
        'minMinutos': minMinutes,
        'minMinutosDefesa': minDefenseMinutes,
        'capitao': captainMultiplier,
      };

  FantasyConfigDTO copyWith({
    String? championshipDocId,
    int? championshipId,
    String? season,
    String? title,
    String? imageUrl,
    String? region,
    List<String>? regionIds,
    bool? active,
    int? minMinutes,
    int? minDefenseMinutes,
    double? captainMultiplier,
  }) {
    return FantasyConfigDTO(
      championshipDocId: championshipDocId ?? this.championshipDocId,
      championshipId: championshipId ?? this.championshipId,
      season: season ?? this.season,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      region: region ?? this.region,
      regionIds: regionIds ?? this.regionIds,
      active: active ?? this.active,
      minMinutes: minMinutes ?? this.minMinutes,
      minDefenseMinutes: minDefenseMinutes ?? this.minDefenseMinutes,
      captainMultiplier: captainMultiplier ?? this.captainMultiplier,
      currentRound: currentRound,
      participants: participants,
    );
  }

  @override
  List<Object?> get props => [
        championshipDocId,
        championshipId,
        season,
        title,
        imageUrl,
        region,
        regionIds,
        active,
        minMinutes,
        minDefenseMinutes,
        captainMultiplier,
        currentRound,
        participants,
      ];
}
