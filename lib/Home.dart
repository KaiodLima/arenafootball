import 'package:arena_soccer/Login.dart';
import 'package:arena_soccer/abas/AbaCampeonatos.dart';
import 'package:arena_soccer/abas/AbaNoticias.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController = TabController(length: 2, vsync: this);

  //deslogar usuário
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _chamarTelaLogin();
  }
  //chamar tela de login
  _chamarTelaLogin(){
    //o pushReplacement substitui a rota atual pela próxima, ou seja, não vai haver botão volta no appbar
    Navigator.pushReplacement(
      context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
      MaterialPageRoute(
        builder: (context) => const Login(),
      ) //o outro parâmetro é a rota
    );
    //Navigator.pop(context); //fecha a tela atual e abre uma nova
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(        
        backgroundColor: Colors.green,
        title: const Text("Página Inicial"),
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          controller: _tabController,
          indicatorColor: Colors.white, //cor do indicador da tab ativa
          tabs: const [
            Tab(text: "Notícias",),
            Tab(text: "Campeonatos",)
          ]
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AbaNoticias(), //chama minha aba de notícias
          AbaCampeonatos(), //chama minha aba de campeonatos
        ],
      ),
    );
  }
}