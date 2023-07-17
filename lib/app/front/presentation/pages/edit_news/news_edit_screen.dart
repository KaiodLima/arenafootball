import 'dart:io';
import 'dart:math';

import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:arena_soccer/app/front/presentation/components/dropdown_field/dropdown_field.dart';
import 'package:arena_soccer/app/front/presentation/pages/edit_news/news_edit_screen_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class NewsEditScreen extends StatefulWidget {
  final DocumentSnapshot<Object?>? dataNews;

  NewsEditScreen({
    Key? key,
    this.dataNews,
  }) : super(key: key);

  @override
  State<NewsEditScreen> createState() => _NewsEditScreenState();
}

class _NewsEditScreenState extends State<NewsEditScreen> {
  final _controller = NewsEditScreenController(); //utilizo mobX

  

  @override
  void initState() {
    super.initState();
    _controller.recuperarCidades();
    _controller.iniciarDados(widget.dataNews);
  }

  pageNew() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.numbers,
              color: Colors.green,
              size: 24.0,              
            ),
            const SizedBox(width: 16,),
            Text(
              widget.dataNews!.id.toString(), 
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 8,),
        Observer(
          builder: (_) {
            return TextField(
              controller: _controller.controllerTitulo,
              //autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Título",
                icon: Icon(
                  Icons.text_fields_outlined,
                  color: Colors.green,
                  size: 24.0,              
                ),
              ),
            );
          }
        ),
        const SizedBox(height: 8,),
        Observer(builder: (_){
          return _controller.imageFile != null? Container(          
            margin: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 1,
            child: Image.file(_controller.imageFile!),
          ): Container();
        }),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,          
            children: [              
              Container(
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {                    
                    //Tirar foto:
                    _controller.recoveryImage(true);
                                
                  },
                  label: const Text("Tirar foto"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra
                  ),
                ),
              ),
              Container(                
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.attach_file, color: Colors.green,),
                  onPressed: () {
                    //buscar na galeria
                    _controller.recoveryImage(false);
                                
                  },
                  label: const Text("Galeria", style: TextStyle(color: Colors.green),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white), //essa merda toda pra mudar a cor do botão oporra                
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8,),
        Observer(
          builder: (_) {
            return TextField(
              controller: _controller.controllerDescricao,
              maxLines: 5,
              //autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Descricao",            
                icon: Icon(
                  Icons.text_fields_outlined ,
                  color: Colors.green,
                  size: 24.0,              
                ),
              ),
            );
          }
        ),
        const SizedBox(height: 16,),
        Observer(
          builder: (_) {
            return TextField(
              controller: _controller.controllerTag,
              //autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Tag",
                icon: Icon(
                  Icons.label,
                  color: Colors.green,
                  size: 24.0,              
                ),
              ),
            );
          }
        ),
        const SizedBox(height: 16,),
        Observer(
          builder: (_) {
            return TextField(
              controller: _controller.controllerLink,
              //autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Link",
                icon: Icon(
                  Icons.link,
                  color: Colors.green,
                  size: 24.0,              
                ),
              ),
            );
          }
        ),
        const SizedBox(height: 16,),
        Observer(builder: (_) {
          return ArenaDropdownField(
            controllerNews: _controller,
            initialValue: _controller.controllerExibir.text == "true"? true : false,
            icon: Icon(
              Icons.visibility,
              color: _controller.validateExibition() == null
                  ? Colors.green
                  : Colors.red,
              size: 24.0,
            ),
          );
        }),
        const SizedBox(height: 16,),
        Observer(builder: (_) {
          final width = MediaQuery.of(context).size.width;

          return ArenaButton(
            height: 47,
            width: width,
            title: "ATUALIZAR",
            isLoading: _controller.isLoading,
            function: () async {
              await _controller.changeLoading(true);
              
              Random random = Random();
              int randomNumber = random.nextInt(100000);

              if(_controller.controllerTitulo.text.isNotEmpty){
                if(_controller.imageFile != null){
                  await _controller.uploadPhoto(_controller.imageFile!, "noticias${_controller.controllerTitulo.text+randomNumber.toString()}");
                }
                
                _controller.atualizarNoticia(context);
                _controller.chamarSnackBar("Noticia Atualizada com Sucesso!!!", context);
              }else{
                _controller.chamarSnackBar("A noticia precisa de um titulo!!!", context);
              }

              // Simulando uma operação assíncrona com o Future.delayed
              await _controller.changeLoading(false);
            },
            buttonColor: Colors.green,
            fontSize: 16,
            borderRadius: 8,
          );
        }),
        const SizedBox(height: 2,),       
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EDITAR NOTÍCIA"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Observer(builder: (_){
                return _chamarDropDownCity();
              }),
              const SizedBox(height: 12,),
              Observer(builder: (_){
                if(_controller.imageFile == null){
                  return Image.network(
                    _controller.controllerUrlImagem.text,
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 1,
                  );
                }else{
                  return Image.asset(
                    "lib/assets/images/ic_arena.png",
                    height: 100,
                  );//height mexe com o tamanho da imagem
                }
              }),
              const SizedBox(
                height: 16,
              ),
              pageNew(),
              
            ],
          ),
        ),
      ),
    );
  }

  _chamarDropDownCity(){

    return Container(
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
        value: _controller.cidadeSelecionada,
        icon: const Icon(Icons.change_circle_outlined, color: Colors.green,),
        isExpanded: true,
        borderRadius: BorderRadius.circular(16),
        //elevation: 16,
        style: const TextStyle(color: Colors.black, fontSize: 18,),
        // underline: Container(height: 2, color: Colors.green,),
        underline: Container(),
        alignment: AlignmentDirectional.center,
        dropdownColor: Colors.green,
        onChanged: (String? newValue) {
          _controller.cidadeSelecionada = newValue!;
        },

        items: _controller.listaCidadesFirebase.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
        }).toList(),
      ),
    );
  }


  
  
  
}