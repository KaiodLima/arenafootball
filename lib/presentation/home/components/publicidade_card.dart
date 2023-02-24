import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PublicidadeCard extends StatefulWidget {
  var noticia;
  int? index;

  PublicidadeCard({
    Key? key,
    this.noticia,
    this.index
  }) : super(key: key);

  @override
  State<PublicidadeCard> createState() => _PublicidadeCardState();
}

class _PublicidadeCardState extends State<PublicidadeCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width * 1,
              decoration: BoxDecoration(
                image: DecorationImage(
                  repeat: ImageRepeat.noRepeat,
                  image: CachedNetworkImageProvider(
                    (widget.noticia[widget.index].get("urlImagem") != null && widget.noticia[widget.index].get("urlImagem").toString().isNotEmpty) ? widget.noticia[widget.index].get("urlImagem").toString() : "",
                  ),
                  // image: ExactAssetImage("lib/assets/images/celebrate_cr7_1500.png"),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: Colors.white,
                  // color: Colors.white,
                  width: 2,
                  style: BorderStyle.solid
                ),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "PUBLICIDADE",
                      style: TextStyle(
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
      ],
    );
  }
}