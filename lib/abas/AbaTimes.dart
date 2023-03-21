import 'package:arena_soccer/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app/front/presentation/pages/show_players/ExibirJogadores.dart';

class AbaTimes extends StatefulWidget {
  final String? regiao;
  final Usuario? usuario;
  
  AbaTimes({
    Key? key,
    this.regiao,
    this.usuario,
  }) : super(key: key);

  @override
  State<AbaTimes> createState() => _AbaTimesState();
}

class _AbaTimesState extends State<AbaTimes> {
  /*List<Time> listaTimes = [
    Time(
      "Lava Jato",
      "Seu novo APP de notícias...",
      "https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
    ),
    Time(
      "Terra Plana",
      "Seu novo APP de notícias...",
      "https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
    ),
    Time(
      "X-9 Caiçara",
      "Seu novo APP de notícias...",
      "https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
    ),
  ];*/
  

  @override
  Widget build(BuildContext context) {
    var aux;
    // print("TESTE ::: "+widget.regiao.toString());
    if(widget.regiao != null){
      aux = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados.where("fk_competicao", isEqualTo: widget.regiao).snapshots(); //passa uma stream de dados
    }else{
      aux = FirebaseFirestore.instance.collection("times").snapshots();
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
            List<DocumentSnapshot> time = snapshot.data!.docs;

            if (time.isEmpty) {
              return const Center(
                child: Text("Equipes ainda não registradas", style: TextStyle(color: Colors.white, fontSize: 20),),
              );
            } else {
              return ListView.builder(
                itemCount: time.length,
                itemBuilder: (context, index) {
                  //monta interface da noticia
                  return GestureDetector(
                    onTap: () {
                      //quando um time é clicado:
                      Navigator.push(
                          context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                          MaterialPageRoute(
                            builder: (context) => ExibirJogadores(nomeTime: time[index].get("nome").toString(), usuario: widget.usuario,), //passando por parâmetro o nome do time selecionado
                          ) //o outro parâmetro é a rota
                          );
                      //Navigator.pop(context); //fecha a tela atual e abre uma nova
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
                        if(time[index].get("urlImagem").toString().isNotEmpty)
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
                                backgroundImage: NetworkImage(time[index].get("urlImagem").toString()),                            
                              ),
                              title: Text(time[index].get("nome"), //recuperar título da noticia
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              subtitle: Text(time[index].get("descricao")), //recuperar descrição da noticia
                            ),
                          )
                        else
                          ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            trailing: const Icon(
                              Icons.more_vert,
                              size: 30,
                            ), //adiciona ícone no final
                            //add imagem de contato
                            leading: const CircleAvatar(
                              maxRadius: 30,
                              backgroundColor: Color.fromARGB(255, 134, 143, 134),                           
                              //backgroundImage: Image.asset("lib/assets/images/avatar.png"),
                              //backgroundImage: NetworkImage(time[index].get("urlImagem").toString()),                            
                            ),
                            title: Text(
                              time[index]
                                  .get("nome"), //recuperar título da noticia
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 110, 7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            subtitle: Text(time[index].get("descricao")), //recuperar descrição da noticia
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

    /*return ListView.builder(
      itemCount: listaTimes.length,
      itemBuilder: (context, index) {
        Time time = listaTimes[index]; //recupera notíca da lista

        //monta interface da noticia
        return GestureDetector(
          onTap: () {
            //quando clicado

          },
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  //border: Border.all(color: Colors.green),
                  image: DecorationImage(                                        
                    fit: BoxFit.scaleDown,
                    image: NetworkImage(time.urlImagem),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  time.nome,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Color.fromARGB(255, 4, 110, 7), fontWeight: FontWeight.bold, fontSize: 20),
                ),
                subtitle: Text(time.descricao),
              ),
            ],
          ),
        );
        
      },
    );*/
  }
  

}
