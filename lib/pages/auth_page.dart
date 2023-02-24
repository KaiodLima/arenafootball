import 'package:arena_soccer/components/auth_form.dart';
import 'package:arena_soccer/core/models/auth_form_data.dart';
import 'package:flutter/material.dart';

import '../core/services/auth/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLoading =
      false; //verifica se a tela de "loading..."" deve ser carregada ou não

  //função que recebe as informações enviadas do componente filho
  Future<void> _handleSubmit(AuthFormData formData) async {
    try {
      setState(() => isLoading = true);
      //verifica se a tela atual é Login ou Signup
      if (formData.isLogin) {
        //Login:
        await AuthService().login(formData.email, formData.password);
      } else {
        print("signup");
        //Signup:
        await AuthService().signup(
            formData.name, formData.email, formData.password, formData.image);
      }
    } catch (error) {
      //tratar erro:

    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: AuthForm(
                onSubmit: _handleSubmit,
              ),
            ),
          ),
          if (isLoading)
            Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
