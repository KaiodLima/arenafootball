import 'package:arena_soccer/app/front/presentation/pages/show_soccer_scorers/ExibirArtilheiros.dart';
import 'package:arena_soccer/app/front/presentation/pages/show_assistance_leader/ExibirAssistencias.dart';
import 'package:arena_soccer/app/front/presentation/pages/show_groups/components/groups_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExibirGrupos extends StatefulWidget {
  final String? regiao;
  
  ExibirGrupos({
    Key? key,
    this.regiao,
  }) : super(key: key);

  @override
  State<ExibirGrupos> createState() => _ExibirGruposState();
}

class _ExibirGruposState extends State<ExibirGrupos> {
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
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.sports_soccer),
            onPressed: (){
              //print("Minha Conta Clicado!");
              //chamar lista de artilheiros:
              Navigator.push(
                context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                MaterialPageRoute(
                  builder: (context) => ExibirArtilheiros(regiao: widget.regiao,),
                ) //o outro parâmetro é a rota
              );
              
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.star_border),
            onPressed: (){
              //print("Minha Conta Clicado!");
              //chamar lista de assistencias:
              Navigator.push(
                context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                MaterialPageRoute(
                  builder: (context) => ExibirAssistencias(regiao: widget.regiao,),
                ) //o outro parâmetro é a rota
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        //recupera os dados toda vez que o banco é modificado
        stream: FirebaseFirestore.instance.collection("grupos").where("fk_competicao", isEqualTo: widget.regiao).snapshots(), //passa uma stream de dados
        builder: (context, snapshot) {
          //verificação de estado
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<DocumentSnapshot> grupo = snapshot.data!.docs;

              if (grupo.isEmpty) {
                return const Center(
                  child: Text("Vazio", textAlign: TextAlign.center,),
                );
              } else {

                return GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                  ),
                  children: [
                    ...grupo.map((e) => 
                      GestureDetector(
                        onTap: (){
                          //quando um grupo é clicado:
                          // print("GRUPO CLICADO::: "+index.toString());
                        },
                        child: GridTile(
                          child: GroupCards(
                            groupCompetition: e,
                            title: e.get("descricao"),
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                // return GridView.builder(
                //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 2,
                //     childAspectRatio: 0.65,
                //   ),
                //   itemCount: grupo.length,
                //   itemBuilder: (context, index){                    
                //     return GestureDetector(
                //       onTap: (){
                //         //quando um grupo é clicado:
                //         // print("GRUPO CLICADO::: "+index.toString());
                //       },
                //       child: GridTile(
                //         child: GroupCards(
                //               groupCompetition: grupo,
                //               index: index,
                //               title: grupo[index].get("descricao"),
                //             ),
                //       ),
                //     );
                //   }
                // );

                // return ListView.builder(
                //   itemCount: grupo.length,
                //   itemBuilder: (context, index) {
                //     //monta interface da noticia
                //     return GestureDetector(
                //       onTap: () {
                //         //quando um grupo é clicado:
                        
                //       },
                //       child: GridView.count(
                //           primary: false,
                //           padding: const EdgeInsets.all(20),
                //           crossAxisSpacing: 10,
                //           mainAxisSpacing: 10,
                //           crossAxisCount: 2,
                //           children: [
                //             GroupCards(
                //               groupCompetition: grupo,
                //               index: index,
                //               title: grupo[index].get("descricao"),
                //             ),
                //           ],
                //         ),
                //       // child: Column(
                //       //   mainAxisAlignment: MainAxisAlignment.center,
                //       //   crossAxisAlignment: CrossAxisAlignment.stretch,
                //       //   children: [
                //       //     /*Container(
                //       //     height: 100,
                //       //     decoration: BoxDecoration(
                //       //       //border: Border.all(color: Colors.green),
                //       //       image: DecorationImage(
                //       //         fit: BoxFit.scaleDown,
                //       //         image: NetworkImage(time[index].get("urlImagem").toString()),
                //       //       ),
                //       //     ),
                //       //   ),*/
                //       //   // Padding(
                //       //   //   padding: const EdgeInsets.only(right: 12, left: 10, top: 10),
                //       //   //   child: Text("${grupo[index].get("descricao")}", //recuperar título da noticia
                //       //   //         textAlign: TextAlign.start,
                //       //   //         style: const TextStyle(
                //       //   //             color: Color.fromARGB(255, 4, 110, 7),
                //       //   //             fontWeight: FontWeight.bold,
                //       //   //             fontSize: 20),
                //       //   //       ),
                //       //   // ), //recuperar título do grupo
                //       //   // Row(
                //       //   //   children: [
                //       //   //     Container(
                //       //   //       margin: EdgeInsets.all(10),
                //       //   //       child: GroupCards(
                //       //   //         groupCompetition: grupo,
                //       //   //         index: index,
                //       //   //         title: grupo[index].get("descricao"),
                //       //   //       ),
                //       //   //     ),
                //       //       // Container(
                //       //       //   margin: EdgeInsets.all(10),
                //       //       //   child: GroupCards(
                //       //       //     groupCompetition: grupo,
                //       //       //     index: index+1,
                //       //       //     title: grupo[index+1].get("descricao"),
                //       //       //   ),
                //       //       // ),
                //       //       // Container(
                //       //       //   width: MediaQuery.of(context).size.width * 0.45, // retorna o tamanho da largura da tela
                //       //       //   margin: EdgeInsets.all(10),
                //       //       //   decoration: BoxDecoration(
                //       //       //     border: Border.all(color: Colors.green),
                //       //       //     borderRadius: BorderRadius.all(Radius.circular(8)),
                //       //       //   ),
                //       //       //   child: ListTile(
                //       //       //     contentPadding: EdgeInsets.all(16),
                //       //       //     //trailing: , //adiciona ícone no final                              
                //       //       //     //leading: , //add imagem de contato
                //       //       //     title: Text(
                //       //       //       "${grupo[index].get("time1")}\n\n${grupo[index].get("time2")}\n\n${grupo[index].get("time3")}\n\n${grupo[index].get("time4")}", //recuperar título da noticia
                //       //       //       textAlign: TextAlign.start,
                //       //       //       style: const TextStyle(                                  
                //       //       //           color: Color.fromARGB(255, 4, 110, 7),
                //       //       //           fontWeight: FontWeight.bold,
                //       //       //           fontSize: 20),
                //       //       //     ),
                //       //       //     //subtitle: Text("${grupo[index].get("descricaoT1")}\n${grupo[index].get("descricaoT2")}\n${grupo[index].get("descricaoT3")}\n${grupo[index].get("descricaoT4")}\n", textAlign: TextAlign.end,), //recuperar nome do jogador
                //       //       //   ),
                //       //       // ),
                //       //       // Container(   
                //       //       //   width: MediaQuery.of(context).size.width * 0.40, // retorna o tamanho da largura da tela
                //       //       //   margin: EdgeInsets.all(10),
                //       //       //   decoration: BoxDecoration(
                //       //       //     border: Border.all(color: Colors.green),
                //       //       //     borderRadius: BorderRadius.all(Radius.circular(8)),
                //       //       //   ),
                //       //       //   child: ListTile(
                //       //       //     contentPadding: EdgeInsets.all(16),
                //       //       //     //trailing: , //adiciona ícone no final                              
                //       //       //     //leading: , //add imagem de contato
                //       //       //     title: Text(
                //       //       //       "${grupo[index].get("descricaoT1")}\n\n${grupo[index].get("descricaoT2")}\n\n${grupo[index].get("descricaoT3")}\n\n${grupo[index].get("descricaoT4")}", //recuperar título da noticia
                //       //       //       textAlign: TextAlign.start,
                //       //       //       style: const TextStyle(                                  
                //       //       //           color: Color.fromARGB(255, 4, 110, 7),
                //       //       //           fontWeight: FontWeight.bold,
                //       //       //           fontSize: 20),
                //       //       //     ),
                //       //       //     //subtitle: Text("${grupo[index].get("descricaoT1")}\n${grupo[index].get("descricaoT2")}\n${grupo[index].get("descricaoT3")}\n${grupo[index].get("descricaoT4")}\n", textAlign: TextAlign.end,), //recuperar nome do jogador
                //       //       //   ),
                //       //       // ),
                //       //   //   ],
                //       //   // ),
                //       //   // // const Padding(
                //       //   // //     padding: EdgeInsets.only(right: 10, left: 10, bottom: 16),
                //       //   // //     child: Text("*A pontuação está distribuida na seguinte ordem: Vitórias - Derrotas - Empates - Gols Feitos - Gols Sofridos - Pontos."),
                //       //   // //   ),
                //       //   // ],
                //       // ),
                //     );
                //   },
                // );
              }
          }
        },
      ),
    );
  }
}