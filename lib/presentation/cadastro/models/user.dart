import 'package:mobx/mobx.dart';
part 'user.g.dart';

class User = _UserBase with _$User;

abstract class _UserBase with Store{
  @observable
  String? nome;
  @action
  changeName(String value) => nome = value;

  @observable
  String? email;
  @action
  changeEmail(String value) => email = value;

  @observable
  String? senha;
  @action
  changeSenha(String value) => senha = value;

  //cadastro de imagem na lista de jogadores do time
  @observable
  String? imagePlayer;
  @action
  addImagePlayer(String? value) => imagePlayer = value;

  @observable
  int nGols = 0;
  @action
  setGol(int value) => nGols = value;
  @action
  addGol(){
    nGols++;
  }
  @action
  removeGol(){
    nGols--;
  }

  @observable
  int nAssistencias = 0;
  @action
  setAssistencia(int value) => nAssistencias = value;
  @action
  addAssistencia(){
    nAssistencias++;
  }
  @action
  removeAssistencia(){
    nAssistencias--;
  }

}