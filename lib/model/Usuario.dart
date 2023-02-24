
class Usuario {
  //atributos
  String? idUsuario;
  String? nome;
  String? email;
  String? senha;
  String? timeQueTorce;
  bool? isAdmin;
  //construtor
  Usuario({
    this.idUsuario, 
    this.nome, 
    this.email, 
    this.senha, 
    this.timeQueTorce,
    this.isAdmin});

  //métodos acessores
  String get getIdUsuario => idUsuario ?? "";

  set setIdUsuario(String value) {
    idUsuario = value;
  }

  String get getSenha => senha ?? "";

  set setSenha(String value) {
    senha = value;
  }

  String get getEmail => email ?? "";

  set setEmail(String value) {
    email = value;
  }

  String get getNome => nome ?? "";

  set setNome(String value) {
    nome = value;
  }

  String get getTimeQuetorce => timeQueTorce ?? "";

  set setTimeQueTorce(String value) {
    timeQueTorce = value;
  }

  bool get getIsAdmin => isAdmin ?? false;

  set setIsAdmin(bool value) {
    isAdmin = value;
  }
}