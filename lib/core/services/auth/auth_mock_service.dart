//classe "fake" de autenticação
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:arena_soccer/core/models/chat_user.dart';
import 'package:arena_soccer/core/services/auth/auth_service.dart';

class AuthMockService implements AuthService {
  //cria usuário padrão pra ficar logado
  static final _defaultUser = ChatUser(id: "1", nome: "admin", email: "admin@teste.com", imageURL: "assets/images/avatar.png");

  //atributos static pega sempre a mesma instancia do objeto, sem duplicatas na memória.
  static Map<String, ChatUser> _users = {
    _defaultUser.email: _defaultUser, //passado o user padrão aqui pra já começar na lista
  };
  static ChatUser? _currentUser;

  //detecta quando o usuário fizer mudanças no estado da aplicação (logar ou sair, por exemplo.)
  static MultiStreamController<ChatUser?>? _controller;
  static final _userStream = Stream<ChatUser?>.multi((controller) {
    _controller = controller;
    _updateUser(_defaultUser); //passando usuário padrão
  });

  //vai retornar o usuário logado, caso não tenha retorna null
  @override
  ChatUser? get currentUser {
    return _currentUser;
  }

  //retorna uma stream de dados com as alterações feitas
  Stream<ChatUser?> get userChanges {
    return _userStream;
  }

  //método que realiza o cadastro:
  @override
  Future<void> signup(
    String name,
    String email,
    String password,
    File? image,
  ) async {
    final newUser = ChatUser(
      id: Random().nextDouble().toString(),
      nome: name,
      email: email,
      imageURL: image?.path ?? 'assets/images/avatar.png',
    );

    _users.putIfAbsent(email, () => newUser); //adiciona usuário na lista

    _updateUser(newUser); //faz login
  }

  //método que realiza o login:
  @override
  Future<void> login(String email, String password) async {
    _updateUser(_users[email]);
  }

  //método que realiza o logout:
  Future<void> logout() async {
    _updateUser(null);
  }

  static void _updateUser(ChatUser? user) {
    _currentUser = null;
    _controller?.add(_currentUser);
  }
}
