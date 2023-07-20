import 'package:arena_soccer/app/front/presentation/components/arena_dropdown/arena_dropdown_controller.dart';
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
  
}