import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NewsCard extends StatefulWidget {
  final String? title;
  final String? description;
  final String? urlImage;

  const NewsCard({ 
    Key? key,
    this.title,
    this.description,
    this.urlImage,
  }) : super(key: key);

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  String newTitle = "";
  String newDescription = "";

  prepareText(){
    newTitle = widget.title!.toString();
    newDescription = widget.description!.toString();
    // print("TAMANHO T::: "+newTitle.length.toString());
    // print("TAMANHO D::: "+newDescription.length.toString());

    if(widget.title!.length > 40){
      newTitle = widget.title!.substring(0, 30).padRight(31, "...");
    }
    if(widget.description!.length > 120){
      newDescription = widget.description!.substring(0, 110).padRight(111, "...");      
    }
    // print("TAMANHO T2::: "+newTitle.length.toString());
    // print("TAMANHO D2::: "+newDescription.length.toString());
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
          height: MediaQuery.of(context).size.height * 0.55,
          width: MediaQuery.of(context).size.width * 1, // retorna o tamanho da largura da tela
          decoration: BoxDecoration(
            image: DecorationImage(
              repeat: ImageRepeat.noRepeat,                
              image: CachedNetworkImageProvider(
                (widget.urlImage != null && widget.urlImage!.isNotEmpty)?widget.urlImage.toString():"https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
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
          height: MediaQuery.of(context).size.height * 0.55,
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
                  alignment: Alignment.centerLeft,
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
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    //"X-9 Caiçara finalmente quebra seu jejum de títulos e sai campeã pela primeira vez na história do clube! Parabéns a todos. hahaha", //max 120 caracteres
                    //(widget.description != null && widget.description!.isNotEmpty)?widget.description.toString():"SEM DESCRIÇÃO",
                    (newDescription.isNotEmpty)?newDescription.toString():"",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: "Arial",
                    ),              
                  ),
                ),
              ],
            ),
          ),
        ),
        //CURTIR E COMENTAR:
        // Container(
        //   height: MediaQuery.of(context).size.height * 0.55,
        //   width: MediaQuery.of(context).size.width * 1, // retorna o tamanho da largura da tela          
        //   child: Column(            
        //     children: [
        //       Padding(
        //         padding: const EdgeInsets.only(top: 10, right: 10),
        //         child: Container(
        //           alignment: Alignment.topRight,
        //           child: InkWell(
        //             onTap: (){
        //               // Navigator.push(
        //               //   context,
        //               //   MaterialPageRoute(
        //               //     builder: (context)=>CombosScreen(
        //               //       storeId: storeId,
        //               //       comboId: combo.attributesCombo!.id.toString(),
        //               //     ),
        //               //   ),
        //               // );
        //             },
        //             child: Container(
        //               height: 40,
        //               width: 40,
        //               decoration: const BoxDecoration(
        //                 shape: BoxShape.circle,
        //                 color: Colors.green,
        //               ),
        //               child: const Icon(Icons.thumb_up, color: Colors.white,),
        //             ),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(top: 10, right: 10),
        //         child: Container(
        //           alignment: Alignment.topRight,
        //           child: InkWell(
        //             onTap: (){
        //               // Navigator.push(
        //               //   context,
        //               //   MaterialPageRoute(
        //               //     builder: (context)=>CombosScreen(
        //               //       storeId: storeId,
        //               //       comboId: combo.attributesCombo!.id.toString(),
        //               //     ),
        //               //   ),
        //               // );
        //             },
        //             child: Container(
        //               height: 40,
        //               width: 40,
        //               decoration: const BoxDecoration(
        //                 shape: BoxShape.circle,
        //                 color: Colors.green,
        //               ),
        //               child: const Icon(Icons.comment, color: Colors.white,),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ]
    );
    
  }
}