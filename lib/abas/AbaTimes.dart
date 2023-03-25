import 'package:arena_soccer/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app/front/presentation/pages/show_players/ExibirJogadores.dart';

class AbaTimes extends StatefulWidget {
  final String? regiao;
  final String? ano;
  final Usuario? usuario;
  
  AbaTimes({
    Key? key,
    this.regiao,
    this.ano,
    this.usuario,
  }) : super(key: key);

  @override
  State<AbaTimes> createState() => _AbaTimesState();
}

class _AbaTimesState extends State<AbaTimes> {
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
    var aux;
    // print("TESTE ::: "+widget.regiao.toString());
    // print("TESTE ::: "+widget.ano.toString());
    // print("TESTE ::: "+anoAtual.toString());
    if(widget.ano != null && widget.ano!.isNotEmpty){
      if(widget.ano.toString() == anoAtual.toString()){
        if(widget.regiao != null){
          aux = FirebaseFirestore.instance.collection("times")
          .where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados.where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados
        }else{
          aux = FirebaseFirestore.instance.collection("times").snapshots();
        }
      }else{
        if(widget.regiao != null){
          aux = FirebaseFirestore.instance.collection("times${widget.ano}")
          .where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados.where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados
        }else{
          aux = FirebaseFirestore.instance.collection("times${widget.ano}").snapshots();
        }
      }
      
    }else{
      if(widget.regiao != null){
        aux = FirebaseFirestore.instance.collection("times")
        .where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados.where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados
      }else{
        aux = FirebaseFirestore.instance.collection("times").snapshots();
      }
    }
    // if(widget.regiao != null){
    //   aux = FirebaseFirestore.instance.collection("times")
    //   .where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados.where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados
    // }else{
    //   aux = FirebaseFirestore.instance.collection("times").snapshots();
    // }

    return StreamBuilder<QuerySnapshot>(
      //recupera os dados toda vez que o banco é modificado
      stream: aux,
      builder: (context, snapshot) {
        //verificação de estado
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            List<DocumentSnapshot> time = snapshot.data!.docs;

            if (time.isEmpty) {
              return const Center(
                child: Text("Equipes ainda não registradas", style: TextStyle(color: Colors.white, fontSize: 20),),
              );
            } else {

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  children: [
                    ...time.map((e) => GestureDetector(
                      onTap: () {
                        //quando um time é clicado:
                        Navigator.push(
                          context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                          MaterialPageRoute(
                            builder: (context) => ExibirJogadores(nomeTime: e.get("nome").toString(), usuario: widget.usuario,), //passando por parâmetro o nome do time selecionado
                          ) //o outro parâmetro é a rota
                        );
                      },
                      child: Column(
                        children: [
                          if(e.get("urlImagem").toString().isNotEmpty)
                            Card(
                              color: const Color.fromRGBO(0, 255, 0, 0.25),                            
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(45.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                trailing: const Icon(
                                  Icons.more_vert,
                                  size: 30,
                                  color: Colors.white,
                                ), //adiciona ícone no final
                                //add imagem de contato
                                leading: CircleAvatar(
                                  maxRadius: 30,
                                  backgroundColor: const Color.fromARGB(255, 134, 143, 134),                           
                                  //backgroundImage: CachedNetworkImageProvider(time[index].get("urlImagem").toString()),
                                  backgroundImage: NetworkImage(e.get("urlImagem").toString()),                            
                                ),
                                title: Text(e.get("nome"), //recuperar título da noticia
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Text(e.get("descricao")), //recuperar descrição da noticia
                              ),
                            )
                          else
                            Card(
                              color: const Color.fromRGBO(0, 255, 0, 0.25),                            
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(45.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                trailing: const Icon(
                                  Icons.more_vert,
                                  size: 30,
                                  color: Colors.white,
                                ), //adiciona ícone no final
                                //add imagem de contato
                                leading: const CircleAvatar(
                                  maxRadius: 30,
                                  backgroundColor: Color.fromARGB(255, 134, 143, 134),                           
                                  //backgroundImage: CachedNetworkImageProvider(time[index].get("urlImagem").toString()),
                                  // backgroundImage: NetworkImage(e.get("urlImagem").toString()),                            
                                ),
                                title: Text(e.get("nome"), //recuperar título da noticia
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Text(e.get("descricao")), //recuperar descrição da noticia
                              ),
                            )

                        ],
                      ),
                    )),
                  ],
                ),
              );
            }
        }
      },
    );

  }
  
}
