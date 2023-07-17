import 'dart:io';

import 'package:arena_soccer/model/Noticia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
part 'publicar_anuncio_screen_controller.g.dart';

class PublicCardScreenController = _ControleBase with _$PublicCardScreenController;

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
  TextEditingController controllerLink = TextEditingController();
  @observable
  TextEditingController controllerDescricao = TextEditingController();
  @observable
  TextEditingController controllerTitulo = TextEditingController();
  @observable
  TextEditingController controllerExibir = TextEditingController();
  @observable
  String cidadeSelecionada = 'Floresta';
  @observable
  String? urlDownloadImage;

  //noticia e anuncio usam o mesmo model
  criarAnuncio(context) {
    // int idNoticia = idAtual;
    String titulo = controllerTitulo.text;
    String descricao = controllerDescricao.text;
    String urlImagem = urlDownloadImage?.toString() ?? "";
    String link = controllerLink.text;
    // String exibir = _controllerExibir.text;
    String? exibir = isShow;

    String fkCompeticao = cidadeSelecionada;
    String golCasa = "";
    String golFora = "";
    String timeCasa = "";
    String timeFora = "";
    String tag = "publicidade";

    //validar campos:
    if (exibir != null && exibir.isNotEmpty) {
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
      _cadastrarFirebase(noticia);
    } else {      
      chamarSnackBar("Preencha todos os campos!!!", context);
      print("TESTE Exibir::: "+exibir.toString());
    }
  }

  //cadastrar informações no banco de dados
  Future<void> _cadastrarFirebase(Noticia noticia) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    //aqui estou usando o uid do usuário logado pra salvar como  id na colection de dados
    var addedDocRef = await db.collection("noticias").add({
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

    print("TESTE TITULO::: "+noticia.titulo.toString());

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

  //Teste camera:
  @observable
  PickedFile? _image;
  @observable
  File? imageFile;
  
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
    print("ENTROU!!! "+Image.uri.toString());
    try {
      var result = await storage.FirebaseStorage.instance.ref("noticias/$fileName").putFile(Image);
      print("RESULT!!! "+result.toString());
      final urlDownload = await result.ref.getDownloadURL();
        urlDownloadImage = urlDownload;
        print("TESTE CAMERA URL: "+urlDownloadImage.toString());
    } on core.FirebaseException catch(e) {
      print("Error: ${e.code}");
 
    }
  }

}