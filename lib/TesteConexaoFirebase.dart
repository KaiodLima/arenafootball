import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //deslogar usuário
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  //criar/registrar usuário
  criarUsuario() async {    
    FirebaseAuth _auth = await FirebaseAuth.instance; //cria uma instancia do objeto de autenticação    

    String email = "teste@teste.com";
    String senha = "123456";

    //método responsável por cria um acesso para autenticação
    _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
      ).then(
        //retorna uma instancia do usuário/objeto criado
        (fireBaseUser){
          print("Usuário criado com Sucesso!");
        }
      ).catchError(
        (error){
          print("Erro: "+error);
        }
      );

  }

  //logar usuário na aplicação
  Future<void> login() async {
    FirebaseAuth auth = await FirebaseAuth.instance;

    String email = "teste@teste.com";
    String senha = "123456";

    auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    ).then(
      //retorna uma instancia do usuário/objeto criado
      (fireBaseUser){
        print("Usuário logado com Sucesso!");
      }
    ).catchError(
      (error){
        print("Erro: "+error);
      }
    );

  }


  //cadastrar
  Future<void> cadastrar() async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    
    db.collection("usuarios").add(
      {
        "nome": "Kaio Lima",
        "time": "Lava Jato",
      }
    );

  }

  String currentUser = "";
  //verificar usuário logado
  Future<void> usuarioLogado() async {
    currentUser = await FirebaseAuth.instance.currentUser!.email.toString();
  }

  @override
  Widget build(BuildContext context) {
    //iniciarFirebase();
    //cadastrar();
    //criarUsuario();
    login();
    usuarioLogado();

    return Scaffold(
      body: Center(child: Text("Usuário -> "+currentUser)),
    );
  }
}