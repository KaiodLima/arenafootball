import 'dart:io';

import 'package:arena_soccer/model/Noticia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;
part 'news_edit_screen_controller.g.dart';

class NewsEditScreenController = _ControleBase with _$NewsEditScreenController;

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
  TextEditingController controllerIdNoticia = TextEditingController();
  @observable
  Timestamp? controllerData;
  @observable
  TextEditingController controllerTitulo = TextEditingController();
  @observable
  TextEditingController controllerDescricao = TextEditingController();
  @observable
  TextEditingController controllerUrlImagem = TextEditingController();
  @observable
  TextEditingController controllerLink = TextEditingController();
  @observable
  TextEditingController controllerExibir = TextEditingController();
  @observable
  TextEditingController controllerTag = TextEditingController();
  @observable
  String cidadeSelecionada = 'Floresta';
  @observable
  File? imageFile;
  @observable
  String? urlDownloadImage;

  //
  @action
  iniciarDados(dataNews){
    // int index = widget.index ?? 0;
    controllerIdNoticia.text = dataNews!.id.toString();
    controllerData = dataNews!.get("data");
    controllerTitulo.text = dataNews!.get("titulo");
    controllerDescricao.text = dataNews!.get("descricao");
    controllerUrlImagem.text = dataNews!.get("urlImagem");
    controllerLink.text = dataNews!.get("link");
    controllerExibir.text = dataNews!.get("exibir");
    controllerTag.text = dataNews!.get("tag");

  }

  //cadastrar informações do usuário no banco de dados
  Future<void> _salvarFirebase(Noticia noticia) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    //aqui estou usando o uid do usuário logado pra salvar como  id na colection de dados
    db.collection("noticias").doc(noticia.idNoticia.toString()).set({
      "id": noticia.idNoticia,
      "data": noticia.data,

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

  }

  //capturar dados da partida
  atualizarNoticia(context) {
    String idNoticia = controllerIdNoticia.text;
    Timestamp? data = controllerData;
    String titulo = controllerTitulo.text;
    String descricao = controllerDescricao.text;
    String urlImagem = imageFile != null ? urlDownloadImage!.toString() : controllerUrlImagem.text;
    String link = controllerLink.text;
    String exibir = controllerExibir.text;
    String fkCompeticao = cidadeSelecionada;
    String tag = controllerTag.text;
    
    //validar campos:
    if (
    // (titulo.isNotEmpty && titulo.length >= 3) && 
    // (descricao.isNotEmpty && descricao.length >= 3) &&
    // (urlImagem.isNotEmpty && urlImagem.length >= 3) &&
    (exibir.isNotEmpty)) {
      //criar partida
      Noticia noticia = Noticia(
        idNoticia: idNoticia, 
        data: data,
        titulo: titulo,
        descricao: descricao,
        urlImagem: urlImagem,
        link: link, 
        exibir: exibir,
        timeCasa: "", 
        timeFora: "", 
        golTimeCasa: "", 
        golTimeFora: "", 
        tag: tag, 
        fkCompeticao: fkCompeticao,
        );        

      //salvar informações do jogador no banco de dados
      _salvarFirebase(noticia);
    } else {      
      chamarSnackBar("Preencha todos os campos!!!", context);
    }
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

  //

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

  //

  //Teste camera:
  @observable
  PickedFile? _image;
  
  Future recoveryImage(bool isCamera) async{
    PickedFile? imageSelected;
    var imageTemporary;
    if(isCamera) {
      _image = await ImagePicker.platform.pickImage(source: ImageSource.camera);
      imageTemporary = File(_image!.path);
    } else {
      print("GALERY!!!");
      _image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
      imageTemporary = File(_image!.path);
    }
 
    imageFile = imageTemporary;
    _image = imageSelected;
 
  }
  
  Future<void> uploadPhoto(File Image, String fileName) async {
    try {
      var result = await storage.FirebaseStorage.instance.ref("noticias/$fileName").putFile(Image);

      final urlDownload = await result.ref.getDownloadURL();
        urlDownloadImage = urlDownload;
        print("TESTE CAMERA URL: "+urlDownloadImage.toString());
    } on core.FirebaseException catch(e) {
      print("Error: ${e.code}");
 
    }
  }
}