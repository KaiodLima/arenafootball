
class Time {
  //atributos
  String? idTime;
  String? nome;
  String? descricao;
  String? urlImagem;
  String? fkCompeticao;

  //construtor
  Time({
    this.idTime,
    this.nome, 
    this.descricao, 
    this.urlImagem,
    this.fkCompeticao,
  });

  //métodos acessores
  String get getIdTime => idTime ?? "";

  set setIdTime(String value) {
    idTime = value;
  }

  String get getNome => nome ?? "";

  set setNome(String value) {
    nome = value;
  }

  String get getDescricao => descricao ?? "";

  set setDescricao(String value) {
    descricao = value;
  }

  String get getUrlImagem => urlImagem ?? "";

  set setUrlImagem(String value) {
    urlImagem = value;
  }

  String get getFkCompeticao => fkCompeticao ?? "";

  set setFkCompeticao(String value) {
    fkCompeticao = value;
  }

}