import 'dart:io';

enum AuthMode { Signup, Login }

class AuthFormData {
  String name = '';
  String email = '';
  String password = '';
  File? image;

  AuthMode _mode = AuthMode
      .Login; //inicialmente minha classe vai começar configurada pra Login

  //verifica se está configurado como Login
  bool get isLogin {
    return _mode == AuthMode.Login;
  }

  //verifica se está configurado como Sigup
  bool get isSigup {
    return _mode == AuthMode.Signup;
  }

  //alternar os valores, se for Login vira Signup e vice-versa
  void authToogleMode() {
    _mode = isLogin ? AuthMode.Signup : AuthMode.Login;
  }
}
