import 'package:arena_soccer/model/Usuario.dart';
import 'package:arena_soccer/app/front/presentation/pages/edit_news/news_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../presentation/home/components/gol_card.dart';
import '../presentation/home/components/publicidade_card.dart';
import '../app/front/presentation/pages/show_news_details/news_details_screen.dart';
import '../app/front/presentation/components/news_card.dart';

class AbaNoticias extends StatefulWidget {
  final String? regiao;
  final Usuario? usuario;

  AbaNoticias({
    Key? key,
    this.regiao,
    this.usuario,
  }) : super(key: key);

  @override
  State<AbaNoticias> createState() => _AbaNoticiasState();
}

class _AbaNoticiasState extends State<AbaNoticias> {
  /*List<Noticia> listaNoticias = [
    Noticia(
      "Lançamento confirmado! Arena Soccer é seu novo aplicativo de notícias.",
      "Seu novo APP de notícias...",
      "https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
    ),
    Noticia(
      "Lançamento confirmado! Arena Soccer é seu novo aplicativo de notícias.",
      "Seu novo APP de notícias...",
      "https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
    ),
    Noticia(
      "Lançamento confirmado! Arena Soccer é seu novo aplicativo de notícias.",
      "Seu novo APP de notícias...",
      "https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
    ),
  ];*/

  //recupera as noticias cadastradas no firebase
  /*Future<List<Noticia>> _recuperarNoticias() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("Noticias").get();

    List<Noticia> listaNoticias = [];
    for(DocumentSnapshot item in querySnapshot.docs){
      var dados = item.data();

      Noticia noticia = Noticia(dados["titulo"], dados["descricao"], dados["urlImagem"]);

      listaNoticias.add(noticia);
    }

    return listaNoticias;

  }*/

  //recupera as noticias cadastradas no firebase
  /*final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('usuarios').snapshots();
  Future<List<Noticia>> _recuperarNoticias() async {
    StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return ListTile(
              title: Text(data['nome']),
              subtitle: Text(data['email']),
            );
          }).toList(),
        );
      },
    );
  }*/

  //cria a snackBar com a mensagem de alerta  
  Widget chamarLink(String link){
    return InkWell(
      child: Text('$link', style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),),
      onTap: () => launch(link),
    );
  }

  @override
  Widget build(BuildContext context) {
    var aux;
    // print("TESTE ::: "+widget.regiao.toString());
    if(widget.regiao != null){
      aux = FirebaseFirestore.instance.collection("noticias").where("fk_competicao", isEqualTo: widget.regiao).orderBy("data", descending: true).snapshots(); //passa uma stream de dados
    }else{
      aux = FirebaseFirestore.instance.collection("noticias").orderBy("data", descending: true).snapshots(); //passa uma stream de dados
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
            List<DocumentSnapshot> noticia = snapshot.data!.docs;
            // print("TESTE::: "+noticia.first.data().toString());

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                children: [
                  ...noticia.map(
                    (e) => Column(
                      children: [
                        if(e.get("exibir").toString() == "true" && e.get("tag").toString() == "gol")
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                GolCard(noticia: e,),
                                _actionCard(e, "delete"),                              
                              ],
                            ),
                          )
                        else if(e.get("exibir").toString() == "true" && e.get("tag").toString() == "publicidade")
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: (e.get("link").toString().isNotEmpty)
                                  ? () => launchUrlString(e.get("link").toString())
                                  : () {},
                                  child: PublicidadeCard(noticia: e,)
                                ),
                                _actionCard(e, "delete"),
                              ],
                            ),
                          )
                        else if(e.get("tag").toString() != "gol" && e.get("tag").toString() != "publicidade")
                          //monta interface da noticia
                          GestureDetector(
                            onTap: () {
                              //quando clicado
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsDatailsScreen(dataNews: e,),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  NewsCard(
                                    urlImage: e.get("urlImagem").toString(),
                                    title: e.get("titulo").toString(),
                                    description: e.get("descricao").toString(),
                                  ),
                                  Column(
                                    children: [
                                      _actionCard(e, "edit"),
                                      _actionCard(e, "delete"),
                                    ],
                                  ),
                                  
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  ),
                  // SizedBox(height: MediaQuery.of(context).size.height*0.12,)
                ],
              ),
            );

            // if (noticia.isEmpty) {
            //   return const Center(
            //     child: Text("Nenhuma notícia registrada", style: TextStyle(color: Colors.white, fontSize: 20),),
            //   );
            // } else {
            //   return ListView.builder(
            //     //reverse: true,
            //     itemCount: noticia.length,
            //     itemBuilder: (context, index) {   

            //       return Column(
            //         children: [
            //           if(noticia[index].get("exibir").toString() == "true" && noticia[index].get("tag").toString() == "gol")
            //             Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: Stack(
            //                 children: [
            //                   GolCard(noticia: noticia, index: index),
            //                   _actionCard(noticia, index, "delete"),                              
            //                 ],
            //               ),
            //             )
            //           else if(noticia[index].get("exibir").toString() == "true" && noticia[index].get("tag").toString() == "publicidade")
            //             Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: Stack(
            //                 children: [
            //                   PublicidadeCard(noticia: noticia, index: index,),
            //                   _actionCard(noticia, index, "delete"),
            //                 ],
            //               ),
            //             )
            //           else if(noticia[index].get("tag").toString() != "gol" && noticia[index].get("tag").toString() != "publicidade")
            //             //monta interface da noticia
            //             GestureDetector(
            //               onTap: () {
            //                 //quando clicado
            //                 Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     builder: (context) => NewsDatailsScreen(dataNews: noticia, index: index,),
            //                   ),
            //                 );
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Stack(
            //                   children: [
            //                     NewsCard(
            //                       urlImage: noticia[index].get("urlImagem").toString(),
            //                       title: noticia[index].get("titulo").toString(),
            //                       description: noticia[index].get("descricao").toString(),
            //                     ),
            //                     Column(
            //                       children: [
            //                         _actionCard(noticia, index, "edit"),
            //                         _actionCard(noticia, index, "delete"),
            //                       ],
            //                     ),
                                
            //                   ],
            //                 ),
            //               ),
            //             ),
            //         ],
            //       );
                  
            //     },
            //   );
            // }
        }
      },
    );

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

  _actionCard(DocumentSnapshot<Object?> noticia, String action){
    return Visibility(
      visible: widget.usuario?.getIsAdmin == true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            alignment: Alignment.centerRight,
            width: MediaQuery.of(context).size.width * 0.13,
            height: MediaQuery.of(context).size.height * 0.06,
            // color: Colors.amber,
            child: GestureDetector(
              onTap: () async {
                switch (action) {
                  case "edit":
                    print("EDIT NOTICIA CLICADO!");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsEditScreen(dataNews: noticia,),
                      ),
                    );
                    
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
                                  "DESEJA REALMENTE EXCLUIR ESSA NOTÍCIA ?",
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
                                        final collection = FirebaseFirestore.instance.collection('noticias');
                                        final idDoRegistro = noticia.id; // ID do registro que você deseja excluir

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
                
              },
              child: Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: action == "edit" 
                ? Icon(Icons.edit, color: Colors.black,)
                : Icon(Icons.delete, color: Colors.black,)
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.circular(25)),
            ),
          ),
        ),
      ),
    );
  }
}
