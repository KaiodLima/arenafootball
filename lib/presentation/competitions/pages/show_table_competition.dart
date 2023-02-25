import 'dart:ffi';

import 'package:arena_soccer/ExibirGrupos.dart';
import 'package:arena_soccer/MelhorDaPartida.dart';
import 'package:arena_soccer/TelaJogadorEleito.dart';
import 'package:arena_soccer/model/Partida.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../ExibirArtilheiros.dart';
import '../../../ExibirAssistencias.dart';
import '../../../model/Usuario.dart';


class ShowTableCompetition extends StatefulWidget {
  final int? idCompetition; //recebe a variável enviada da outra tela
  final String? regiao;
  Usuario? usuario;

  ShowTableCompetition({ 
    Key? key,
    this.idCompetition,
    this.regiao,
    this.usuario
  }) : super(key: key);

  @override
  State<ShowTableCompetition> createState() => _ShowTableCompetitionState();
}

class _ShowTableCompetitionState extends State<ShowTableCompetition> {

  chamaTelaVotacao(String timeC, String timeF, String tituloVotacao){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MelhorDaPartida(timeC: timeC, timeF: timeF, tituloVotacao: tituloVotacao),
      ) 
    );
    //Navigator.pop(context); //fecha a tela atual e abre uma nova
  }  

  chamaTelaEleitoMelhor(String jogadorEleito, String quantidadeVotos){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaJogadorEleito(jogadorEleito, quantidadeVotos), //passo os dois times por parâmetro
      ) //o outro parâmetro é a rota
    );
  }
  
  @override
  Widget build(BuildContext context) {
    print("TESTE REGIAO TABELA DE JOGOS -> "+widget.regiao.toString());

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
              //chamar lista de assistencias:
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ExibirAssistencias(regiao: widget.regiao,),
                ) 
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        //recupera os dados toda vez que o banco é modificado
        stream: FirebaseFirestore.instance.collection("partidas").orderBy("id_partida", descending: true).snapshots(), //passa uma stream de dados
        builder: (context, snapshot) {
          // if(snapshot.data == null){
          //   return Center(
          //     child: Text("NENHUM DADO ENCONTRADO", style: TextStyle(color: Colors.white, fontSize: 24),),
          //   );
          // }
          //verificação de estado
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<DocumentSnapshot> partida = snapshot.data!.docs;

              if (partida.isEmpty) {
                return const Text("Vazio");
              } else {
                return Column(
                  children: [
                    TextButton(
                      child: Text(
                        "VER GRUPOS",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            //side: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      onPressed: () {
                        //chamar tela de grupos
                        Navigator.push( context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                          MaterialPageRoute(
                            builder: (context) => ExibirGrupos(regiao: widget.regiao.toString(),), 
                          ) //o outro parâmetro é a rota
                        );
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: partida.length,
                        itemBuilder: (context, index) {
                          // isVote = partida[index].get("votacao") == "true" ? true : false;
                          // print("TESTE 1: "+isVote.toString());

                          if(partida[index].get("id_campeonato") == widget.idCompetition){
                            //monta interface da tabela
                            return Column(
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
                                Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          // color: Colors.blue,
                                          width: widget.usuario?.getIsAdmin == true 
                                            ? MediaQuery.of(context).size.width * .7
                                            : MediaQuery.of(context).size.width * .8,
                                          child: Column(
                                            children: [
                                              // const CircleAvatar(
                                              //   maxRadius: 25,
                                              //   backgroundColor: Color.fromARGB(255, 45, 94, 45),
                                              //   backgroundImage: NetworkImage(partida[index].get("timeC").toString()),
                                              // ),
                                              AutoSizeText(
                                                partida[index].get("timeC"),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 4, 110, 7),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 4,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: MediaQuery.of(context).size.width*0.08,
                                                    height: MediaQuery.of(context).size.height*0.05,
                                                    child: Text(partida[index].get("golTimeCasa").toString(), style: TextStyle(fontSize: 20),),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.green),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8,),
                                                  const Text(
                                                    "X",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color.fromARGB(255, 4, 110, 7),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8,),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: MediaQuery.of(context).size.width*0.08,
                                                    height: MediaQuery.of(context).size.height*0.05,
                                                    child: Text(partida[index].get("golTimeFora").toString(), style: TextStyle(fontSize: 20),),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.green),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4,),
                                              // const CircleAvatar(
                                              //   maxRadius: 25,
                                              //   backgroundColor: Color.fromARGB(255, 45, 94, 45),
                                              //   backgroundImage: NetworkImage(partida[index].get("timeF").toString()),
                                              // ),
                                              AutoSizeText(
                                                partida[index].get("timeF"),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 4, 110, 7),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 16,),
                                              AutoSizeText(
                                                "${partida[index].get("data")} às ${partida[index].get("horario")} horas\n${partida[index].get("local")}",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Visibility(
                                            visible: widget.usuario?.getIsAdmin == true,
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 8.0,),
                                              child: Container(
                                                alignment: Alignment.centerRight,
                                                width: MediaQuery.of(context).size.width * 0.13,
                                                height: MediaQuery.of(context).size.height * 0.06,
                                                // color: Colors.amber,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    print("EDIT PARTIDA CLICADA!");
                                                    _exibirTelaCadastro(partida, index);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(right: 12.0),
                                                    child: Icon(Icons.edit),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  // color: Colors.red,
                                                  border: Border.all(),
                                                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: widget.usuario?.getIsAdmin == true,
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 8.0,),
                                              child: Container(
                                                alignment: Alignment.centerRight,
                                                width: MediaQuery.of(context).size.width * 0.13,
                                                height: MediaQuery.of(context).size.height * 0.06,
                                                // color: Colors.amber,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    print("HABILITA VOTACAO!");
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.only(right: 12.0),
                                                    child: Icon(
                                                      Icons.done_all, 
                                                      color: partida[index].get("votacao") == "true" ? Colors.white : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: partida[index].get("votacao") == "true" ? Colors.green : Colors.white,
                                                  border: Border.all(),
                                                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0,),
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              width: MediaQuery.of(context).size.width * 0.13,
                                              height: MediaQuery.of(context).size.height * 0.06,
                                              child: GestureDetector(
                                                onTap: () {
                                                  print("CARD PARTIDA CLICADO!");
                                                  if(partida[index].get("votacao") == "true"){
                                                    //quando uma partida é clicada:
                                                    chamaTelaVotacao(
                                                      partida[index].get("timeC").toString(), 
                                                      partida[index].get("timeF").toString(), 
                                                      partida[index].get("tituloVotacao").toString(),
                                                    );
                                                  }else{
                                                    chamaTelaEleitoMelhor(
                                                      partida[index].get("melhorJogador").toString(), 
                                                      partida[index].get("quantidadeVotos").toString(),
                                                    );
                                                  } 
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.only(right: 12.0),
                                                  child: Icon(Icons.more_vert),
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                // color: Colors.red,
                                                border: Border.all(),
                                                borderRadius: const BorderRadius.all(Radius.circular(25)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8,),
                                        ],
                                      ),
                                      
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }else{
                            return Container();
                          }
                        }
                          
                      ),
                    ),
                  ],
                );
              }
          }
        },
      ),
    );
  }

  TextEditingController _placarTimeAController = TextEditingController();
  TextEditingController _placarTimeBController = TextEditingController();

  _exibirTelaCadastro(List<DocumentSnapshot> partida, int index){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Center(child: Text("Alterar Placar:", style: TextStyle(fontSize: 24,),)),
          content: Column(
            mainAxisSize: MainAxisSize.min, //faz a coluna ocupar apenas o espaço suficiente para seus widgets
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.12,
                width: MediaQuery.of(context).size.width*1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.2,
                      height: MediaQuery.of(context).size.height*.2,
                      child: TextField(
                        controller: _placarTimeAController,
                        keyboardType: TextInputType.number,
                        onChanged: (value){

                        },
                        decoration: const InputDecoration(
                          label: Text("Casa"),
                          labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                            borderSide: BorderSide(
                              color: Colors.green,
                            ),
                          ),
                          // labelText: "Casa",
                          // labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16,),
                    const Text("X", style: TextStyle(fontSize: 24, color: Colors.green,),),
                    const SizedBox(width: 16,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.2,
                      height: MediaQuery.of(context).size.height*.2,
                      child: TextField(
                        controller: _placarTimeBController,
                        keyboardType: TextInputType.number,
                        onChanged: (value){

                        },
                        decoration: const InputDecoration(
                          label: Text("Fora", style: TextStyle(fontSize: 18),),
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                            borderSide: BorderSide(
                              color: Colors.green,
                            ),
                          ),
                          // labelText: "Casa",
                          // labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    child: TextButton(
                      child: const Text("Cancelar", style: TextStyle(fontSize: 20, color: Colors.white),),
                      onPressed: () => Navigator.pop(context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      // border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: Container(
                    child: TextButton(
                      child: Text("Salvar", style: TextStyle(fontSize: 20,  color: Colors.white),),
                      onPressed: (){
                        print("Dados Atualizados!");
                        criarPartida(partida, index);
                        Navigator.pop(context);
                      },
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      // border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  //capturar dados da partida
  criarPartida(List<DocumentSnapshot> partida, int index) {
    String idPartida = partida[index].get("id_partida");
    int idCampeonato = partida[index].get("id_campeonato");
    String data = partida[index].get("data");
    String horario = partida[index].get("horario");
    String melhorJogador = partida[index].get("melhorJogador");
    String quantidadeVotos = partida[index].get("quantidadeVotos");
    String votacao = partida[index].get("votacao");

    int golCasa = int.parse(_placarTimeAController.text);
    int golFora = int.parse(_placarTimeBController.text);
    String timeCasa = partida[index].get("timeC");
    String timeFora = partida[index].get("timeF");

    print(idPartida.toString()+" TESTE KAIO::: "+golCasa.toString()+" "+golFora.toString()+" "+timeCasa+" "+timeFora);
    
    //criar partida
    Partida partidaModel = Partida(
      idPartida: idPartida,
      idCampeonato: idCampeonato,
      fkPartida: partida[index].get("fk_competicao") ?? "Floresta",
      data: data,
      horario: horario,
      local: partida[index].get("local") ?? "",
      golTimeCasa: golCasa,
      golTimeFora: golFora,
      timeC: timeCasa,
      timeF: timeFora,
    );

    //salvar informações da partida no banco de dados
    _cadastrarFirebase(partidaModel);
    
  }

  //cadastrar informações no banco de dados
  Future<void> _cadastrarFirebase(Partida partida) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    
    db.collection("partidas").doc(partida.idPartida.toString()).set({
      "id_partida": partida.idPartida,
      "id_campeonato": partida.idCampeonato,
      "fk_competicao": partida.fkPartida,

      "data": partida.data,
      "horario": partida.horario,
      "local": partida.local,
      "melhorJogador": partida.melhorJogador ?? "",
      "quantidadeVotos": partida.quantidadeVotos ?? "",
      "timeC": partida.timeC,
      "timeF": partida.timeF,
      "votacao": partida.votacao ?? "",
      "tituloVotacao": "",
      "golTimeCasa": partida.golTimeCasa,
      "golTimeFora": partida.golTimeFora,
    });

    _chamarSnackBar("Placar registrado com Sucesso!!!");
  }

  //cria a snackBar com a mensagem de alerta
  var _snackBar;
  _chamarSnackBar(texto){
    _snackBar = SnackBar(content: Text(texto),);

    if(_snackBar != null){
      ScaffoldMessenger.of(context).showSnackBar(_snackBar); //chama o snackBar 
      //limpa snackbar
      _snackBar = "";
    }
  }

}