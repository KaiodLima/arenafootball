
class Votacao {
  //atributos
  String? id;
  String? nome;
  String? time;


  //construtor
  Votacao({
    this.id,
    this.nome, 
    this.time, 
  });

  //métodos acessores
  String get getId => id ?? "";

  set setId(String value) {
    id = value;
  }

  String get getNome => nome ?? "";

  set setNome(String value) {
    nome = value;
  }

  String get getTime => time ?? "";

  set setTime(String value) {
    time = value;
  }

  

}