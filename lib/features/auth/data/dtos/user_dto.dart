import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Documento da coleção `usuarios` (id do documento = uid do FirebaseAuth).
class UserDTO extends Equatable {
  final String id;
  final String name;
  final String email;
  final String favoriteTeam;
  final bool isAdmin;

  /// `urlImagem`: foto da conta (carteirinha de torcedor); vazio = sem foto.
  final String photoUrl;

  const UserDTO({
    required this.id,
    required this.name,
    required this.email,
    this.favoriteTeam = '',
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
        'admin': isAdmin,
        if (photoUrl.isNotEmpty) 'urlImagem': photoUrl,
      };

  /// Contas antigas e quem pulou a etapa 2 do cadastro ficam com `time` vazio.
  bool get hasFavoriteTeam => favoriteTeam.trim().isNotEmpty;

  UserDTO copyWith({String? name, String? email, String? favoriteTeam, String? photoUrl}) {
    return UserDTO(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      favoriteTeam: favoriteTeam ?? this.favoriteTeam,
      isAdmin: isAdmin,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, favoriteTeam, isAdmin, photoUrl];
}
