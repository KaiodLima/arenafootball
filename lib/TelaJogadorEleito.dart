import 'package:flutter/material.dart';

class TelaJogadorEleito extends StatefulWidget {
  String? nomeJogador; //recebe a variável enviada da outra tela
  String? quantidadeVotos;
  // String timeC; //recebe a variável enviada da outra tela
  // String timeF;

  TelaJogadorEleito({
    this.nomeJogador,
    this.quantidadeVotos,
    // required this.timeC,
    // required this.timeF,
  }); //construtor

  @override
  State<TelaJogadorEleito> createState() => _TelaJogadorEleitoState();
}

class _TelaJogadorEleitoState extends State<TelaJogadorEleito> {
  // String? jogadorMaisVotado;
  // String? nVotos;

  //recuperar votos
  // _calcularVotos() async {
  //   var collection = FirebaseFirestore.instance.collection("melhorjogador${widget.timeC}${widget.timeF}"); //cria instancia

  //   var resultado = await collection.get(); //busca os dados uma vez    

  //   var fieldValueMap = Map<String, int>();
  //   for (var value in resultado.docs) {
  //     var fieldValue = value["nome"] as String;
  //     if (fieldValueMap.containsKey(fieldValue)) {
  //       fieldValueMap[fieldValue] = fieldValueMap[fieldValue]! + 1;
  //     } else {
  //       fieldValueMap[fieldValue] = 1;
  //     }
  //   }

  //   var mostFrequentValue = '';
  //   var frequency = 0;
  //   fieldValueMap.forEach((key, value) {
  //     if (value > frequency) {
  //       frequency = value;
  //       mostFrequentValue = key;
  //     }
  //   });

  //   print("MAIS VOTADO: "+mostFrequentValue.toString()+" Votos: "+frequency.toString());
  //   jogadorMaisVotado = mostFrequentValue.toString();
  //   nVotos = frequency.toString();
    
  // }

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 67, 28),
      appBar: AppBar(        
        //backgroundColor: Colors.green,
        backgroundColor: const Color.fromARGB(255, 27, 67, 28),
        elevation: 0,
        title: Image.asset(
          //"lib/assets/images/ic_logo.png",
          "lib/assets/images/ic_arena.png",
          width: 110,
          height: 40,
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Eleito o melhor jogador da partida: "+ widget.nomeJogador.toString(), 
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Center(
            child: Text(
              "Número de votos: "+ widget.quantidadeVotos.toString(),
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10,),
          // TextButton(
          //   child: Text("VOLTAR", style: TextStyle(fontSize: 18),),
          //   onPressed: (){
          //     Navigator.pop(context); //fecha a tela atual e abre uma nova
          //   },
          // ),
        ],
      ),
    );
  }
}