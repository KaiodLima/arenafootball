import 'package:arena_soccer/model/Time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
part 'register_new_team_controller.g.dart';

class RegisterNewTeamController = _ControleBase with _$RegisterNewTeamController;

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
  TextEditingController controllerTimeNome = TextEditingController();
  @observable
  TextEditingController controllerDescricao = TextEditingController();
  @observable
  String? urlDownloadImage;
  @observable
  int idAtual = 0;
  @observable
  String timeSelecionadoCasa = 'Lava Jato';
  @observable
  String timeSelecionadoFora = 'Lava Jato';
  @observable
  String cidadeSelecionada = 'Floresta';

  //capturar dados do time
  criarTime(context) {
    String id_time = idAtual.toString();

    String nomeTime = controllerTimeNome.text;
    String? descricaoTime = controllerDescricao.text;
    String idCampeonato = cidadeSelecionada;
    String? urlImagem = urlDownloadImage?.toString() ?? "";
    
    //validar campos:
    if ((nomeTime.isNotEmpty && nomeTime.length >= 3)) {
      //criar time:
      Time timeNovo = Time(
        idTime: id_time+"_"+nomeTime.replaceAll(" ", "_"),
        nome: nomeTime,
        descricao: descricaoTime,
        fkCompeticao: idCampeonato,
        urlImagem: urlImagem,
      );

      _cadastrarFirebase(timeNovo);
    } else {      
      chamarSnackBar("Preencha os campos obrigatórios!!!", context);
    }
  }

  //cadastrar informações no fireabase
  Future<void> _cadastrarFirebase(Time time) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    
    db.collection("times").doc(time.idTime).set({
      "id_partida": time.idTime,

      "nome": time.nome,
      "descricao": time.descricao,
      "fk_competicao": time.fkCompeticao,
      "urlImagem": time.urlImagem,

    });

    db.collection("classificacao").doc(time.idTime).set({
      "id_partida": time.idTime,

      "nome": time.nome,
      "descricao": time.descricao,
      "fk_competicao": time.fkCompeticao,
      "urlImagem": time.urlImagem,

      "vitorias": 0,
      "derrotas": 0,
      "empates": 0,
      "gols_feitos": 0,
      "gols_sofridos": 0,
      "pontos": 0,

      "fk_grupo": "",

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
  recuperarIdAtual() async {
    var collection = FirebaseFirestore.instance.collection("times"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    // for(var doc in resultado.docs){
    //   print("TESTE REGIAO -> "+doc["nome"]);
    //   setState(() {

    //   });
      
    // }
    //print("TESTE -> "+listaTimesFirebase.toString());
    // print("TESTE -> "+resultado.docs.length.toString());

    idAtual = resultado.docs.length+1;  

  }

  //recuperar nomes dos times no firebase
  ObservableList<String> listaTimesFirebaseFora = ObservableList<String>();
  // List<String> listaTimesFirebaseFora = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimesFora() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      listaTimesFirebaseFora.add(doc["nome"]); //adiciona em uma list
      
    }
    timeSelecionadoFora = listaTimesFirebaseFora.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

  //recuperar nomes dos times no firebase
  ObservableList<String> listaTimesFirebaseCasa = ObservableList<String>();
  // List<String> listaTimesFirebaseCasa = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimesCasa() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      listaTimesFirebaseCasa.add(doc["nome"]); //adiciona em uma list
      
    }
    timeSelecionadoCasa = listaTimesFirebaseCasa.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
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