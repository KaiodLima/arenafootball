import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompetitionsCard extends StatefulWidget {
  final List<DocumentSnapshot>? dataCompetition;
  final int? index;
  final String? title;
  final String? urlImage;

  const CompetitionsCard({ 
    Key? key,
    this.dataCompetition,
    this.index,
    this.title,
    this.urlImage,
  }) : super(key: key);

  @override
  State<CompetitionsCard> createState() => _CompetitionsCardState();
}

class _CompetitionsCardState extends State<CompetitionsCard> {
  double fontSizeTeam = 22;
  double fontSizeGroup = 24;
  String newTitle = "";  

  prepareText(){
    newTitle = widget.title!.toString();
    print("TESTE::: "+newTitle.toString());

    if(widget.title!.length > 20){
      newTitle = widget.title!.substring(0, 20).padRight(21, "...");
    }
  }

  @override
  void initState() {
    prepareText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(        
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.35,
          width: MediaQuery.of(context).size.width * 1, // retorna o tamanho da largura da tela
          decoration: BoxDecoration(
            image: DecorationImage(
              repeat: ImageRepeat.noRepeat,                
              image: CachedNetworkImageProvider(
                (widget.urlImage != null && widget.urlImage!.isNotEmpty)?widget.urlImage.toString():"https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_logo02.png?alt=media&token=53661073-6de9-41f0-a4bd-5148e0f9be3a",
              ),
              fit: BoxFit.cover,
            ),
            // border: Border.all(
            //   color: Color.fromARGB(255, 4, 110, 7),
            //   width: 2,
            //   style: BorderStyle.solid
            // ),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.35,
          width: MediaQuery.of(context).size.width * 1, // retorna o tamanho da largura da tela
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color.fromARGB(0, 0, 0, 0)],
              begin: Alignment.bottomCenter,
              end: Alignment.center,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          child: Container(
            margin: const EdgeInsets.only(top: 180),
            child: Column(            
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    //"CAMPEÃO NA ARENA BERNALDINO DE NOVO O NOVO...", //max 40 caracteres
                    //(widget.title != null && widget.title!.isNotEmpty)?widget.title.toString():"SEM TÍTULO",
                    (newTitle.isNotEmpty)?newTitle.toString():"",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Arial",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ]
    );
  }
}