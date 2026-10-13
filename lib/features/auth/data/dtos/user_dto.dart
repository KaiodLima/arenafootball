import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';

/// Documento da coleção `usuarios` (id do documento = uid do FirebaseAuth).
class UserDTO extends Equatable {
  final String id;
  final String name;
  final String email;
  /// Nome do time do coração (cópia para exibir; o vínculo é [favoriteTeamId]).
  final String favoriteTeam;

  /// `idTime`: id do time do coração; vazio em contas antigas (vale o nome).
  final String favoriteTeamId;
  final bool isAdmin;

  /// `urlImagem`: foto da conta (carteirinha de torcedor); vazio = sem foto.
  final String photoUrl;

  const UserDTO({
    required this.id,
    required this.name,
    required this.email,
    this.favoriteTeam = '',
    this.favoriteTeamId = '',
    this.isAdmin = false,
    this.photoUrl = '',
  });

  factory UserDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return UserDTO(
      id: data['idUsuario']?.toString() ?? doc.id,
      name: data['nome']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      favoriteTeam: data['time']?.toString() ?? '',
      favoriteTeamId: data['idTime']?.toString() ?? '',
      isAdmin: data['admin'] == true,
      photoUrl: data['urlImagem']?.toString() ?? '',
    );
  }

  /// A senha não é mais gravada no Firestore: a autenticação é feita só
  /// pelo FirebaseAuth. Contas antigas ainda têm o campo `senha`.
  Map<String, dynamic> toMap() => {
        'idUsuario': id,
        'nome': name,
        'email': email,
        'time': favoriteTeam,
        'idTime': favoriteTeamId,
        'admin': isAdmin,
        if (photoUrl.isNotEmpty) 'urlImagem': photoUrl,
      };

  /// Contas antigas e quem pulou a etapa 2 do cadastro ficam com `time` vazio.
  bool get hasFavoriteTeam => favoriteTeam.trim().isNotEmpty || favoriteTeamId.isNotEmpty;

  /// O time de id [id] (ou, sem id no doc antigo, de nome [name]) é o do coração?
  bool isFavorite({String id = '', String name = ''}) =>
      hasFavoriteTeam && sameTeam(idA: favoriteTeamId, nameA: favoriteTeam, idB: id, nameB: name);

  UserDTO copyWith({String? name, String? email, String? favoriteTeam, String? favoriteTeamId, String? photoUrl}) {
    return UserDTO(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      favoriteTeam: favoriteTeam ?? this.favoriteTeam,
      favoriteTeamId: favoriteTeamId ?? this.favoriteTeamId,
      isAdmin: isAdmin,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, favoriteTeam, favoriteTeamId, isAdmin, photoUrl];
}
