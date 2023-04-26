import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDatailsScreen extends StatefulWidget {
  final DocumentSnapshot<Object?>? dataNews;
  
  const NewsDatailsScreen({ 
    Key? key,
    this.dataNews,
  }) : super(key: key);

  @override
  State<NewsDatailsScreen> createState() => _NewsDatailsScreenState();
}

class _NewsDatailsScreenState extends State<NewsDatailsScreen> {
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
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color.fromARGB(0, 0, 0, 0)],
              begin: Alignment.bottomCenter,
              end: Alignment.center,              
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width * 1, // retorna o tamanho da largura da tela
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      repeat: ImageRepeat.noRepeat,                
                      image: CachedNetworkImageProvider(
                        (widget.dataNews!.get("urlImagem") != null)?widget.dataNews!.get("urlImagem").toString():"https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2F65c92ebe3eec4b2ebcdfbf5a298e558c.jpg?alt=media&token=eacbf582-f4d6-4fec-8388-f7c236fad4b9",
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
                  //max 40 caracteres
                  //(widget.title != null && widget.title!.isNotEmpty)?widget.title.toString():"SEM TÍTULO",
                  (widget.dataNews!.get("titulo") != null)? widget.dataNews!.get("titulo").toString().toUpperCase():"",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontFamily: "PTSans"
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: AutoSizeText(
                  //(widget.title != null && widget.title!.isNotEmpty)?widget.title.toString():"SEM TÍTULO",
                  (widget.dataNews!.get("descricao") != null)? widget.dataNews!.get("descricao").toString():"",
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: "PTSans"
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Visibility(
                visible: widget.dataNews!.get("link").toString() != "",
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const ImageIcon(
                      //   AssetImage("lib/assets/images/ic_insta.png"), //não funciona não sei o motivo
                      //   size: 50,
                      //   color: Colors.white,
                      // ),
                      const Icon(
                        Icons.link,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5,),
                      Center(
                        child: _chamarLink(widget.dataNews!.get("link")),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25,),
            ],
          ),
        ),
      ),
    );
  }

  _chamarLink(String link){
    return InkWell(
      child: const Text('Mais Informações', style: TextStyle(decoration: TextDecoration.underline, color: Colors.white,), textAlign: TextAlign.center,),
      onTap: () => launch(link),
    );
  }
  
}