import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Destaque extends StatefulWidget {
  final String? title;  
  final String? urlImage;
  
  const Destaque({
    Key? key,
    this.title,    
    this.urlImage,    
  }) : super(key: key);

  @override
  State<Destaque> createState() => _DestaqueState();
}


class _DestaqueState extends State<Destaque> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: width*.20,
        height: height, 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(55)),
          border: Border.all(
            color: Colors.green,
            width: 3,
          ),
          image: DecorationImage(
              repeat: ImageRepeat.noRepeat,                
              image: CachedNetworkImageProvider(
                (widget.urlImage != null && widget.urlImage!.isNotEmpty)?widget.urlImage.toString() :"https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710",
              ),
              fit: BoxFit.cover,
            ),
        ),
      ),
    );
  }
}