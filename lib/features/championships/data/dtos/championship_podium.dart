import 'package:equatable/equatable.dart';

/// Time no pódio da competição encerrada (`campeao`/`vice` em `campeonatos`):
/// cópias para exibir sem ler o time.
class ChampionshipPodiumTeam extends Equatable {
  final String teamId;
  final String name;
  final String imageUrl;
  final String primaryColor;
  final String secondaryColor;

  const ChampionshipPodiumTeam({
    this.teamId = '',
    required this.name,
    this.imageUrl = '',
    this.primaryColor = '',
    this.secondaryColor = '',
  });

  /// Lido do mapa do Firestore; nulo sem o campo ou sem nome.
  static ChampionshipPodiumTeam? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['nome']?.toString() ?? '';
    if (name.trim().isEmpty) return null;
    return ChampionshipPodiumTeam(
      teamId: raw['idTime']?.toString() ?? '',
      name: name,
      imageUrl: raw['urlImagem']?.toString() ?? '',
      primaryColor: raw['corPrimaria']?.toString() ?? '',
      secondaryColor: raw['corSecundaria']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'idTime': teamId,
        'nome': name,
        'urlImagem': imageUrl,
        if (primaryColor.isNotEmpty) 'corPrimaria': primaryColor,
        if (secondaryColor.isNotEmpty) 'corSecundaria': secondaryColor,
      };

  @override
  List<Object?> get props => [teamId, name, imageUrl, primaryColor, secondaryColor];
}
