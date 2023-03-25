import 'package:arena_soccer/presentation/home/components/destaque.dart';
import 'package:arena_soccer/presentation/home/pages/destaque_detalhes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ARENAHighlights extends StatelessWidget {
  double? height;
  double? width;

  ARENAHighlights({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //recupera os dados toda vez que o banco é modificado
      stream: FirebaseFirestore.instance.collection("destaques").orderBy("id", descending: true).snapshots(), //passa uma stream de dados
      builder: (context, snapshot) {
        //verificação de estado
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            List<DocumentSnapshot> destaque = snapshot.data!.docs;

            if (destaque.isEmpty) {
              return Container(
                // child: const Center(
                //   child: Text("Nenhuma notícia registrada!"),
                // ),
              );
            } else {
              return SizedBox(
                width: width!,
                height: height!*0.12,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 16.0,),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: destaque.map((e){ //percorre o documento como um list
                        return GestureDetector(
                          onTap: () {
                            //quando clicado
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context)=>DetalhesDestaqueScreen(destaque_selecionado: e,),
                              ),
                            );
                            // print("DESTAQUE CLICADO!!! "+e.id.toString());
                          },
                          child: Destaque(
                              urlImage: e.get("urlImagem").toString(),
                              title: e.get("title").toString(),
                            ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            }
        }
      },
    );
  }
}