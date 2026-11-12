import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Dados da arte de anúncio do atleta ("contratação"): só o que o elenco já
/// carregou (atleta, time e a competição escolhida), sem leitura nova.
class PlayerArtData extends Equatable {
  final String name;
  final String photoUrl;

  /// Chave da posição (`posicao`: goleiro, zagueiro...); vazia = sem posição.
  final String positionKey;
  final ArtTeam team;

  /// Competição escolhida no elenco (vazio = geral).
  final String championship;
  final String championshipLogoUrl;

  /// Números na competição escolhida (ou no geral); 0 = não aparece.
  final int goals;
  final int assists;

  /// Link público do atleta (QR).
  final String link;

  const PlayerArtData({
    required this.name,
    required this.team,
    this.photoUrl = '',
    this.positionKey = '',
    this.championship = '',
    this.championshipLogoUrl = '',
    this.goals = 0,
    this.assists = 0,
    this.link = '',
  });

  List<String> get _words => name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  /// "Ronaldo" de "Ronaldo Nazário Lima" (vazio com um nome só).
  String get firstName {
    final words = _words;
    return words.length > 1 ? words.first : '';
  }

  /// O destaque: o resto do nome ("NAZÁRIO LIMA"), ou o nome inteiro se for um só.
  String get highlightName {
    final words = _words;
    return words.length > 1 ? words.sublist(1).join(' ') : name.trim();
  }

  /// Iniciais (silhueta quando não há foto).
  String get initials => ArtTeam(name: name).initials;

  factory PlayerArtData.of({
    required PlayerDTO player,
    required TeamDTO team,
    required String season,
    ChampionshipDTO? championship,
  }) {
    final enrollment = championship == null ? null : player.enrollmentIn(championship.championshipId);
    return PlayerArtData(
      name: player.name,
      photoUrl: player.imageUrl.trim(),
      positionKey: player.position,
      team: ArtTeam(
        name: team.name,
        crestUrl: team.imageUrl,
        primaryColor: team.primaryColor,
        secondaryColor: team.secondaryColor,
      ),
      championship: championship?.title ?? '',
      championshipLogoUrl: championship?.imageUrl.trim() ?? '',
      goals: enrollment?.goals ?? (championship == null ? player.goals : 0),
      assists: enrollment?.assists ?? (championship == null ? player.assists : 0),
      link: player.id.isEmpty ? appLink : athleteLink(season, player.id),
    );
  }

  @override
  List<Object?> get props =>
      [name, photoUrl, positionKey, team, championship, championshipLogoUrl, goals, assists, link];
}
