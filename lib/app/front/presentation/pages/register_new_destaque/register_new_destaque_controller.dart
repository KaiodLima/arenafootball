import 'package:arena_soccer/model/Destaque.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
part 'register_new_destaque_controller.g.dart';

class RegisterNewDestaqueController = _ControleBase with _$RegisterNewDestaqueController;

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
  TextEditingController controllerTitle = TextEditingController();
  @observable
  TextEditingController controllerLink = TextEditingController();
  @observable
  TextEditingController controllerExibir = TextEditingController();
  
  @observable
  String? urlDownloadImage;

  createNewDestaque(context) {
    String titulo = controllerTitle.text;
    String urlImagem = urlDownloadImage?.toString() ?? "";
    String link = controllerLink.text;
    // String exibir= _controllerExibir.text;
    String? exibir = isShow ?? "false";
    String? priority = listaPriorityFirebase.first;
    //validar campos:
    if (titulo.isNotEmpty && titulo.length >= 3) {
      //criar destaque
      Destaque destaque = Destaque(
        titulo: titulo,
        urlImagem: urlImagem,
        link: link,
        exibir: exibir,
        priority: priority,
      );

      _cadastrarFirebase(destaque);
    
    } else {
      //print("Preencha o campo NOME!!!");
      chamarSnackBar("Preencha o campo TÍTULO!!!", context);
    }
  }

  Future<void> _cadastrarFirebase(Destaque destaque) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    
    var addedDocRef = await db.collection("destaques").add({
      "id": "",
      "title": destaque.titulo,
      "link": destaque.link,
      "urlImagem": destaque.urlImagem,
      "exibir": destaque.exibir,
      "priority": destaque.priority,
    });

    db.collection("destaques").doc(addedDocRef.id).set({
      "id": addedDocRef.id,
      "title": destaque.titulo,
      "link": destaque.link,
      "urlImagem": destaque.urlImagem,
      "exibir": destaque.exibir,
      "priority": destaque.priority,
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

  String prioritySelecionada = '1';
  _chamarDropDownPriority(context){

    return Container(
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: prioritySelecionada,
              icon: const Icon(Icons.change_circle_outlined, color: Colors.green,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 18,),
              // underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              dropdownColor: Colors.green,
              onChanged: (String? newValue) {
                prioritySelecionada = newValue!;
              },

              items: listaPriorityFirebase.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

  //recuperar quantidade de destaques cadastrados no banco
  final List<String> listaPriorityFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  recuperarDestaquesPriority() async {
    var collection = FirebaseFirestore.instance.collection("destaques"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    for(var doc in resultado.docs){
      // print("TESTE REGIAO -> "+doc["nome"]);
      listaPriorityFirebase.add(doc["priority"]); //adiciona em uma list
      
    }
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }


}