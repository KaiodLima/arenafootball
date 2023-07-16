import 'package:arena_soccer/model/Jogador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
part 'register_new_player_controller.g.dart';

class RegisterNewPlayerController = _ControleBase with _$RegisterNewPlayerController;

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
  TextEditingController controllerNome = TextEditingController();
  @observable
  TextEditingController controllerTime = TextEditingController();
  @observable
  TextEditingController controllerUrlImagem = TextEditingController();
  @observable
  TextEditingController controllerBusca = TextEditingController();
  @observable
  TextEditingController controllerGols = TextEditingController();
  @observable
  TextEditingController controllerPasses = TextEditingController();
  @observable
  String timeSelecionado = 'Lava Jato';

  //capturar dados do novo jogador
  criarJogador(context) {
    String nomeJogador = controllerNome.text;
    //String urlImagemJogador = _controllerUrlImagem.text;
    //validar campos:
    if (nomeJogador.isNotEmpty && nomeJogador.length >= 3) {
      if (timeSelecionado.isNotEmpty) {
        //criar jogador
        Jogador jogador = Jogador(nome: nomeJogador, time: timeSelecionado, urlImagem: "");

        //salvar informações do jogador no banco de dados
        _cadastrarFirebase(jogador);
      } else {
        //print("Informe um Time!!!");
        chamarSnackBar("Informe um Time!!!", context);
      }
    } else {
      //print("Preencha o campo NOME!!!");
      chamarSnackBar("Preencha o campo NOME!!!", context);
    }
  }

  Future<void> _cadastrarFirebase(Jogador jogador) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    
    var addedDocRef = await db.collection("jogadores").add({
      "idJogador": "",
      "nome": jogador.nome,
      "time": jogador.time,
      "urlImagem": jogador.urlImagem,
      "nGols": 0,
      "nAssistencias": 0,
    });

    // print("TESTE ID::: "+addedDocRef.id.toString());

    db.collection("jogadores").doc(addedDocRef.id).set({
      "idJogador": addedDocRef.id,
      "nome": jogador.nome,
      "time": jogador.time,
      "urlImagem": jogador.urlImagem,
      "nGols": 0,
      "nAssistencias": 0,
    });

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

  //recuperar nomes das cidades no firebase
  final List<String> listaCidadesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
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

  //recuperar nomes dos time no firebase
  ObservableList<String> listaTimesFirebase = ObservableList<String>(); 
  // final List<String> listaTimesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  recuperarTimes() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez

    for (var doc in resultado.docs) {
      //print("TESTE -> " + doc["nome"]);
      listaTimesFirebase.add(doc["nome"]); //adiciona em uma list
    }
    timeSelecionado = listaTimesFirebase.first.toString();
    //print("TESTE -> "+listaTimesFirebase.toString());
  }
}