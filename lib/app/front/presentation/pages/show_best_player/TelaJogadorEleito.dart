import 'package:arena_soccer/model/Time.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../../../model/Jogador.dart';

class TelaJogadorEleito extends StatefulWidget {
  String? nomeJogador; //recebe a variável enviada da outra tela
  String? quantidadeVotos;
  Time? timeDados;
  Jogador? jogadorDados;
  // String timeC; //recebe a variável enviada da outra tela
  // String timeF;

  TelaJogadorEleito({
    this.nomeJogador,
    this.quantidadeVotos,
    this.timeDados,
    this.jogadorDados,
    // required this.timeC,
    // required this.timeF,
  }); //construtor

  @override
  State<TelaJogadorEleito> createState() => _TelaJogadorEleitoState();
}

class _TelaJogadorEleitoState extends State<TelaJogadorEleito> {

  @override
  void initState(){
    super.initState();

  }

  getTimeAndJogadorImage(){
    print("tem time e jogador");
    return Stack(
        children: [
          if(widget.jogadorDados?.urlImagem != null && widget.jogadorDados!.urlImagem!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.center,
                    colors: [Colors.transparent, Colors.black],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Container(
                  // height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      repeat: ImageRepeat.noRepeat,                
                      image: CachedNetworkImageProvider(
                        widget.jogadorDados!.urlImagem.toString(),
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ),
            ),
          if(widget.timeDados?.urlImagem != null && widget.timeDados!.urlImagem!.isNotEmpty)
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.black],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  // height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      repeat: ImageRepeat.noRepeat,                
                      image: CachedNetworkImageProvider(
                        widget.timeDados!.urlImagem.toString(),
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color.fromARGB(0, 0, 0, 0)],
                begin: Alignment.bottomCenter,
                end: Alignment.center,              
              ),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64, right: 8, left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Center(
                    child: AutoSizeText(
                      "Eleito o melhor jogador da partida: ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Center(
                    child: AutoSizeText(
                      widget.nomeJogador.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Center(
                    child: Text(
                      "Número de votos: "+ widget.quantidadeVotos.toString(),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  // TextButton(
                  //   child: Text("VOLTAR", style: TextStyle(fontSize: 18),),
                  //   onPressed: (){
                  //     Navigator.pop(context); //fecha a tela atual e abre uma nova
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ],
      );
  }

  getOnlyTimeImage(){
    print("tem só time");
    return Stack(
        children: [
          if(widget.timeDados?.urlImagem != null && widget.timeDados!.urlImagem!.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                // height: MediaQuery.of(context).size.height * 0.7,
                // width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    repeat: ImageRepeat.noRepeat,                
                    image: CachedNetworkImageProvider(
                      widget.timeDados!.urlImagem.toString(),
                    ),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                ),
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color.fromARGB(0, 0, 0, 0)],
                begin: Alignment.bottomCenter,
                end: Alignment.center,              
              ),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64, right: 8, left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Center(
                    child: AutoSizeText(
                      "Eleito o melhor jogador da partida: ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Center(
                    child: AutoSizeText(
                      widget.nomeJogador.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Center(
                    child: Text(
                      "Número de votos: "+ widget.quantidadeVotos.toString(),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  // TextButton(
                  //   child: Text("VOLTAR", style: TextStyle(fontSize: 18),),
                  //   onPressed: (){
                  //     Navigator.pop(context); //fecha a tela atual e abre uma nova
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ],
      );
  }

  getOnlyJogadorImage(){
    print("tem só jogador");
    return Stack(
        children: [
          if(widget.jogadorDados?.urlImagem != null && widget.jogadorDados!.urlImagem!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.center,
                    colors: [Colors.transparent, Colors.black],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Container(
                  // height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      repeat: ImageRepeat.noRepeat,                
                      image: CachedNetworkImageProvider(
                        widget.jogadorDados!.urlImagem.toString(),
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color.fromARGB(0, 0, 0, 0)],
                begin: Alignment.bottomCenter,
                end: Alignment.center,              
              ),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64, right: 8, left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Center(
                    child: AutoSizeText(
                      "Eleito o melhor jogador da partida: ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Center(
                    child: AutoSizeText(
                      widget.nomeJogador.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Center(
                    child: Text(
                      "Número de votos: "+ widget.quantidadeVotos.toString(),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  // TextButton(
                  //   child: Text("VOLTAR", style: TextStyle(fontSize: 18),),
                  //   onPressed: (){
                  //     Navigator.pop(context); //fecha a tela atual e abre uma nova
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ],
      );
  }

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
      body: (widget.jogadorDados?.urlImagem != null 
      && widget.jogadorDados!.urlImagem!.isNotEmpty) 
      && (widget.timeDados?.urlImagem != null 
      && widget.timeDados!.urlImagem!.isNotEmpty)  ? getTimeAndJogadorImage() 
      : (widget.jogadorDados?.urlImagem != null 
      && widget.jogadorDados!.urlImagem!.isEmpty)
      && (widget.timeDados?.urlImagem != null 
      && widget.timeDados!.urlImagem!.isNotEmpty) ? getOnlyTimeImage() 
      : getOnlyJogadorImage(),
    );
  }
}