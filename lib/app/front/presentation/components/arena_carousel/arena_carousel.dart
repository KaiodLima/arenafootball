import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ArenaCarouselImages extends StatelessWidget {
  final List<String> images;
  final double? height;
  final double? width;
  final bool? autoPlay;
  final bool? infinityScroll;

  ArenaCarouselImages({
    Key? key,
    required this.images,
    this.height,
    this.width,
    this.autoPlay,
    this.infinityScroll
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height ?? 450, // Altura do carrossel (ajuste conforme necessário)
        autoPlay: autoPlay ?? images.length > 1, // Define se o carrossel roda automaticamente
        enlargeCenterPage: true, // Aumenta o tamanho da imagem no centro
        aspectRatio: 16 / 9, // Proporção de aspecto das imagens
        autoPlayCurve: Curves.fastOutSlowIn, // Curva de animação
        enableInfiniteScroll: infinityScroll ?? images.length > 1, // Permite rolar indefinidamente
        autoPlayAnimationDuration: Duration(milliseconds: 800), // Duração da animação
        viewportFraction: 0.8, // Proporção do item visível na tela (0 a 1)
      ),
      items: images.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                width: MediaQuery.of(context).size.width * 1, // retorna o tamanho da largura da tela
                decoration: BoxDecoration(
                  image: DecorationImage(
                    repeat: ImageRepeat.noRepeat,                
                    image: CachedNetworkImageProvider(
                      url,
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
            );
          },
        );
      }).toList(),
    );
  }
}
