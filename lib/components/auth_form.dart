import 'dart:io';

import 'package:arena_soccer/components/user_image_picker.dart';
import 'package:arena_soccer/core/models/auth_form_data.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(AuthFormData)
      onSubmit; //função que envia a informação para o componente pai

  const AuthForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>(); //ainda não sei pra que serve
  final _authFormData =
      AuthFormData(); //cria instancia da classe AuthFormData()

  //recupera a informação enviada do componente filho
  void _handleImagePick(File image) {
    _authFormData.image = image;
  }

  void showError(String msg) {
    //cria um alerta do tipo snackbar na tela
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }

  void _submit() {
    var isValid = _formKey.currentState?.validate() ??
        false; //ainda não sei pra que serve

    //se o formulário não for válido, não faz nada:
    if (!isValid) {
      return;
    }

    //valida se a foto foi selecionada
    if (_authFormData.image == null && _authFormData.isSigup) {
      return showError("Por favor, selecione uma imagem!");
    }

    //caso seja válido, notifica o componente pai:
    widget.onSubmit(_authFormData);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_authFormData.isSigup)
                UserImagePicker(
                  onImagePick: _handleImagePick,
                ),
              if (_authFormData.isSigup)
                TextFormField(
                  //isso resolve o bug de migração de dados dos campos do formulário
                  key: const ValueKey('name'),
                  //faz o campo nome recuperar o último valor inserido antes de alternar o modo Signup para Login
                  initialValue: _authFormData.name,
                  onChanged: (name) => _authFormData.name = name,
                  //cria uma regra de preenchimento obrigatório para o campo Nome
                  validator: (_name) {
                    final name = _name ?? '';
                    if (name.trim().length < 5) {
                      return "Seu nome de usuário deve ter pelo menos 5 caracteres!!!";
                    }
                    return null;
                  },
                  decoration:
                      const InputDecoration(labelText: "Nome de Usuário"),
                ),
              TextFormField(
                key: const ValueKey('email'),
                initialValue: _authFormData.email,
                onChanged: (email) => _authFormData.email = email,
                validator: (_email) {
                  final email = _email ?? '';
                  if (!email.contains("@")) {
                    return "Informe um e-mail válido!!!";
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: "E-mail"),
              ),
              TextFormField(
                key: const ValueKey('password'),
                obscureText: true,
                validator: (_password) {
                  final password = _password ?? '';
                  if (password.trim().length < 8) {
                    return "Sua senha deve ter pelo menos 8 caracteres!!!";
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: "Senha"),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                child: Text(_authFormData.isLogin ? "ENTRAR" : "CADASTRAR"),
                onPressed: _submit,
              ),
              TextButton(
                child: Text(_authFormData.isLogin
                    ? "Clique aqui para criar uma nova conta!"
                    : "Clique aqui se já possui um conta!"),
                onPressed: () {
                  setState(() {
                    _authFormData
                        .authToogleMode(); //alterna entre o modo Login e Signup
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
