import 'package:equatable/equatable.dart';

/// Atleta do card "Craques da rodada" do Arena Fantasy (`craques_fantasy`,
/// gravado pelas functions): colocação, foto, time, posição e pontos.
class FantasyNewsAthlete extends Equatable {
  final String id;
  final String name;
  final String team;
  final String teamId;
  final String photoUrl;

  /// `gol`/`zag`/`mei`/`ata` (vazio = sem posição).
  final String position;
  final double points;

  /// Colocação na rodada (empate = a mesma).
  final int rank;

  const FantasyNewsAthlete({
    required this.id,
    required this.name,
    this.team = '',
    this.teamId = '',
    this.photoUrl = '',
    this.position = '',
    this.points = 0,
    this.rank = 1,
  });

  factory FantasyNewsAthlete.fromMap(Map<String, dynamic> data) => FantasyNewsAthlete(
        id: data['idJogador']?.toString() ?? '',
        name: data['nome']?.toString() ?? '',
        team: data['time']?.toString() ?? '',
        teamId: data['idTime']?.toString() ?? '',
        photoUrl: data['urlImagem']?.toString() ?? '',
        position: data['posicao']?.toString() ?? '',
        points: (data['pontos'] as num?)?.toDouble() ?? 0,
        rank: (data['colocacao'] as num?)?.toInt() ?? 1,
      );

  /// Lista do doc (`craques_fantasy`), na ordem gravada.
  static List<FantasyNewsAthlete> listFrom(Object? value) => [
        for (final item in (value as List?) ?? const [])
          if (item is Map) FantasyNewsAthlete.fromMap(Map<String, dynamic>.from(item)),
      ];

  /// Mesmas chaves do doc (o cache relê pelo [fromMap]).
  Map<String, dynamic> toMap() => {
        'idJogador': id,
        'nome': name,
        'time': team,
        'idTime': teamId,
        'urlImagem': photoUrl,
        'posicao': position,
        'pontos': points,
        'colocacao': rank,
      };

  @override
  List<Object?> get props => [id, name, team, teamId, photoUrl, position, points, rank];
}
