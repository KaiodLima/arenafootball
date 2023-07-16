import 'package:arena_soccer/model/Partida.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
part 'register_new_match_controller.g.dart';

class RegisterNewMatchController = _ControleBase with _$RegisterNewMatchController;

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
  TextEditingController controllerIdPartida = TextEditingController();
  @observable
  TextEditingController controllerTimeC = TextEditingController();
  @observable
  TextEditingController controllerTimeF = TextEditingController();
  @observable
  TextEditingController controllerHorario = TextEditingController();
  @observable
  TextEditingController controllerLocal = TextEditingController();
  @observable
  TextEditingController controllerData = TextEditingController();
  @observable
  String timeSelecionadoCasa = 'Lava Jato';
  @observable
  String timeSelecionadoFora = 'Lava Jato';
  @observable
  String cidadeSelecionada = 'Floresta';
  
  //capturar dados da partida
  criarPartida() {
    // String id_partida = idAtual.toString();
    // String id_partida = _controllerIdPartida.text;
    String timeC = timeSelecionadoCasa;
    String timeF = timeSelecionadoFora;
    // String timeC = _controllerTimeC.text;
    // String timeF = _controllerTimeF.text;
    String horario = controllerHorario.text;
    String local = controllerLocal.text;
    String data = controllerData.text;
    int idCampeonato = buscarIdCampeonato(cidadeSelecionada);
    
    //validar campos:
    if ((timeC.isNotEmpty && timeC.length >= 3) && (timeF.isNotEmpty && timeF.length >= 3)) {
      //criar partida
      Partida partida = Partida(
        // idPartida: id_partida, 
        timeC: timeC, 
        timeF: timeF, 
        horario: horario, 
        local: local, 
        data: data,
        fkPartida: cidadeSelecionada,
        idCampeonato: idCampeonato,
      );

      //salvar informações do jogador no banco de dados
      _cadastrarFirebase(partida);
    } else {      
      chamarSnackBar("Preencha todos os campos!!!", context);
    }
  }

  int buscarIdCampeonato(String regiao){
    switch (regiao) {
      case "Floresta":
        return 1;
      case "Santo inacio":
        return 2;
      default:
        return 0;
    }
  }

  //cadastrar informações do usuário no banco de dados
  Future<void> _cadastrarFirebase(Partida partida) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    
    var addedDocRef = await db.collection("partidas").add({
      "id_partida": "",
      "dataRegistro": FieldValue.serverTimestamp(),

      "timeC": partida.timeC,
      "timeF": partida.timeF,
      "horario": partida.horario,
      "id_campeonato":partida.getIdCampeonato,
      "local": partida.local,
      "data": partida.data,

      "golTimeCasa": 0,
      "golTimeFora": 0,

      "quantidadeVotos": "",
      "tituloVotacao": "",
      "votacao": "false",
      "melhorJogador": "",

      "fk_competicao":partida.fkPartida,

    });
    
    db.collection("partidas").doc(addedDocRef.id).set({
      "id_partida": addedDocRef.id,
      "dataRegistro": FieldValue.serverTimestamp(),

      "timeC": partida.timeC,
      "timeF": partida.timeF,
      "horario": partida.horario,
      "id_campeonato":partida.getIdCampeonato,
      "local": partida.local,
      "data": partida.data,

      "golTimeCasa": 0,
      "golTimeFora": 0,

      "quantidadeVotos": "",
      "tituloVotacao": "",
      "votacao": "false",
      "melhorJogador": "",

      "fk_competicao":partida.fkPartida,

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

  //recuperar nomes dos times no firebase
  ObservableList<String> listaTimesFirebaseCasa = ObservableList<String>();
  // List<String> listaTimesFirebaseCasa = []; //precisa estar assinalada com o final pra os valores persistirem
  recuperarTimesCasa() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      listaTimesFirebaseCasa.add(doc["nome"]); //adiciona em uma list
      
    }
    timeSelecionadoCasa = listaTimesFirebaseCasa.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

  //recuperar nomes dos times no firebase
  ObservableList<String> listaTimesFirebaseFora = ObservableList<String>();
  // List<String> listaTimesFirebaseFora = []; //precisa estar assinalada com o final pra os valores persistirem
  recuperarTimesFora() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      listaTimesFirebaseFora.add(doc["nome"]); //adiciona em uma list
      
    }
    timeSelecionadoFora = listaTimesFirebaseFora.last; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());    

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
}