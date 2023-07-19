import 'dart:io';

import 'package:arena_soccer/model/Noticia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
part 'register_new_controller.g.dart';

class RegisterNewController = _ControleBase with _$RegisterNewController;

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

  String? urlDownloadImage;
  //capturar dados da notícia
  criarNoticia(context) {
    String titulo = title!;
    String descricao = controllerDescricao.text;
    String urlImagem = urlDownloadImage?.toString() ?? "";
    String link = controllerLink.text;
    String? exibir = isShow;
    String fkCompeticao = cidadeSelecionada;
    String tag = controllerTag.text;

    //validar campos:
    if (
      // (titulo.isNotEmpty && titulo.length >= 3) &&
      // (descricao.isNotEmpty && descricao.length >= 3) &&
      // (urlImagem.isNotEmpty && urlImagem.length >= 3) &&
      (exibir != null && exibir.isNotEmpty)) {
        //criar partida
        Noticia noticia = Noticia(
          // idNoticia: idNoticia,
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
        _cadastrarFirebase(noticia, context);
      } else {
        chamarSnackBar("Preencha todos os campos obrigatórios!!!", context);
      }
  }

  //cadastrar informações do usuário no banco de dados
  Future<void> _cadastrarFirebase(Noticia noticia, context) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;

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

    chamarSnackBar("Notícia Cadastrada com Sucesso!!!", context);
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
  @observable
  String cidadeSelecionada = 'Floresta';

  chamarDropDownCity(context) {
    return Container(
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
        value: cidadeSelecionada,
        icon: const Icon(
          Icons.change_circle_outlined,
          color: Colors.green,
        ),
        isExpanded: true,
        borderRadius: BorderRadius.circular(16),
        //elevation: 16,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        // underline: Container(height: 2, color: Colors.green,),
        underline: Container(),
        alignment: AlignmentDirectional.center,
        dropdownColor: Colors.green,
        onChanged: (String? newValue) {
          cidadeSelecionada = newValue!;
        },

        items:
            listaCidadesFirebase.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  //recuperar nomes das cidades no firebase
  @observable
  ObservableList<String> listaCidadesFirebase = ObservableList<String>();
  // final List<String> listaCidadesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem

  @action
  void adicionarString(String novaString) {
    listaCidadesFirebase.add(novaString);
  }

  recuperarCidades() async {
    var collection = FirebaseFirestore.instance.collection("competicao"); //cria instancia
    var resultado = await collection.get(); //busca os dados uma vez

    for (var doc in resultado.docs) {
      // print("TESTE REGIAO -> "+doc["nome"]);
      // listaCidadesFirebase.add(doc["nome"]); //adiciona em uma list
      adicionarString(doc["nome"]);
    }
    //print("TESTE -> "+listaTimesFirebase.toString());
  }

  //
  @observable
  PickedFile? _image;
  @observable
  File? imageFile;

  Future recoveryImage(bool isCamera) async {
    PickedFile? imageSelected;
    var imageTemporary;
    if (isCamera) {
      _image = await ImagePicker.platform.pickImage(source: ImageSource.camera);
      imageTemporary = File(_image!.path);
    } else {
      print("GALERY!!!");
      _image =
          await ImagePicker.platform.pickImage(source: ImageSource.gallery);
      imageTemporary = File(_image!.path);
    }

    imageFile = imageTemporary;
    _image = imageSelected;
  }

  Future<void> uploadPhoto(File Image, String fileName) async {
    try {
      var result = await storage.FirebaseStorage.instance
          .ref("noticias/$fileName")
          .putFile(Image);

      final urlDownload = await result.ref.getDownloadURL();
      urlDownloadImage = urlDownload;
      print("TESTE CAMERA URL: " + urlDownloadImage.toString());
    } on core.FirebaseException catch (e) {
      print("Error: ${e.code}");
    }
  }

}