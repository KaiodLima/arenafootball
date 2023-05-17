import 'package:mobx/mobx.dart';
part 'arena_dropdown_controller.g.dart';

class ControllerArenaDropdownButton = _ControleBase with _$ControllerArenaDropdownButton;

abstract class _ControleBase with Store {
  @observable
  String? selectedItem;


}