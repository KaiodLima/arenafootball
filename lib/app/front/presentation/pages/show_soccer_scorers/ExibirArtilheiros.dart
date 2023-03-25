import 'package:arena_soccer/model/Jogador.dart';
import 'package:arena_soccer/model/Time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExibirArtilheiros extends StatefulWidget {
  final String? regiao;
  final String? ano;

  ExibirArtilheiros({
    Key? key,
    this.regiao,
    this.ano
  }) : super(key: key);

  @override
  State<ExibirArtilheiros> createState() => _ExibirArtilheirosState();
}

class _ExibirArtilheirosState extends State<ExibirArtilheiros> {

  int? anoAtual;
  getAnoAtual(){
    anoAtual = DateTime.now().year;
    print('Ano atual: $anoAtual');

  }

  @override
  void initState() {
    getAnoAtual();
    super.initState();
    _recuperarTimes();
    _recuperarJogadores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 67, 28),
        title: const Text("ARTILHARIA"),
      ),
      body: ListView.builder(
        itemCount: listaJogadoresFirebase.length,
                  itemBuilder: (context, index) {
                    return Visibility(
                      visible: listaJogadoresFirebase[index].getNGols > 0,
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
                                  backgroundImage: AssetImage("lib/assets/images/avatar.png"),
                                ),
                              title: Text(
                                listaJogadoresFirebase[index].getNome, //recuperar título da noticia
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 110, 7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              subtitle: Text("Gols: "+listaJogadoresFirebase[index].getNGols.toString()), //recuperar nome do jogador
                            ),
                          ],
                        ),
                      ),
                    );
                  },
      ),
    );
  }

  //recuperar times
  final List<Time> listaTimesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimes() async {

    if(widget.ano.toString() == anoAtual.toString()){
      var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: widget.regiao); //cria instancia
      var resultado = await collection.get();

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
    }else{
      var collection = FirebaseFirestore.instance.collection("times${widget.ano}").where("fk_competicao", isEqualTo: widget.regiao); //cria instancia
      var resultado = await collection.get();

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
    }
    
    // var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: widget.regiao); //cria instancia
    // var resultado = await collection.get(); //busca os dados uma vez

    // for(var doc in resultado.docs){
    //   // print("TESTE REGIAO -> "+doc["nome"]);
    //   setState(() {
    //     Time aux = Time(
    //       nome: doc["nome"],
    //       descricao: doc["descricao"],
    //       urlImagem: doc["urlImagem"],
    //       fkCompeticao: doc["fk_competicao"],
    //     );
    //     // print("TESTE -> "+doc["nome"].toString());
    //     listaTimesFirebase.add(aux); //adiciona em uma list
        
    //   });
      
    // }
    // print("TESTE -> "+listaTimesFirebase.first.getNome.toString());

  }

  //recuperar jogadores
  final List<Jogador> listaJogadoresFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarJogadores() async {

    if(widget.ano.toString() == anoAtual.toString()){
      var collection = FirebaseFirestore.instance.collection("jogadores");
      var resultado = await collection.get();

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
        listaJogadoresFirebase.sort((a, b) => b.nGols!.compareTo(a.nGols!));
      });
    }else{
      var collection = FirebaseFirestore.instance.collection("jogadores${widget.ano}");
      var resultado = await collection.get();

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
        listaJogadoresFirebase.sort((a, b) => b.nGols!.compareTo(a.nGols!));
      });
    }

    // var collection = FirebaseFirestore.instance.collection("jogadores"); //cria instancia
    // var resultado = await collection.get(); //busca os dados uma vez

    // for(var doc in resultado.docs){
    //   // print("TESTE REGIAO -> "+doc["nome"]);
    //   setState(() {
    //     Jogador aux = Jogador(
    //       nome: doc["nome"],
    //       time: doc["time"],
    //       urlImagem: doc["urlImagem"],
    //       nGols: doc["nGols"],
    //       nAssistencias: doc["nAssistencias"]
    //     );

    //     for (var i = 0; i < listaTimesFirebase.length; i++) {
    //       if(aux.getTime.toString() == listaTimesFirebase[i].getNome.toString()){
    //         // print("TESTE -> "+aux.getNome.toString());
    //         listaJogadoresFirebase.add(aux); //adiciona em uma list
    //       }
    //     }
        
    //   });
      
    // }
    // setState(() {
    //   listaJogadoresFirebase.sort((a, b) => b.nGols!.compareTo(a.nGols!));
    // });
    // print("TESTE -> "+listaJogadoresFirebase.first.getNome.toString());

  }
}