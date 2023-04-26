
class Destaque {
  //atributos
  String? idDestaque;
  String? titulo;
  String? link;
  String? urlImagem;
  String? exibir;
  
  //construtor
  Destaque({
    this.idDestaque,
    this.titulo, 
    this.link, 
    this.urlImagem,
    this.exibir
  });

  //métodos acessores
  String get getIdDestaque => idDestaque ?? "";

  set setIdjogador(String value) {
    idDestaque = value;
  }

  String get getTitulo => titulo ?? "";

  set setTitulo(String value) {
    titulo = value;
  }

  String get getUrlImagem => urlImagem ?? "";

  set setUrlImagem(String value) {
    urlImagem = value;
  }

  String get getLink => link ?? "";

  set setLink(String value) {
    link = value;
  }

  String get getExibir => exibir ?? "";

  set setExibir(String value) {
    exibir = value;
  }

}