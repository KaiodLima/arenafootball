import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../model/Jogador.dart';
import '../../../../../model/Time.dart';

class ExibirAssistencias extends StatefulWidget {
  final String? regiao;

  ExibirAssistencias({
    Key? key,
    this.regiao,
  }) : super(key: key);

  @override
  State<ExibirAssistencias> createState() => _ExibirAssistenciasState();
}

class _ExibirAssistenciasState extends State<ExibirAssistencias> {

  @override
  void initState() {
    super.initState();

    _recuperarTimes();
    _recuperarJogadores();
  }
  
  @override
  Widget build(BuildContext context) {
    print("TESTE REGIAO ASSISTENCIAS -> "+widget.regiao.toString());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 67, 28),
        title: const Text("ASSISTENCIAS"),//
      ),
      body: ListView.builder(
        itemCount: listaJogadoresFirebase.length,
                  itemBuilder: (context, index) {
                    return Visibility(
                      visible: listaJogadoresFirebase[index].getNAssistencias > 0,
                      child: GestureDetector(
                        onTap: () {
                          //quando um jogador é clicado:
                          //_chamarStatusJogador(jogador[index].id.toString());
                        },
                        child: Column(
                          children: [
                            /*Container(
                            height: 100,
                            decoration: BoxDecoration(
                              //border: Border.all(color: Colors.green),
                              image: DecorationImage(
                                fit: BoxFit.scaleDown,
                                image: NetworkImage(time[index].get("urlImagem").toString()),
                              ),
                            ),
                          ),*/
                            ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              trailing: const Icon(
                                Icons.more_vert,
                                size: 30,
                              ), //adiciona ícone no final
                              //add imagem de contato
                              leading: listaJogadoresFirebase[index].getUrlImagem.isNotEmpty
                              ? CircleAvatar(
                                  maxRadius: 30,
                                  backgroundColor:const Color.fromARGB(255, 134, 143, 134),
                                  backgroundImage: NetworkImage(listaJogadoresFirebase[index].getUrlImagem.toString())
                                )
                              : const CircleAvatar(
                                  maxRadius: 30,
                                  backgroundColor: Color.fromARGB(255, 134, 143, 134),
                                  backgroundImage: AssetImage("lib/assets/images/avatar.png",),
                                ),
                              title: Text(
                                listaJogadoresFirebase[index].getNome, //recuperar nome jogador
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 110, 7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              subtitle: Text("Assistências: "+listaJogadoresFirebase[index].getNAssistencias.toString()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: const Color.fromARGB(255, 27, 67, 28),
    //     title: const Text("ASSISTENCIAS"),//
    //   ),
    //   body: StreamBuilder<QuerySnapshot>(
    //     //recupera os dados toda vez que o banco é modificado
    //     stream: FirebaseFirestore.instance
    //         .collection("jogadores")
    //         .where("nAssistencias", isGreaterThanOrEqualTo: 1).orderBy("nAssistencias", descending: true)
    //         .snapshots(), //passa uma stream de dados
    //     builder: (context, snapshot) {
    //       //verificação de estado
    //       switch (snapshot.connectionState) {
    //         case ConnectionState.none:
    //         case ConnectionState.waiting:
    //           return const Center(
    //             child: CircularProgressIndicator(),
    //           );
    //         default:
    //           List<DocumentSnapshot> jogador = snapshot.data!.docs;

    //           if (jogador.isEmpty) {
    //             return const Center(
    //               child: Text("Jogadores ainda não registrados!", style: TextStyle(fontSize: 18),),
    //             );
    //           } else {
    //             return ListView.builder(
    //               itemCount: jogador.length,
    //               itemBuilder: (context, index) {
    //                 //monta interface da noticia
    //                 return GestureDetector(
    //                   onTap: () {
    //                     //quando um jogador é clicado:
    //                     //_chamarStatusJogador(jogador[index].id.toString());
    //                   },
    //                   child: Column(
    //                     children: [
    //                       /*Container(
    //                       height: 100,
    //                       decoration: BoxDecoration(
    //                         //border: Border.all(color: Colors.green),
    //                         image: DecorationImage(
    //                           fit: BoxFit.scaleDown,
    //                           image: NetworkImage(time[index].get("urlImagem").toString()),
    //                         ),
    //                       ),
    //                     ),*/
    //                       ListTile(
    //                         contentPadding: const EdgeInsets.all(16),
    //                         trailing: const Icon(
    //                           Icons.more_vert,
    //                           size: 30,
    //                         ), //adiciona ícone no final
    //                         //add imagem de contato
    //                         leading: CircleAvatar(
    //                           maxRadius: 30,
    //                           backgroundColor:
    //                               const Color.fromARGB(255, 134, 143, 134),
    //                           backgroundImage: NetworkImage(jogador[index].get("nome").toString()),
    //                         ),
    //                         title: Text(
    //                           jogador[index].get("nome"), //recuperar título da noticia
    //                           textAlign: TextAlign.start,
    //                           style: const TextStyle(
    //                               color: Color.fromARGB(255, 4, 110, 7),
    //                               fontWeight: FontWeight.bold,
    //                               fontSize: 20),
    //                         ),
    //                         subtitle: Text("Assistencias: "+jogador[index].get("nAssistencias").toString()), //recuperar nome do jogador
    //                       ),
    //                     ],
    //                   ),
    //                 );
    //               },
    //             );
    //           }
    //       }
    //     },
    //   ),
    // );
  }

  //recuperar times
  final List<Time> listaTimesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimes() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: widget.regiao); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    for(var doc in resultado.docs){
      // print("TESTE REGIAO -> "+doc["nome"]);
      setState(() {
        Time aux = Time(
          nome: doc["nome"],
          descricao: doc["descricao"],
          urlImagem: doc["urlImagem"],
          fkCompeticao: doc["fk_competicao"],
        );
        // print("TESTE -> "+doc["nome"].toString());
        listaTimesFirebase.add(aux); //adiciona em uma list
        
      });
      
    }
    // print("TESTE -> "+listaTimesFirebase.first.getNome.toString());

  }

  //recuperar jogadores
  final List<Jogador> listaJogadoresFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarJogadores() async {
    var collection = FirebaseFirestore.instance.collection("jogadores"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    for(var doc in resultado.docs){
      // print("TESTE REGIAO -> "+doc["nome"]);
      setState(() {
        Jogador aux = Jogador(
          nome: doc["nome"],
          time: doc["time"],
          urlImagem: doc["urlImagem"],
          nGols: doc["nGols"],
          nAssistencias: doc["nAssistencias"]
        );

        for (var i = 0; i < listaTimesFirebase.length; i++) {
          if(aux.getTime.toString() == listaTimesFirebase[i].getNome.toString()){
            // print("TESTE -> "+aux.getNome.toString());
            listaJogadoresFirebase.add(aux); //adiciona em uma list
          }
        }
        
      });
      
    }
    setState(() {
      listaJogadoresFirebase.sort((a, b) => b.nAssistencias!.compareTo(a.nAssistencias!));
    });
    // print("TESTE -> "+listaJogadoresFirebase.first.getNome.toString());

  }
}