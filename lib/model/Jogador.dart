
class Jogador {
  //atributos
  String? idJogador;
  String? nome;
  String? time;
  String? urlImagem;
  
  int? nGols;
  int? nAssistencias;

  //construtor
  Jogador({
    this.idJogador,
    this.nome, 
    this.time, 
    this.urlImagem,
    this.nGols,
    this.nAssistencias
  });

  //métodos acessores
  String get getIdjogador => idJogador ?? "";

  set setIdjogador(String value) {
    idJogador = value;
  }

  String get getNome => nome ?? "";

  set setNome(String value) {
    nome = value;
  }

  String get getTime => time ?? "";

  set setTime(String value) {
    time = value;
  }

  String get getUrlImagem => urlImagem ?? "";

  set setUrlImagem(String value) {
    urlImagem = value;
  }

  int get getNGols => nGols ?? 0;

  set setNGols(int value) {
    nGols = value;
  }

  int get getNAssistencias => nAssistencias ?? 0;

  set setNAssistencias(int value) {
    nAssistencias = value;
  }

}