
class News {
  //atributos
  final int? idNoticia;
  final String? titulo;
  final String? descricao;
  final String? urlImagem;

  final String? link;
  final String? exibir;

  final String? fkCompeticao;
  final String? timeCasa;
  final String? timeFora;
  final String? golTimeCasa;
  final String? golTimeFora;
  final String? tag;

  News({
    required this.idNoticia,
    this.titulo,
    this.descricao,
    this.urlImagem,
    this.link,
    this.exibir,
    this.fkCompeticao,
    this.timeCasa,
    this.timeFora,
    this.golTimeCasa,
    this.golTimeFora,
    this.tag,
  });

}
