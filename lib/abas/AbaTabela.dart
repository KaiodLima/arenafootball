import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../MelhorDaPartida.dart';
import '../TelaJogadorEleito.dart';
import '../model/Usuario.dart';
import '../presentation/competitions/pages/show_table_competition.dart';
import '../presentation/competitions/widget/competitions_card.dart';

class AbaTabela extends StatefulWidget {
  final String? regiao;
  Usuario? usuario;

  AbaTabela({
    Key? key,
    this.regiao,
    this.usuario
  }) : super(key: key);

  @override
  State<AbaTabela> createState() => _AbaTabelaState();
}

class _AbaTabelaState extends State<AbaTabela> {

  // chamaTelaVotacao(String timeC, String timeF, String tituloVotacao){
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => MelhorDaPartida(timeC: timeC, timeF: timeF, tituloVotacao: tituloVotacao), //passo os dois times por parâmetro
  //     ) //o outro parâmetro é a rota
  //   );
  //   //Navigator.pop(context); //fecha a tela atual e abre uma nova
  // }  

  // chamaTelaEleitoMelhor(String jogadorEleito, String quantidadeVotos){
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => TelaJogadorEleito(nomeJogador: jogadorEleito, quantidadeVotos: quantidadeVotos, timeC: "", timeF: "",), //passo os dois times por parâmetro
  //     ) //o outro parâmetro é a rota
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var aux;
    print("TESTE ::: "+widget.regiao.toString());
    if(widget.regiao != null){
      aux = FirebaseFirestore.instance.collection("campeonatos").where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados
    }else{
      aux = FirebaseFirestore.instance.collection("campeonatos").snapshots();
    }


    // return ShowTableCompetition(idCompetition: 1,);

