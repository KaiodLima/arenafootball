import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app/front/presentation/pages/show_championships/ExibirCampeonato.dart';

class AbaCampeonatos extends StatefulWidget {
  final String? regiao;
  final String? ano;

  const AbaCampeonatos({
    Key? key,
    this.regiao,
    this.ano
  }) : super(key: key);

  @override
  State<AbaCampeonatos> createState() => _AbaCampeonatosState();
}

class _AbaCampeonatosState extends State<AbaCampeonatos> {
  /*List<Campeonato> listaCampeonatos = [
    Campeonato(
      "Lançamento confirmado! Arena Soccer é seu novo aplicativo de notícias.",
      "Seu novo APP de notícias...",
      "https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
    ),
    Campeonato(
      "Lançamento confirmado! Arena Soccer é seu novo aplicativo de notícias.",
      "Seu novo APP de notícias...",
      "https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
    ),
    Campeonato(
      "Lançamento confirmado! Arena Soccer é seu novo aplicativo de notícias.",
      "Seu novo APP de notícias...",
      "https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
    ),
  ];*/

  @override
  Widget build(BuildContext context) {
    var aux;
    // print("TESTE ::: "+widget.regiao.toString());
    if(widget.regiao != null){
      aux = FirebaseFirestore.instance.collection("campeonatos").where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados
    }else{
      aux = FirebaseFirestore.instance.collection("campeonatos").snapshots();
    }

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
            List<DocumentSnapshot> campeonatos = snapshot.data!.docs;

            if (campeonatos.isEmpty) {
              return const Center(
                child: Text("Nenhuma competição registrada", style: TextStyle(color: Colors.white, fontSize: 20),),
              );
            } else {
              return ListView.builder(
                itemCount: campeonatos.length,
                itemBuilder: (context, index) {                  

                  //monta interface da noticia
                  return GestureDetector(
                    onTap: () {                      
                      //quando um campeonato é clicado:
                      Navigator.push(
                          context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                          MaterialPageRoute(
                            builder: (context) => ExibirCampeonato(campeonatos[index].id.toString(), regiao: widget.regiao.toString(), ano: widget.ano,), //passando por parâmetro o nome do time selecionado
                          ) //o outro parâmetro é a rota
                          );
                      //Navigator.pop(context); //fecha a tela atual e abre uma nova
                    },
                    child: Column(
                      children: [
                        Container(
                            //height: 200, 
                            padding: const EdgeInsets.only(left: 10, right: 10),                           
                            child: CachedNetworkImage(
                              imageUrl: campeonatos[index].get("urlImagem").toString(),
                              fit: BoxFit.scaleDown,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                        ),
                        /*Container(
                          height: 200,
                          decoration: BoxDecoration(
                            //border: Border.all(color: Colors.green),
                            image: DecorationImage(
                              fit: BoxFit.scaleDown,
                              image: NetworkImage(campeonatos[index].get("urlImagem").toString()),
                            ),
                          ),
                        ),*/
                        ListTile(
                          title: Text(
                            campeonatos[index].get("titulo"), //recuperar título da noticia
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          //subtitle: Text(campeonatos[index].get("descricao")), //recuperar descrição da noticia
                        ),
                      ],
                    ),
                  );
                },
              );

              /*return ListView.builder(
                    itemCount: noticia.length,
                    itemBuilder: (context, index) {
                      //monta interface da noticia
                      return ListTile(
                        title: Text(
                          noticia[index].get("titulo"), //recuperar título da noticia
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 4, 110, 7),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        subtitle: Text(noticia[index].get("descricao")), //recuperar descrição da noticia
                      );
                    },
                  );*/
            }
        }
      },
    );
  }
}
