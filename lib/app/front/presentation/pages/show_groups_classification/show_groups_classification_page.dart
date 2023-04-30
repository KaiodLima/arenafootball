import 'package:arena_soccer/app/front/presentation/pages/show_assistance_leader/ExibirAssistencias.dart';
import 'package:arena_soccer/app/front/presentation/pages/show_soccer_scorers/ExibirArtilheiros.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ShowGroupsClassificationPage extends StatefulWidget {
  final String? regiao;
  final String? ano;
  final String? grupo;

  ShowGroupsClassificationPage({
    Key? key,
    this.regiao,
    this.ano,
    this.grupo
  }) : super(key: key);

  @override
  State<ShowGroupsClassificationPage> createState() => _ShowGroupsClassificationPageState();
}

class _ShowGroupsClassificationPageState extends State<ShowGroupsClassificationPage> {

  int? anoAtual;
  getAnoAtual(){
    anoAtual = DateTime.now().year;
    print('Ano atual: $anoAtual');

  }

  @override
  void initState() {
    getAnoAtual();
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
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.sports_soccer),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExibirArtilheiros(regiao: widget.regiao, ano: widget.ano,),
                )
              );
              
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.star_border),
            onPressed: (){
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ExibirAssistencias(regiao: widget.regiao, ano: widget.ano,),
                ) 
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        //recupera os dados toda vez que o banco é modificado
        // stream: FirebaseFirestore.instance.collection("grupos").where("fk_competicao", isEqualTo: widget.regiao).snapshots(), //passa uma stream de dados
        stream: (widget.ano.toString() != anoAtual.toString())
        ? FirebaseFirestore.instance.collection("classificacao${widget.ano}").where("fk_competicao", isEqualTo: widget.regiao).where("fk_grupo", isEqualTo: widget.grupo).orderBy("pontos", descending: true).snapshots()
        : FirebaseFirestore.instance.collection("classificacao").where("fk_competicao", isEqualTo: widget.regiao).where("fk_grupo", isEqualTo: widget.grupo).orderBy("pontos", descending: true).snapshots(), //passa uma stream de dados
        builder: (context, snapshot) {
          //verificação de estado
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<DocumentSnapshot> classificacao = snapshot.data!.docs;
              if (classificacao.isEmpty) {
                return const Center(
                  child: Text("Vazio", textAlign: TextAlign.center,),
                );
              } else {

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: classificacao.length,
                    itemBuilder: (context, index){                    
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: const BorderRadius.all(Radius.circular(8))
                            ),
                            child: SizedBox(
                              height: 140,
                              width: MediaQuery.of(context).size.width*1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IntrinsicHeight(
                                        child: Container(
                                          height: 140,
                                          width: 50,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.all(Radius.circular(4)),
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "#${index+1}",
                                              style: const TextStyle(
                                                color: Colors.white, 
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                        )
                                      ),
                                      const SizedBox(width: 10,),
                                      IntrinsicHeight(
                                        child: Text(
                                          classificacao[index].get("nome"), 
                                          style: const TextStyle(color: Colors.white, fontSize: 22),
                                        ),
                                      ),
                                      const SizedBox(width: 10,),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Column(
                                                children: [
                                                  const Text(
                                                    "V",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white, fontSize: 24,),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                    child: Text(
                                                      classificacao[index].get("vitorias").toString(), 
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(color: Colors.white, fontSize: 24),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "D",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white, fontSize: 24,),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                    child: Text(
                                                      classificacao[index].get("derrotas").toString(), 
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(color: Colors.white, fontSize: 24),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "E",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white, fontSize: 24,),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                    child: Text(
                                                      classificacao[index].get("empates").toString(), 
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(color: Colors.white, fontSize: 24),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "P",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white, fontSize: 24,),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                    child: Text(
                                                      classificacao[index].get("pontos").toString(), 
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(color: Colors.white, fontSize: 24),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10,),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width*0.35,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Column(
                                                  children: [
                                                    const Text(
                                                      "GF",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.white, fontSize: 24,),
                                                    ),
                                                    Container(
                                                      width: 30,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                                      ),
                                                      child: Text(
                                                        classificacao[index].get("gols_feitos").toString(), 
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(color: Colors.white, fontSize: 24),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 10,),
                                                Column(
                                                  children: [
                                                    const Text(
                                                      "GS",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.white, fontSize: 24,),
                                                    ),
                                                    Container(
                                                      width: 30,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                                      ),
                                                      child: Text(
                                                        classificacao[index].get("gols_sofridos").toString(), 
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(color: Colors.white, fontSize: 24),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 10,),
                                                Column(
                                                  children: [
                                                    const Text(
                                                      "SG",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.white, fontSize: 24,),
                                                    ),
                                                    Container(
                                                      width: 30,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                                      ),
                                                      child: Text(
                                                        (classificacao[index].get("gols_feitos")-classificacao[index].get("gols_sofridos")).toString(),
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(color: Colors.white, fontSize: 24),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8,),
                        ],
                      );
                    }
                  ),
                );

              }
          }
        },
      ),
    );
  }
}