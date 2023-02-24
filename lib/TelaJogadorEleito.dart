import 'package:flutter/material.dart';

class TelaJogadorEleito extends StatefulWidget {
  String? nomeJogador; //recebe a variável enviada da outra tela
  String? quantidadeVotos;

  TelaJogadorEleito(this.nomeJogador, this.quantidadeVotos); //construtor

  @override
  State<TelaJogadorEleito> createState() => _TelaJogadorEleitoState();
}

class _TelaJogadorEleitoState extends State<TelaJogadorEleito> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("Eleito o melhor jogador da partida: "+ widget.nomeJogador.toString(), style: TextStyle(fontSize: 18),),
          ),
          SizedBox(height: 10,),
          Center(
            child: Text("Número de votos: "+ widget.quantidadeVotos.toString(), style: TextStyle(fontSize: 16),),
          ),
          SizedBox(height: 10,),
          TextButton(
            child: Text("VOLTAR", style: TextStyle(fontSize: 18),),
            onPressed: (){
              Navigator.pop(context); //fecha a tela atual e abre uma nova
            },
          ),
        ],
      ),
    );
  }
}