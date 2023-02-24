import 'dart:io';

import 'package:arena_soccer/core/models/chat_user.dart';
import 'package:arena_soccer/core/services/auth/auth_mock_service.dart';

abstract class AuthService {
  //vai retornar o usuário logado, caso não tenha retorna null
  ChatUser? get currentUser;
  //detecta quando o usuário fizer mudanças no estado da aplicação (logar ou sair, por exemplo.)
  Stream<ChatUser?> get userChanges;

  //método que realiza o cadastro:
  Future<void> signup(String name, String email, String password, File? image);

  //método que realiza o login:
  Future<void> login(String email, String password);

  //método que realiza o logout:
  Future<void> logout();

  //retorna o serviço que estou utilizando
  factory AuthService(){
    return AuthMockService();
  }

}
