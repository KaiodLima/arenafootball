import 'package:flutter/material.dart';

class GolCard extends StatefulWidget {
  var noticia;

  GolCard({
    Key? key,
    this.noticia,
  }) : super(key: key);

  @override
  State<GolCard> createState() => _GolCardState();
}

class _GolCardState extends State<GolCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.12,
                    width: MediaQuery.of(context).size.width * 0.69,
                    decoration: BoxDecoration(
                      // image: const DecorationImage(
                      //   repeat: ImageRepeat.noRepeat,                
                      //   image: ExactAssetImage("lib/assets/images/celebrate_cr7_1500.png"),
                      //   fit: BoxFit.cover,
                      // ),
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 255, 8),
                        // color: Colors.white,
                        width: 2,
                        style: BorderStyle.solid
                      ),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25)),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.noticia.get("time_casa").toString()+" "+widget.noticia.get("gol_time_casa").toString()+" x "+widget.noticia.get("gol_time_fora").toString()+" "+widget.noticia.get("time_fora").toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              // backgroundColor: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.width * 0.18,
                decoration: BoxDecoration(
                      image: const DecorationImage(
                        repeat: ImageRepeat.noRepeat,                
                        image: ExactAssetImage("lib/assets/images/bola_na_rede.png"),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 255, 8),
                        // color: Colors.white,
                        width: 2,
                        style: BorderStyle.solid
                      ),
                      // borderRadius: const BorderRadius.all(Radius.circular(25)),
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(25), bottomRight: Radius.circular(25)),
                    ),
                // child: Image.asset("lib/assets/images/bola_na_rede.png"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}