import 'package:arena_soccer/app/front/presentation/components/arena_carousel/arena_carousel.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:banner_carousel/banner_carousel.dart';
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
  List<BannerModel> bannerImages = [
    BannerModel(imagePath: 'lib/assets/images/ic_arena.png', id: "1"),
    BannerModel(imagePath: "https://picjumbo.com/wp-content/uploads/the-golden-gate-bridge-sunset-1080x720.jpg", id: "2"),
    BannerModel(imagePath: "https://wallpaperaccess.com/full/19921.jpg", id: "3")
  ];

  final List<String> imagens = [
    // "https://picjumbo.com/wp-content/uploads/the-golden-gate-bridge-sunset-1080x720.jpg",
    // "https://wallpaperaccess.com/full/19921.jpg",
    // Adicione outras URLs das imagens que deseja exibir no carrossel
  ];
  // final List<String> imagens = [];

  loadImages() {
    if (widget.dataNews != null && widget.dataNews!['images'] != null) {
      // O campo "images" existe no objeto widget.dataNews
      // Faça o que precisa com os dados presentes no campo "images"
      List<dynamic>? imagesDynamicList = widget.dataNews!.get("images") as List<dynamic>?;

      if (imagesDynamicList != null) {
        List<String> imagesList = imagesDynamicList.map((item) => item.toString()).toList();

        // Agora você pode percorrer a lista de strings e fazer o que precisa
        imagesList.forEach((imageUrl) {
          print(imageUrl); // Faça o que precisa com a URL da imagem
          if(imageUrl.isNotEmpty){
            imagens.add(imageUrl);
          }
        });
        print("TAM:: "+imagesDynamicList.length.toString());
      }
    } else {
      // O campo "images" não existe ou o objeto widget.dataNews é nulo
      // Lidar com essa situação de acordo com a sua lógica
      print("O CAMPO IMAGES NÃO EXISTE !!! ");
    }

    
  }

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 1;

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
      body: Column(
        children: [
          ///Base
          // BannerCarousel(
          //   banners: bannerImages,
          //   onTap: (id) => print(id),
          // ),
          /// Carousel Customized
          // BannerCarousel(
          //   banners: bannerImages,
          //   customizedIndicators: const IndicatorModel.animation(width: 20, height: 5, spaceBetween: 2, widthAnimation: 50),
          //   height: 120,
          //   activeColor: Colors.amberAccent,
          //   disableColor: Colors.white,
          //   animation: true,
          //   borderRadius: 16,
          //   onTap: (id) => print(id),
          //   width: width,
          //   indicatorBottom: false,
          //   spaceBetween: 4,
          // ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
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
                    if(imagens.isNotEmpty && imagens != null)
                      ArenaCarouselImages(images: imagens,)
                    else
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
          ),
        ],
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