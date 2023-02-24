import 'package:arena_soccer/presentation/news/widget/news_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../news/pages/news_details_screen.dart';

// A ideia é filtrar toda as noticias do time em destaque. 
//Vou adicionar um campo tag nos registro da tabela noticias pra poder fazer o filtro.

class DetalhesDestaqueScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> destaque_selecionado;

  const DetalhesDestaqueScreen({
    Key? key,
    required this.destaque_selecionado, 
  }) : super(key: key);

  @override
  State<DetalhesDestaqueScreen> createState() => _DetalhesDestaqueScreenState();
}

class _DetalhesDestaqueScreenState extends State<DetalhesDestaqueScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Size>? _tamanhoContainer;

  final ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    // print("Chamou função!!");
    _controller?.forward();
    // if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
    
    // }
  }

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _tamanhoContainer = Tween(
      begin: const Size(500, 500),
      end: const Size(150, 150),
    ).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.linear),
    );

    _tamanhoContainer?.addListener(() { setState(() {
      
    }); });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                //height: MediaQuery.of(context).size.height * 0.65,
                height: _tamanhoContainer?.value.height ?? 300, //caso o valor seja nulo em algum momento, preenche com 300
                //width: MediaQuery.of(context).size.width * 1, // retorna o tamanho da largura da tela
                width: _tamanhoContainer?.value.width ?? 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    repeat: ImageRepeat.noRepeat,                
                    image: CachedNetworkImageProvider(
                      (widget.destaque_selecionado.get("urlImagem") != null)?widget.destaque_selecionado.get("urlImagem").toString():"https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2F65c92ebe3eec4b2ebcdfbf5a298e558c.jpg?alt=media&token=eacbf582-f4d6-4fec-8388-f7c236fad4b9",
                    ),
                    fit: BoxFit.cover,
                  ),
                  // border: Border.all(
                  //   color: Color.fromARGB(255, 4, 110, 7),
                  //   width: 2,
                  //   style: BorderStyle.solid
                  // ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: AutoSizeText(
                //"CAMPEÃO NA ARENA BERNALDINO DE NOVO O NOVO...", //max 40 caracteres
                //(widget.title != null && widget.title!.isNotEmpty)?widget.title.toString():"SEM TÍTULO",
                (widget.destaque_selecionado.get("title") != null)?widget.destaque_selecionado.get("title").toString() :"",
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Arial",
                ),
              ),
            ),
            const SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: AutoSizeText(
                //"CAMPEÃO NA ARENA BERNALDINO DE NOVO O NOVO...", //max 40 caracteres
                //(widget.title != null && widget.title!.isNotEmpty)?widget.title.toString():"SEM TÍTULO",
                (widget.destaque_selecionado.get("title") != null)?widget.destaque_selecionado.get("title").toString() :"",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: "Arial",
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Center(
              child: _chamarLink(widget.destaque_selecionado.get("link")),
            ),
            const SizedBox(height: 25,),
            _buscarNoticiasPorTime(width, height),
          ],
        ),
      ),
    );
  }

  //cria a snackBar com a mensagem de alerta  
  _chamarLink(String link){
    return InkWell(
      child: Text(link, style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),),
      onTap: () => launch(link),
    );
  }

  _buscarNoticiasPorTime(double width, double height){

    return StreamBuilder<QuerySnapshot>(
      //recupera os dados toda vez que o banco é modificado
      stream: FirebaseFirestore.instance.collection("noticias").where("tag", isEqualTo: widget.destaque_selecionado.get("title").toString()).orderBy("id", descending: true).snapshots(), //passa uma stream de dados
      builder: (context, snapshot) {
        if(snapshot.data == null || snapshot.data!.docs.isEmpty){ //testa se a busca retornou algum elemento
          return const Center(
            child: Text("Nenhuma notícia disponível!", style: TextStyle(color: Colors.white),),
          );
        }else{
          //verificação de estado
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            default:
              List<DocumentSnapshot> noticia_destaque = snapshot.data!.docs;
              // print("TESTE::: "+noticia_destaque.first.data().toString());
              if (noticia_destaque.isEmpty) {
                return const Center(
                  child: Text("Nenhuma notícia disponível!"),
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var index = 0; index < noticia_destaque.length; index++)
                        GestureDetector(
                          onTap: () {
                            //quando clicado
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context)=>NewsDatailsScreen(dataNews: noticia_destaque, index: index,),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: NewsCard(
                              urlImage: noticia_destaque[index].get("urlImagem").toString(),
                              title: noticia_destaque[index].get("titulo").toString(),
                              description: noticia_destaque[index].get("descricao").toString(),
                            ),
                          ),
                        ),
                    ]
                  ),
                );
                
                //como preciso do index pra chamar a próxima tela, não dá pra usa .map
                // return SingleChildScrollView(
                //   child: Column(
                //     children: noticia_destaque.map((e){ //percorre o documento como um list
                //       return GestureDetector(
                //         onTap: () {
                //           //quando clicado
                //           // Navigator.push(
                //           //   context,
                //           //   MaterialPageRoute(
                //           //     builder: (context)=>NewsDatailsScreen(dataNews: noticia_destaque, index: int.parse(e.id),),
                //           //   ),
                //           // );
                //         },
                //         child: Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child: NewsCard(
                //             urlImage: e.get("urlImagem").toString(),
                //             title: e.get("titulo").toString(),
                //             description: e.get("descricao").toString(),
                //           ),
                //         ),
                //       );
                //     }).toList(),
                //   ),
                // );
              }
          }
        }
      },
    );
  }

}