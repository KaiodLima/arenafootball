import 'package:arena_soccer/presentation/cadastro/models/user.dart';
import 'package:mobx/mobx.dart';
part 'controller_cadastro.g.dart';

class ControleCadastro = _ControleBase with _$ControleCadastro;

abstract class _ControleBase with Store{
  var user = User();

  @computed
  bool get enableButton{
    return validateName() == null && validateEmail() == null && validateSenha() == null;
  }

  String? validateName(){
    if(user.nome == null || user.nome!.isEmpty){
      return "Campo obrigatório";
    }else if(user.nome!.length < 3){
      return "Seu nome de usuário deve conter no mínimo 3 caracteres";
    }
    return null;
  }

  String? validateEmail(){
    if(user.email == null || user.email!.isEmpty){
      return "Campo obrigatório";
    }else if(!user.email!.contains("@") || !user.email!.contains(".com")){
      return "Exemplo: teste@teste.com";
    }
    return null;
  }

  String? validateSenha(){
    if(user.senha == null || user.senha!.isEmpty){
      return "Campo obrigatório";
    }else if(user.senha!.length < 8){
      return "Sua senha deve conter no mínimo 8 caracteres";
    }
    return null;
  }

  @observable
  bool? isLoading = false;
  @action
  changeLoading(bool value) => isLoading = value;


}