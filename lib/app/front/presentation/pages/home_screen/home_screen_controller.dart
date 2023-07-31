import 'package:arena_soccer/app/front/presentation/components/arena_dropdown/arena_dropdown_controller.dart';
import 'package:arena_soccer/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'home_screen_controller.g.dart';

class HomeScreenController = _ControleBase with _$HomeScreenController;

abstract class _ControleBase with Store{
  @observable
  bool? isLoading = false;
  @action
  changeLoading(bool value) => isLoading = value;

  //
  @observable
  final ControllerArenaDropdownButton controllerDropDown = ControllerArenaDropdownButton(); //utilizo mobX
  @observable
  String? anoSelecionado;

  chamarPreferences() async {
    // Obter shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final String? regiaoPadrao = prefs.getString('regiaoPadrao');
    final String? anoEscolhido = prefs.getString('anoEscolhido');

    switch (regiaoPadrao.toString()) {
      case "Floresta":
          controllerDropDown.selectedItem = "Floresta";
          anoSelecionado = anoEscolhido;
        break;
      case "Santo inacio":
          controllerDropDown.selectedItem = "Santo inacio";
          anoSelecionado = anoEscolhido;
        break;
      default:
          controllerDropDown.selectedItem = "Floresta";
          anoSelecionado = anoEscolhido;
        break;
    }
    // print("REGIAO PADRAO:: "+cidadeSelecionada.toString());
  }

  //
  @observable
  Usuario userCurrent = Usuario();
  @observable
  String? imageDrawer;

  getUserData(userId) async {
    print("ENTROU");
    var collection = FirebaseFirestore.instance.collection("usuarios").where("idUsuario", isEqualTo: userId); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      userCurrent.nome = doc["nome"];
      userCurrent.email = doc["email"];
      userCurrent.timeQueTorce = doc["time"];
      // print("TESTE TIME -> "+doc["nome"]);
      // print("TESTE TIME -> "+doc["time"]);
      // print("TESTE TIME -> "+doc["email"]);
      print("TESTE TIME -> "+userCurrent.nome.toString());
      
    }

    var collectionTeam = FirebaseFirestore.instance.collection("times").where("nome", isEqualTo: userCurrent.timeQueTorce); //cria instancia

    var resultadoTeam = await collectionTeam.get(); //busca os dados uma vez

    for(var doc in resultadoTeam.docs){
      // userCurrent = doc["urlImagem"];
      print("TESTE TIME -> "+doc["urlImagem"].toString());
      imageDrawer = doc["urlImagem"].toString();
      // print("TESTE TIME -> "+userCurrent.nome.toString());
      
    }

  }
  
}