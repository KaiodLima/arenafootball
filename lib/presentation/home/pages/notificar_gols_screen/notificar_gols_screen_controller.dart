import 'dart:io';

import 'package:arena_soccer/model/Noticia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
part 'notificar_gols_screen_controller.g.dart';

class NotificarGolsScreenController = _ControleBase with _$NotificarGolsScreenController;

abstract class _ControleBase with Store{
  @observable
  String? title;
  @action
  changeTitle(String value) => title = value;

  // @computed
  // bool get enableButton{
  //   return validateName() == null && validateEmail() == null && validateSenha() == null;
  // }

  String? validateTitle(){
    if(title == null || title!.isEmpty){
      return "Campo obrigatório";
    }else if(title!.length < 3){
      return "O título da notícia deve conter no mínimo 3 caracteres";
    }
    return null;
  }

  @observable
  String? isShow;
  @action
  changeExibition(String value) => isShow = value;

  String? validateExibition(){
    if(isShow == null || isShow!.isEmpty){
      return "Campo obrigatório";
    }else if(isShow != "true" && isShow != "false"){
      return "Preencha esse campo exatamente com true ou false";
    }
    return null;
  }

  @observable
  bool? isLoading = false;
  @action
  changeLoading(bool value) => isLoading = value;

  //
  @observable
  String cidadeSelecionada = 'Floresta';
  @observable
  String timeSelecionadoCasa = '';
  @observable
  String timeSelecionadoFora = '';
  @observable
  TextEditingController controllerGolCasa = TextEditingController();
  @observable
  TextEditingController controllerGolFora = TextEditingController();

  //capturar dados da noticia
  criarCardGol(context) {
    // int id_noticia = int.parse(_controllerId.text);
    // int idNoticia = idAtual;
    String titulo = "";
    String descricao = "";
    String urlImagem = "";
    String link = "";
    // String exibir = _controllerExibir.text;
    String exibir = "true";

    String fkCompeticao = cidadeSelecionada;
    String golCasa = controllerGolCasa.text;
    String golFora = controllerGolFora.text;
    String timeCasa = timeSelecionadoCasa;
    String timeFora = timeSelecionadoFora;
    String tag = "gol";

    print(" TESTE KAIO::: "+fkCompeticao+" "+golCasa+" "+golFora+" "+timeCasa+" "+timeFora+" "+tag);
    
    //validar campos:
    if (exibir.isNotEmpty) {
      //criar partida
      Noticia noticia = Noticia(
        titulo: titulo, 
        descricao: descricao, 
        urlImagem: urlImagem, 
        link: link, 
        exibir: exibir,
        fkCompeticao: fkCompeticao, 
        timeCasa: timeCasa, 
        timeFora: timeFora, 
        golTimeCasa: golCasa, 
        golTimeFora: golFora, 
        tag: tag,
      );        

      //salvar informações do jogador no banco de dados
      _cadastrarFirebase(noticia, context);
    } else {      
      chamarSnackBar("Preencha todos os campos!!!", context);
    }
  }

  //cadastrar informações no banco de dados
  Future<void> _cadastrarFirebase(Noticia noticia, context) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    //aqui estou usando o uid do usuário logado pra salvar como  id na colection de dados
    var addedDocRef = await  db.collection("noticias").add({
      "id": "",
      "data": FieldValue.serverTimestamp(),

      "titulo": noticia.titulo,
      "descricao": noticia.descricao,
      "urlImagem": noticia.urlImagem,
      "link": noticia.link,
      "exibir": noticia.exibir,

      "fk_competicao": noticia.fkCompeticao,
      "time_casa": noticia.timeCasa,
      "time_fora": noticia.timeFora,
      "gol_time_casa": noticia.golTimeCasa,
      "gol_time_fora": noticia.golTimeFora,
      "tag": noticia.tag

    });

    db.collection("noticias").doc(addedDocRef.id).set({
      "id": addedDocRef.id,
      "data": FieldValue.serverTimestamp(),

      "titulo": noticia.titulo,
      "descricao": noticia.descricao,
      "urlImagem": noticia.urlImagem,
      "link": noticia.link,
      "exibir": noticia.exibir,

      "fk_competicao": noticia.fkCompeticao,
      "time_casa": noticia.timeCasa,
      "time_fora": noticia.timeFora,
      "gol_time_casa": noticia.golTimeCasa,
      "gol_time_fora": noticia.golTimeFora,
      "tag": noticia.tag

    });

    chamarSnackBar("Gol registrado com Sucesso!!!", context);
  }

  //cria a snackBar com a mensagem de alerta
  var _snackBar;
  chamarSnackBar(texto, context){
    _snackBar = SnackBar(content: Text(texto),);

    if(_snackBar != null){
      ScaffoldMessenger.of(context).showSnackBar(_snackBar); //chama o snackBar 
      //limpa snackbar
      _snackBar = "";
    }
  }

  //recuperar nomes das cidades no firebase
  ObservableList<String> listaCidadesFirebase = ObservableList<String>();
  // final List<String> listaCidadesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  recuperarCidades() async {
    var collection = FirebaseFirestore.instance.collection("competicao"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    for(var doc in resultado.docs){
      // print("TESTE REGIAO -> "+doc["nome"]);
      listaCidadesFirebase.add(doc["nome"]); //adiciona em uma list
      
    }
    //print("TESTE -> "+listaTimesFirebase.toString());    
  }

  //recuperar nomes dos times no firebase
  ObservableList<String> listaTimesFirebase = ObservableList<String>();
  // List<String> listaTimesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  recuperarTimes() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez

    for(var doc in resultado.docs){
      // print("TESTE TIME -> "+doc["nome"]);
      listaTimesFirebase.add(doc["nome"]); //adiciona em uma list
      
    }
    timeSelecionadoCasa = listaTimesFirebase.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    timeSelecionadoFora = listaTimesFirebase.last;
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

}