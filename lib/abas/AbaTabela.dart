import 'package:arena_soccer/app/front/presentation/pages/show_match_day/show_match_day.dart';
import 'package:arena_soccer/app/front/presentation/pages/show_matches/show_table_matches.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../app/front/presentation/pages/register_vote_best_player/MelhorDaPartida.dart';
import '../app/front/presentation/pages/show_best_player/TelaJogadorEleito.dart';
import '../model/Usuario.dart';
import '../app/front/presentation/pages/show_matches/components/competitions_card.dart';

class AbaTabela extends StatefulWidget {
  final String? regiao;
  final String? ano;
  Usuario? usuario;

  AbaTabela({
    Key? key,
    this.regiao,
    this.ano,
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
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
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
                  // return ShowTableMatches(idCompetition: element.get("id_campeonato"), regiao: widget.regiao, ano: widget.ano, usuario: widget.usuario,);
                  return ShowMatcheDay(idCompetition: element.get("id_campeonato"), regiao: widget.regiao, ano: widget.ano, usuario: widget.usuario,);
                }
              }
              return const SizedBox();
              
            }
        }
      },
    );

  }
}
