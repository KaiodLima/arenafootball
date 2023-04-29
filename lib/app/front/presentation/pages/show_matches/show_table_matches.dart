import 'package:arena_soccer/app/front/presentation/pages/show_groups/ExibirGrupos.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_vote_best_player/MelhorDaPartida.dart';
import 'package:arena_soccer/app/front/presentation/pages/show_best_player/TelaJogadorEleito.dart';
import 'package:arena_soccer/model/Jogador.dart';
import 'package:arena_soccer/model/Partida.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../show_soccer_scorers/ExibirArtilheiros.dart';
import '../show_assistance_leader/ExibirAssistencias.dart';
import '../../../../../model/Time.dart';
import '../../../../../model/Usuario.dart';


class ShowTableMatches extends StatefulWidget {
  final int? idCompetition; //recebe a variável enviada da outra tela
  final String? regiao;
  final String? ano;
  Usuario? usuario;

  ShowTableMatches({ 
    Key? key,
    this.idCompetition,
    this.regiao,
    this.ano,
    this.usuario
  }) : super(key: key);

  @override
  State<ShowTableMatches> createState() => _ShowTableMatchesState();
}

class _ShowTableMatchesState extends State<ShowTableMatches> {

  chamaTelaVotacao(String timeC, String timeF, String tituloVotacao){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MelhorDaPartida(timeC: timeC, timeF: timeF, tituloVotacao: tituloVotacao),
      ) 
    );
    //Navigator.pop(context); //fecha a tela atual e abre uma nova
  }  

  chamaTelaEleitoMelhor(String jogadorEleito, String quantidadeVotos, Time timeDados, Jogador jogadorDados){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaJogadorEleito(
          nomeJogador: jogadorEleito, 
          quantidadeVotos: quantidadeVotos,
          timeDados: timeDados,
          jogadorDados: jogadorDados,
        ), //passo os dois times por parâmetro
      )
    );
  }

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
    print("TESTE REGIAO TABELA DE JOGOS -> "+widget.regiao.toString());
    print("ANO ATUAL -> "+anoAtual.toString());
    print("ANO -> "+widget.ano.toString());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 67, 28),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 67, 28),
        title: const Text("TODOS OS JOGOS"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: TextButton(
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
                    builder: (context) => ExibirGrupos(regiao: widget.regiao.toString(), ano: widget.ano,), 
                  ) //o outro parâmetro é a rota
                );
              },
            ),
          ),
          // const SizedBox(width: 6,),
          // FloatingActionButton.small(
          //   heroTag: "btnArtilharia",
          //   onPressed: (){
          //     Navigator.push(
          //     context, 
          //     MaterialPageRoute(
          //       builder: (context) => ExibirArtilheiros(regiao: widget.regiao??"Floresta", ano: widget.ano),
          //     )
          //   );
          //   },
          //   backgroundColor: Colors.white,
          //   child: const Icon(
          //     Icons.sports_soccer,
          //     color: Colors.green,
          //   ),
          // ),
          // const SizedBox(width: 6,),
          // FloatingActionButton.small(
          //   heroTag: "btnAssistencias",
          //   onPressed: (){
          //     Navigator.push(
          //     context, 
          //     MaterialPageRoute(
          //       builder: (context) => ExibirAssistencias(regiao: widget.regiao??"Floresta", ano: widget.ano,),
          //     )
          //   );
          //   },
          //   backgroundColor: Colors.white,
          //   child: const Icon(
          //     Icons.star_border,
          //     color: Colors.green,
          //   ),
          // ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        //recupera os dados toda vez que o banco é modificado
        stream: (widget.ano.toString() != anoAtual.toString())
        ? FirebaseFirestore.instance.collection("partidas${widget.ano}").orderBy("dataRegistro", descending: true).snapshots()
        : FirebaseFirestore.instance.collection("partidas").orderBy("dataRegistro", descending: true).snapshots(), //passa uma stream de dados
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
                return const Center(child: Text("Nenhuma partida cadastrada", style: TextStyle(fontSize: 20, color: Colors.white),));
              } else {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8,),
                      Column(
                        children: [
                          ...partida.map((e) => Builder(
                              builder: (context) {
                                  if(e.get("id_campeonato") == widget.idCompetition){
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
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Container(
                                                      // color: Colors.blue,
                                                      width: widget.usuario?.getIsAdmin == true 
                                                        ? MediaQuery.of(context).size.width * .7
                                                        : MediaQuery.of(context).size.width * .7,
                                                      child: Column(
                                                        children: [
                                                          // const CircleAvatar(
                                                          //   maxRadius: 25,
                                                          //   backgroundColor: Color.fromARGB(255, 45, 94, 45),
                                                          //   backgroundImage: NetworkImage(partida[index].get("timeC").toString()),
                                                          // ),
                                                          AutoSizeText(
                                                            e.get("timeC"),
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
                                                                child: Text(e.get("golTimeCasa").toString(), style: TextStyle(fontSize: 20),),
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
                                                                child: Text(e.get("golTimeFora").toString(), style: TextStyle(fontSize: 20),),
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
                                                            e.get("timeF"),
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                              color: Color.fromARGB(255, 4, 110, 7),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 16,),
                                                          AutoSizeText(
                                                            "${e.get("data")} às ${e.get("horario")} horas\n${e.get("local")}",
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
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 8.0,),
                                                        child: Container(
                                                          alignment: Alignment.centerRight,
                                                          width: MediaQuery.of(context).size.width * 0.13,
                                                          height: MediaQuery.of(context).size.height * 0.06,
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              print("CARD PARTIDA CLICADO!");
                                                              if(e.get("votacao") == "true"){
                                                                //quando uma partida é clicada:
                                                                chamaTelaVotacao(
                                                                  e.get("timeC").toString(), 
                                                                  e.get("timeF").toString(), 
                                                                  e.get("tituloVotacao").toString(),
                                                                );
                                                              }else{
                                                                await _calcularVotos(e.get("timeC").toString(), e.get("timeF").toString());
                                                                Time timeDados = await _buscarTime(jogadorMaisVotado.toString());
                                                                Jogador jogadorDados = await _buscarDadosJogador(jogadorMaisVotado.toString(), timeDados.nome.toString());
                                                                chamaTelaEleitoMelhor(
                                                                  jogadorMaisVotado.toString(), 
                                                                  nVotos.toString(),
                                                                  timeDados,
                                                                  jogadorDados,
                                                                );
                                                              } 
                                                            },
                                                            child: const Padding(
                                                              padding: EdgeInsets.only(right: 12.0),
                                                              child: Icon(Icons.more_vert) 
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                    visible: widget.usuario?.getIsAdmin == true,
                                                    child: Container(
                                                      alignment: Alignment.center,
                                                      width: MediaQuery.of(context).size.width * 0.13,
                                                      height: MediaQuery.of(context).size.height * 0.05,
                                                      // color: Colors.amber,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if(e.get("votacao") == "true"){
                                                            criarPartida(e, "false");
                                                          }else {
                                                            print("HABILITA VOTACAO!");
                                                            criarPartida(e, "true");
                                                          }
                                                          
                                                        },
                                                        child: Icon(
                                                          Icons.done_all, 
                                                          color: e.get("votacao") == "true" ? Colors.white : Colors.black,
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: e.get("votacao") == "true" ? Colors.green : Colors.white,
                                                        border: const Border(
                                                          top: BorderSide(width: 2.0, color: Colors.black),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                      const SizedBox(height: 8,),
                                                    ],
                                                  ),
                                                  
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Visibility(
                                                    visible: widget.usuario?.getIsAdmin == true,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 8,),
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        width: MediaQuery.of(context).size.width * 0.8,
                                                        height: MediaQuery.of(context).size.height * 0.05,
                                                        // color: Colors.amber,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            print("EDIT PARTIDA CLICADA!");
                                                            _exibirTelaCadastro(e,);
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              const Icon(Icons.edit, ),
                                                              const SizedBox(width: 8,),
                                                              AutoSizeText("Editar Placar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                                            ],
                                                          ),
                                                        ),
                                                        decoration: const BoxDecoration(
                                                          border: Border(
                                                            top: BorderSide(width: 2.0, color: Colors.black),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: widget.usuario?.getIsAdmin == true,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        width: MediaQuery.of(context).size.width * 0.8,
                                                        height: MediaQuery.of(context).size.height * 0.06,
                                                        // color: Colors.amber,
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            print("DELETE PARTIDA CLICADA!");
                                                            await _actionCard(e, "delete");
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              const Icon(Icons.delete, ),
                                                              const SizedBox(width: 8,),
                                                              AutoSizeText("Excluir Partida", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                                            ],
                                                          ),
                                                        ),
                                                        decoration: const BoxDecoration(
                                                          border: Border(
                                                            top: BorderSide(width: 2.0, color: Colors.black),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  
                                                ],
                                              )
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
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  TextEditingController _placarTimeAController = TextEditingController();
  TextEditingController _placarTimeBController = TextEditingController();

  _exibirTelaCadastro(DocumentSnapshot<Object?> partida){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Center(child: Text("Alterar Placar:", style: TextStyle(fontSize: 24,),)),
          content: Column(
            mainAxisSize: MainAxisSize.min, //faz a coluna ocupar apenas o espaço suficiente para seus widgets
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height*0.12,
                width: MediaQuery.of(context).size.width*1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
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
                        criarPartida(partida, "");
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
  criarPartida(DocumentSnapshot<Object?> partida, String votacao) {
    String idPartida = partida.get("id_partida");
    int idCampeonato = partida.get("id_campeonato");
    String data = partida.get("data");
    String horario = partida.get("horario");
    String melhorJogador = partida.get("melhorJogador");
    String quantidadeVotos = partida.get("quantidadeVotos");
    // String votacao = partida[index].get("votacao");

    int? golCasa = _placarTimeAController.text.isNotEmpty 
      ? int.parse(_placarTimeAController.text) 
      : partida.get("golTimeCasa");
    int? golFora = _placarTimeBController.text.isNotEmpty
      ? int.parse(_placarTimeBController.text)
      : partida.get("golTimeFora");
    String timeCasa = partida.get("timeC");
    String timeFora = partida.get("timeF");

    String habilitaVotacao = votacao;
    // print(idPartida.toString()+" TESTE KAIO::: "+golCasa.toString()+" "+golFora.toString()+" "+timeCasa+" "+timeFora);
    
    //criar partida
    Partida partidaModel = Partida(
      idPartida: idPartida,
      idCampeonato: idCampeonato,
      fkPartida: partida.get("fk_competicao") ?? "Floresta",
      data: data,
      horario: horario,
      local: partida.get("local") ?? "",
      golTimeCasa: golCasa,
      golTimeFora: golFora,
      timeC: timeCasa,
      timeF: timeFora,
      votacao: habilitaVotacao,
      dataRegistro: partida.get("dataRegistro"),
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

      "dataRegistro": partida.dataRegistro,

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

    // _chamarSnackBar("Placar registrado com Sucesso!!!");
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

  //recuperar votos
  String? jogadorMaisVotado;
  String? nVotos;
  _calcularVotos(String timeC, String timeF) async {
    var collection = FirebaseFirestore.instance.collection("melhorjogador${timeC}${timeF}"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    var fieldValueMap = Map<String, int>();
    for (var value in resultado.docs) {
      var fieldValue = value["nome"] as String;
      if (fieldValueMap.containsKey(fieldValue)) {
        fieldValueMap[fieldValue] = fieldValueMap[fieldValue]! + 1;
      } else {
        fieldValueMap[fieldValue] = 1;
      }
    }

    var mostFrequentValue = '';
    var frequency = 0;
    fieldValueMap.forEach((key, value) {
      if (value > frequency) {
        frequency = value;
        mostFrequentValue = key;
      }
    });

    print("MAIS VOTADO: "+mostFrequentValue.toString()+" Votos: "+frequency.toString());
    jogadorMaisVotado = mostFrequentValue.toString();
    nVotos = frequency.toString();
    
  }

  //recuperar time no firebase  
  Future<Time> _buscarTime(String jogador) async {
    String nomeJogador = jogador;
    String? nomeTime;

    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db.collection("jogadores")
      .where("nome", isEqualTo: nomeJogador).get(); //recupera time pelo nome do jogador

    for(var item in querySnapshot.docs){
      nomeTime = item.get("time") ?? "";
      
      print("TESTE TIME: "+nomeTime.toString());

    }

    QuerySnapshot querySnapshotTime = await db.collection("times")
      .where("nome", isEqualTo: nomeTime).get(); //recupera dados do time

    Time time = Time();
    for(var item in querySnapshotTime.docs){
      time.nome = item.get("nome");
      time.urlImagem = item.get("urlImagem");      
      time.fkCompeticao = item.get("fk_competicao");

    }

    return time;
    
  }

  //recuperar jogador no firebase  
  Future<Jogador> _buscarDadosJogador(String nome, String time) async {
    print("ENTROU!!!");
    String nomeJogador = nome;
    String timeJogador = time;
    print(""+nomeJogador+" "+timeJogador);
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db.collection("jogadores")
      .where("nome", isEqualTo: nomeJogador)
      .where("time", isEqualTo: timeJogador).get(); //recupera todos os jogadores
    
    Jogador jogador = Jogador();
    for(var item in querySnapshot.docs){
      jogador.nome = item.get("nome");
      jogador.time = item.get("time");
      jogador.urlImagem = item.get("urlImagem");
      jogador.nGols = item.get("nGols");
      jogador.nAssistencias = item.get("nAssistencias");
      
    }

    return jogador;

  }

  _actionCard(DocumentSnapshot<Object?> partida, String action){
    switch (action) {
      case "edit":
        print("EDIT NOTICIA CLICADO!");
        
        break;
      case "delete":
        return showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              actions: [
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 12),
                  child: Center(
                    child: Text(
                      "DESEJA REALMENTE EXCLUIR ESSA PARTIDA ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                        width: 150,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            //buscar na galeria
                            print("Cancelar!");
                            Navigator.pop(context);
                          },
                          label: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red), //essa merda toda pra mudar a cor do botão oporra
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          // border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Container(
                        width: 150,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            print("Excluir");
                            final collection = FirebaseFirestore.instance.collection('partidas');
                            final idDoRegistro = partida.id; // ID do registro que você deseja excluir

                            await collection.doc(idDoRegistro).delete();
                            Navigator.pop(context);
                          },
                          label: const Text(
                            "Excluir",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          // border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
            
          },
        );
      default:
    }
  }
}