    return StreamBuilder<QuerySnapshot>(
      //recupera os dados toda vez que o banco é modificado
      stream: aux, //passa uma stream de dados
      builder: (context, snapshot) {
        //verificação de estado
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            List<DocumentSnapshot> campeonatos = snapshot.data!.docs;

            if (campeonatos.isEmpty) {
              return const Center(
                child: Text("Nenhum registro no momento", style: TextStyle(color: Colors.white, fontSize: 20),),
              );
            } else {
              
              for (var element in campeonatos) {
                if(element.get("fk_competicao").toString() == widget.regiao.toString()){
                  return ShowTableCompetition(idCompetition: element.get("id_campeonato"), regiao: widget.regiao, usuario: widget.usuario,);
                }
              }
              return const SizedBox();
              // return ListView.builder(
              //   itemCount: campeonatos.length,
              //   itemBuilder: (context, index) {   

              //     //monta interface
              //     return GestureDetector(
              //       onTap: () {                      
              //         //quando um campeonato é clicado:
              //         Navigator.push(
              //           context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
              //           MaterialPageRoute(
              //             builder: (context) => ShowTableCompetition(idCompetition: campeonatos[index].get("id_campeonato"),),
              //           ), //o outro parâmetro é a rota
              //         );
              //         //Navigator.pop(context); //fecha a tela atual e abre uma nova
              //       },
              //       child: Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: CompetitionsCard(
              //           dataCompetition: campeonatos,
              //           index: index,
              //           title: campeonatos[index].get("titulo").toString(),
              //           urlImage: campeonatos[index].get("urlImagem").toString(),
              //         ),
              //       ),
              //       // child: Column(
              //       //   children: [
              //       //     Container(
              //       //         //height: 200, 
              //       //         padding: EdgeInsets.only(left: 10, right: 10),                           
              //       //         child: CachedNetworkImage(
              //       //           imageUrl: campeonatos[index].get("urlImagem").toString(),
              //       //           fit: BoxFit.scaleDown,
              //       //           placeholder: (context, url) => CircularProgressIndicator(),
              //       //           errorWidget: (context, url, error) => Icon(Icons.error),
              //       //         ),
              //       //     ),
              //       //     /*Container(
              //       //       height: 200,
              //       //       decoration: BoxDecoration(
              //       //         //border: Border.all(color: Colors.green),
              //       //         image: DecorationImage(
              //       //           fit: BoxFit.scaleDown,
              //       //           image: NetworkImage(campeonatos[index].get("urlImagem").toString()),
              //       //         ),
              //       //       ),
              //       //     ),*/
              //       //     ListTile(
              //       //       title: Text(
              //       //         campeonatos[index].get("titulo"), //recuperar título da noticia
              //       //         textAlign: TextAlign.start,
              //       //         style: const TextStyle(
              //       //             color: Colors.white,
              //       //             fontWeight: FontWeight.bold,
              //       //             fontSize: 20),
              //       //       ),
              //       //       //subtitle: Text(campeonatos[index].get("descricao")), //recuperar descrição da noticia
              //       //     ),
              //       //   ],
              //       // ),
              //     );
              //   },
              // );
            }
        }
      },
    );

    // return StreamBuilder<QuerySnapshot>(
    //   //recupera os dados toda vez que o banco é modificado
    //   stream: FirebaseFirestore.instance
    //       .collection("partidas").orderBy("id_partida", descending: true)
    //       .snapshots(), //passa uma stream de dados
    //   builder: (context, snapshot) {
    //     //verificação de estado
    //     switch (snapshot.connectionState) {
    //       case ConnectionState.none:
    //       case ConnectionState.waiting:
    //         return const Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       default:
    //         List<DocumentSnapshot> partida = snapshot.data!.docs;

    //         if (partida.isEmpty) {
    //           return Container(
    //             child: const Text("Vazio"),
    //           );
    //         } else {
    //           return Column(
    //             children: [
    //               TextButton(
    //                 child: Text(
    //                   "VER GRUPOS",
    //                   style: TextStyle(
    //                     color: Colors.white,
    //                   ),
    //                 ),
    //                 style: ButtonStyle(
    //                   backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
    //                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                     RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(18.0),
    //                       //side: BorderSide(color: Colors.red),
    //                     ),
    //                   ),
    //                 ),
    //                 onPressed: () {
    //                   //chamar tela de grupos
    //                   Navigator.push( context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
    //                     MaterialPageRoute(
    //                       builder: (context) => ExibirGrupos(), 
    //                     ) //o outro parâmetro é a rota
    //                   );
    //                 },
    //               ),
    //               Expanded(
    //                 child: ListView.builder(
    //                   itemCount: partida.length,
    //                   itemBuilder: (context, index) {
    //                     //monta interface da tabela
    //                     return GestureDetector(
    //                       onTap: () {
    //                         if(partida[index].get("votacao") == "true"){
    //                           //quando uma partida é clicada:
    //                           chamaTelaVotacao(partida[index].get("timeC").toString(), partida[index].get("timeF").toString(), partida[index].get("tituloVotacao").toString());
    //                         }else{
    //                           chamaTelaEleitoMelhor(partida[index].get("melhorJogador").toString(), partida[index].get("quantidadeVotos").toString());
    //                         }                          
                            
    //                       },
    //                       child: Column(
    //                         children: [
    //                           /*Container(
    //                             height: 100,
    //                             decoration: BoxDecoration(
    //                               //border: Border.all(color: Colors.green),
    //                               image: DecorationImage(
    //                                 fit: BoxFit.scaleDown,
    //                                 image: NetworkImage(time[index].get("urlImagem").toString()),
    //                               ),
    //                             ),
    //                           ),*/
    //                           ListTile(
    //                             contentPadding: EdgeInsets.all(16),
    //                             trailing: const CircleAvatar(
    //                               maxRadius: 25,
    //                               backgroundColor: Color.fromARGB(255, 45, 94, 45),
    //                               //backgroundImage: NetworkImage(partida[index].get("timeC").toString()),
    //                             ),
    //                             //add imagem de contato
    //                             leading: const CircleAvatar(
    //                               maxRadius: 25,
    //                               backgroundColor: Color.fromARGB(255, 45, 94, 45),
    //                               //backgroundImage: NetworkImage(partida[index].get("timeF").toString()),
    //                             ),
    //                             title: Text(
    //                               "${partida[index].get("timeC")} x ${partida[index].get("timeF")}", //recuperar conteúdo da partida
    //                               textAlign: TextAlign.center,
    //                               style: const TextStyle(
    //                                 color: Color.fromARGB(255, 4, 110, 7),
    //                                 fontWeight: FontWeight.bold,
    //                                 fontSize: 14,
    //                               ),
    //                             ),
    //                             subtitle: Text(
    //                               "${partida[index].get("data")} às ${partida[index].get("horario")} horas",
    //                               textAlign: TextAlign.center,
    //                             ), //recuperar descrição da partida
    //                           ),
    //                         ],
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               ),
    //             ],
    //           );

    //           /*return ListView.builder(
    //                 itemCount: noticia.length,
    //                 itemBuilder: (context, index) {
    //                   //monta interface da noticia
    //                   return ListTile(
    //                     title: Text(
    //                       noticia[index].get("titulo"), //recuperar título da noticia
    //                       textAlign: TextAlign.start,
    //                       style: const TextStyle(
    //                           color: Color.fromARGB(255, 4, 110, 7),
    //                           fontWeight: FontWeight.bold,
    //                           fontSize: 20),
    //                     ),
    //                     subtitle: Text(noticia[index].get("descricao")), //recuperar descrição da noticia
    //                   );
    //                 },
    //               );*/
    //         }
    //     }
    //   },
    // );
  }
}
