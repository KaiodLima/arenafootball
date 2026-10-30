import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Estado do evento no painel: desligado, em teste (só o admin vê) ou
/// liberado para todos.
enum AlbumEventMode { off, test, all }

/// `album_eventos/{id}`: o evento do álbum de figurinhas (um ativo por vez).
class AlbumEventDTO extends Equatable {
  static const int defaultPerPack = 5;

  final String id;
  final String title;
  final String description;
  final bool active;

  /// Modo teste (`somenteAdmin`): ativo, mas só o admin vê.
  final bool adminOnly;

  /// Times do álbum (páginas), na ordem; [teams] = nomes (cópia).
  final List<String> teamIds;
  final List<String> teams;
  final int perPack;
  final DateTime? createdAt;

  const AlbumEventDTO({
    this.id = '',
    this.title = '',
    this.description = '',
    this.active = false,
    this.adminOnly = false,
    this.teamIds = const [],
    this.teams = const [],
    this.perPack = defaultPerPack,
    this.createdAt,
  });

  factory AlbumEventDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    List<String> list(String key) => (data[key] as List?)?.map((e) => e.toString()).toList() ?? const [];
    return AlbumEventDTO(
      id: doc.id,
      title: data['titulo']?.toString() ?? '',
      description: data['descricao']?.toString() ?? '',
      active: data['ativo'] == true,
      adminOnly: data['somenteAdmin'] == true,
      teamIds: list('idsTimes'),
      teams: list('times'),
      perPack: (data['porPacote'] as num?)?.toInt() ?? defaultPerPack,
      createdAt: (data['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': title,
        'descricao': description,
        'ativo': active,
        'somenteAdmin': adminOnly,
        'idsTimes': teamIds,
        'times': teams,
        'porPacote': perPack,
      };

  AlbumEventMode get mode => !active
      ? AlbumEventMode.off
      : adminOnly
          ? AlbumEventMode.test
          : AlbumEventMode.all;

  /// Nome do time [teamId] (cópia gravada no evento).
  String teamName(String teamId) {
    final index = teamIds.indexOf(teamId);
    return index >= 0 && index < teams.length ? teams[index] : '';
  }

  AlbumEventDTO copyWith({
    String? id,
    String? title,
    String? description,
    bool? active,
    List<String>? teamIds,
    List<String>? teams,
    int? perPack,
  }) {
    return AlbumEventDTO(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      active: active ?? this.active,
      adminOnly: adminOnly,
      teamIds: teamIds ?? this.teamIds,
      teams: teams ?? this.teams,
      perPack: perPack ?? this.perPack,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, active, adminOnly, teamIds, teams, perPack, createdAt];
}

/// Tipo da figurinha: o escudo do time ou um atleta.
enum StickerKind {
  crest('escudo'),
  athlete('atleta');

  final String key;

  const StickerKind(this.key);

  static StickerKind fromKey(String? key) => key == crest.key ? crest : athlete;
}

/// `album_eventos/{id}/figurinhas/{idFig}`: uma figurinha do álbum.
class StickerDTO extends Equatable {
  final String id;

  /// Número no álbum (sequencial).
  final int number;
  final StickerKind kind;
  final String name;
  final String teamId;
  final String team;
  final String playerId;
  final String imageUrl;

  /// Ordem na página do time.
  final int order;

  /// Rara (`rara`, marcada pelo admin): sai bem menos no pacotinho e tem a
  /// moldura dourada.
  final bool rare;

  const StickerDTO({
    this.id = '',
    this.number = 0,
    this.kind = StickerKind.athlete,
    this.name = '',
    this.teamId = '',
    this.team = '',
    this.playerId = '',
    this.imageUrl = '',
    this.order = 0,
    this.rare = false,
  });

  factory StickerDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return StickerDTO(
      id: doc.id,
      number: (data['numero'] as num?)?.toInt() ?? 0,
      kind: StickerKind.fromKey(data['tipo']?.toString()),
      name: data['nome']?.toString() ?? '',
      teamId: data['idTime']?.toString() ?? '',
      team: data['time']?.toString() ?? '',
      playerId: data['idJogador']?.toString() ?? '',
      imageUrl: data['urlImagem']?.toString() ?? '',
      order: (data['ordem'] as num?)?.toInt() ?? 0,
      rare: data['rara'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'numero': number,
        'tipo': kind.key,
        'nome': name,
        'idTime': teamId,
        'time': team,
        if (playerId.isNotEmpty) 'idJogador': playerId,
        'urlImagem': imageUrl,
        'ordem': order,
        'rara': rare,
      };

  StickerDTO copyWith({String? id, int? number, String? name, String? imageUrl, int? order, bool? rare}) {
    return StickerDTO(
      id: id ?? this.id,
      number: number ?? this.number,
      kind: kind,
      name: name ?? this.name,
      teamId: teamId,
      team: team,
      playerId: playerId,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      rare: rare ?? this.rare,
    );
  }

  @override
  List<Object?> get props => [id, number, kind, name, teamId, team, playerId, imageUrl, order, rare];
}

/// `usuarios/{uid}/album/{idEvento}`: as figurinhas da conta (só as functions
/// gravam). [counts]: idFig → quantidade (2+ = repetida).
class UserAlbumDTO extends Equatable {
  final Map<String, int> counts;
  final List<String> completedPages;
  final bool complete;

  /// Pacotes já abertos (`pacotes`) e a hora do último pedido
  /// (`ultimoPacote`): o próximo libera 24 h depois (`AlbumPackId`).
  final int packs;
  final DateTime? lastPackAt;

  const UserAlbumDTO({
    this.counts = const {},
    this.completedPages = const [],
    this.complete = false,
    this.packs = 0,
    this.lastPackAt,
  });

  factory UserAlbumDTO.fromMap(Map<String, dynamic> data) {
    final raw = data['figurinhas'] as Map? ?? const {};
    return UserAlbumDTO(
      counts: {
        for (final entry in raw.entries)
          if ((entry.value as num?) != null && (entry.value as num) > 0)
            entry.key.toString(): (entry.value as num).toInt(),
      },
      completedPages: (data['paginasCompletas'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      complete: data['completo'] == true,
      packs: (data['pacotes'] as num?)?.toInt() ?? 0,
      lastPackAt: (data['ultimoPacote'] as Timestamp?)?.toDate(),
    );
  }

  bool has(String stickerId) => (counts[stickerId] ?? 0) > 0;

  int countOf(String stickerId) => counts[stickerId] ?? 0;

  /// Figurinhas diferentes coladas, entre as do catálogo [stickers].
  int collected(List<StickerDTO> stickers) => stickers.where((s) => has(s.id)).length;

  /// Repetidas (as cópias além da colada), entre as do catálogo.
  int duplicates(List<StickerDTO> stickers) =>
      stickers.fold(0, (acc, s) => acc + (countOf(s.id) > 1 ? countOf(s.id) - 1 : 0));

  @override
  List<Object?> get props => [counts, completedPages, complete, packs, lastPackAt];
}

/// Situação do pacote do dia (`status`).
enum AlbumPackStatus {
  requested('pedido'),
  opened('aberto'),
  refused('recusado'),
  error('erro');

  final String key;

  const AlbumPackStatus(this.key);

  static AlbumPackStatus fromKey(String? key) {
    for (final status in values) {
      if (status.key == key) return status;
    }
    return requested;
  }
}

/// `album_pacotes/{idEvento}_{uid}_{dia}`: o pacotinho do dia (sorteado pelas
/// functions).
class AlbumPackDTO extends Equatable {
  final String id;
  final AlbumPackStatus status;

  /// Figurinhas do pacote, na ordem; [newOnes] = as que eram novas.
  final List<String> stickers;
  final List<String> newOnes;

  const AlbumPackDTO({
    this.id = '',
    this.status = AlbumPackStatus.requested,
    this.stickers = const [],
    this.newOnes = const [],
  });

  factory AlbumPackDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    List<String> list(String key) => (data[key] as List?)?.map((e) => e.toString()).toList() ?? const [];
    return AlbumPackDTO(
      id: doc.id,
      status: AlbumPackStatus.fromKey(data['status']?.toString()),
      stickers: list('figurinhas'),
      newOnes: list('novas'),
    );
  }

  bool get isOpened => status == AlbumPackStatus.opened;

  @override
  List<Object?> get props => [id, status, stickers, newOnes];
}

/// `album_eventos/{evento}/ranking/{uid}`: o colecionador no ranking do
/// álbum (gravado pelas functions a cada pacote; leitura pública).
class AlbumRankingEntryDTO extends Equatable {
  final String userId;
  final String name;
  final String imageUrl;

  /// Figurinhas diferentes coladas e, entre elas, as raras.
  final int collected;
  final int rares;
  final bool complete;

  /// Quando chegou na contagem atual (desempate: quem chegou primeiro).
  final DateTime? reachedAt;

  const AlbumRankingEntryDTO({
    required this.userId,
    this.name = '',
    this.imageUrl = '',
    this.collected = 0,
    this.rares = 0,
    this.complete = false,
    this.reachedAt,
  });

  factory AlbumRankingEntryDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AlbumRankingEntryDTO(
      userId: doc.id,
      name: data['nome']?.toString() ?? '',
      imageUrl: data['urlImagem']?.toString() ?? '',
      collected: (data['coladas'] as num?)?.toInt() ?? 0,
      rares: (data['raras'] as num?)?.toInt() ?? 0,
      complete: data['completo'] == true,
      reachedAt: (data['alcancadoEm'] as Timestamp?)?.toDate(),
    );
  }

  /// Ordem do ranking: mais coladas; empate = quem chegou primeiro; depois o nome.
  static List<AlbumRankingEntryDTO> sorted(List<AlbumRankingEntryDTO> entries) => [...entries]..sort((a, b) {
      final byCount = b.collected.compareTo(a.collected);
      if (byCount != 0) return byCount;
      final at = a.reachedAt;
      final bt = b.reachedAt;
      if (at != null && bt != null && at != bt) return at.compareTo(bt);
      if ((at == null) != (bt == null)) return at == null ? 1 : -1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

  @override
  List<Object?> get props => [userId, name, imageUrl, collected, rares, complete, reachedAt];
}

