
import 'package:cloud_firestore/cloud_firestore.dart';

class Noticia {
  String? idNoticia;
  Timestamp? data;
  //atributos
  String? titulo;
  String? descricao;
  String? urlImagem;

  String? link;
  String? exibir;

  String? fkCompeticao;
  String? timeCasa;
  String? timeFora;
  String? golTimeCasa;
  String? golTimeFora;
  String? tag;

  //construtor
  Noticia({
    this.idNoticia,
    this.data,
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
    this.tag
  });

  //métodos acessores
  String get getIdNoticia => idNoticia ?? "";

  set setIdNoticia(String value) {
    idNoticia = value;
  }

  String get getTitulo => titulo ?? "";

  set setTitulo(String value) {
    titulo = value;
  }

  String get getDescricao => descricao ?? "";

  set setDescricao(String value) {
    descricao = value;
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

  String get getFkCompeticao => fkCompeticao ?? "";

  set setFkCompeticao(String value) {
    fkCompeticao = value;
  }

  String get getTimeCasa => timeCasa ?? "";

  set setTimeCasa(String value) {
    timeCasa = value;
  }

  String get getTimeFora => timeFora ?? "";

  set setTimeFora(String value) {
    timeFora = value;
  }

  String get getGolTimeFora => golTimeFora ?? "";

  set setGolTimeFora(String value) {
    golTimeFora = value;
  }

  String get getGolTimeCasa => golTimeCasa ?? "";

  set setGolTimeCasa(String value) {
    golTimeCasa = value;
  }

  String get getTag => tag ?? "";

  set setTag(String value) {
    tag = value;
  }

}
