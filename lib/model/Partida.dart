
import 'package:cloud_firestore/cloud_firestore.dart';

class Partida {
  String? idPartida;
  //atributos
  String? timeC;
  String? timeF;
  String? horario;
  String? local;  
  String? data;
  String? placar;
  int? golTimeCasa;
  int? golTimeFora;

  String? votacao;
  String? melhorJogador;
  String? quantidadeVotos;

  String? fkPartida;
  int? idCampeonato;
  Timestamp? dataRegistro;

  //construtor
  Partida({
    this.idPartida,
    this.timeC, 
    this.timeF,
    this.horario, 
    this.local, 
    this.data,
    this.fkPartida,
    this.idCampeonato,
    this.golTimeCasa,
    this.golTimeFora,
    this.votacao,
    this.dataRegistro
    });

  String get getIdPartida => idPartida ?? "";

  set setIdPartida(String value) {
    idPartida = value;
  }

  //métodos acessores
  String get getTimeC => timeC ?? "";

  set setTimeC(String value) {
    timeC = value;
  }

  String get getTimeF => timeF ?? "";

  set setTimeF(String value) {
    timeF = value;
  }

  String get getHorario => horario ?? "";

  set setHorario(String value) {
    horario = value;
  }

  String get getLocal => local ?? "";

  set setLocal(String value) {
    local = value;
  }

  String get getData => data ?? "";

  set setData(String value) {
    data = value;
  }

  String get getPlacar => placar ?? "";

  set setPlacar(String value) {
    placar = value;
  }

  String get getVotacao => votacao ?? "";

  set setVotacao(String value) {
    votacao = value;
  }

  String get getMelhorJogador => melhorJogador ?? "";

  set setMelhorJogador(String value) {
    melhorJogador = value;
  }

  String get getQuantidadeVotos => quantidadeVotos ?? "";

  set setQuantidadeVotos(String value) {
    quantidadeVotos = value;
  }

  String get getFkPartida => fkPartida ?? "";

  set setFkPartida(String value) {
    fkPartida = value;
  }

  int get getIdCampeonato => idCampeonato ?? 0;

  set setIdCampeonato(int value) {
    idCampeonato = value;
  }

  int get getGolTimeCasa => golTimeCasa ?? 0;

  set setGolTimeCasa(int value) {
    golTimeCasa = value;
  }

  int get getGolTimeFora => golTimeFora ?? 0;

  set setGolTimeFora(int value) {
    golTimeFora = value;
  }

}