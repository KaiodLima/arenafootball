import 'dart:io';
import 'dart:math';

import 'package:arena_soccer/model/Noticia.dart';
import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PublicarAnuncioScreen extends StatefulWidget {
  const PublicarAnuncioScreen({Key? key}) : super(key: key);

  @override
  State<PublicarAnuncioScreen> createState() => _PublicarAnuncioScreenState();
}

class _PublicarAnuncioScreenState extends State<PublicarAnuncioScreen> {

  String cidadeSelecionada = 'Floresta';
  // int idAtual = 0;

  TextEditingController _controllerLink = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();
  TextEditingController _controllerTitulo = TextEditingController();
  TextEditingController _controllerExibir = TextEditingController();

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
              value: cidadeSelecionada,
              icon: const Icon(Icons.change_circle_outlined, color: Colors.white,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.white, fontSize: 18,),
              // underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              dropdownColor: Colors.green,
              onChanged: (String? newValue) {
                setState(() {
                  cidadeSelecionada = newValue!;
                });
              },

              items: listaCidadesFirebase.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

  @override
  void initState() {
    super.initState();

    _recuperarCidades();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const  Color.fromARGB(255, 27, 67, 28),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text("Cadastrar Card de Publicidade:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              const SizedBox(height: 8,),
              // SizedBox(
              //   // width: width*0.2,
              //   // height: height*.2,
              //   child: Text(
              //     "ID #"+idAtual.toString(),
              //     style: const TextStyle(
              //       fontSize: 24,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16,),
              const Text("Região:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              const SizedBox(height: 8,),
              _chamarDropDownCity(),
              const SizedBox(height: 32,),
              // const Text("Time da Casa:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              SizedBox(
                width: width*1,
                // height: height*.2,
                child: TextField(
                  controller: _controllerTitulo,
                  onChanged: (value){

                  },
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    labelText: "Titulo",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                    icon: Icon(
                      Icons.text_fields_outlined,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              imageFile != null? Container(          
                margin: const EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 1,
                child: Image.file(imageFile!),
              ): Container(),
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
                          // getImageCamera();
                          _recoveryImage(true);
                                      
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
                          // getImageGalery();
                          _recoveryImage(false);
                                      
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
              SizedBox(
                width: width*1,
                child: TextField(
                  controller: _controllerDescricao,
                  maxLines: 5,
                  cursorColor: Colors.white,
                  //autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    labelText: "Descricao",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.white, ),
                    icon: Icon(
                      Icons.text_fields_outlined,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              SizedBox(
                width: width*1,
                // height: height*.2,
                child: TextField(
                  controller: _controllerLink,
                  onChanged: (value){

                  },
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    labelText: "Link",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                    icon: Icon(
                      Icons.link,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              SizedBox(
                width: width*1,
                // height: height*.2,
                child: TextField(
                  controller: _controllerExibir,
                  onChanged: (value){

                  },
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    labelText: "Exibir (true ou false)",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                    // icon: Icon(
                    //   Icons.sort,
                    //   color: Colors.white,
                    //   size: 24.0,
                    // ),
                  ),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              ArenaButton(
                height: 47,
                width: width,
                title: "Publicar",
                fontSize: 16,
                textColor: Colors.white,
                buttonColor: Colors.green,                      
                borderRadius: 8,
                function: () async {
                  Random random = Random();
                  int randomNumber = random.nextInt(100000);
                  
                  if(imageFile != null){
                    await uploadPhoto(imageFile!, "noticias${_controllerTitulo.text+randomNumber.toString()}");
                  }
                  criarAnuncio();
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  //recuperar nomes das cidades no firebase
  final List<String> listaCidadesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarCidades() async {
    var collection = FirebaseFirestore.instance.collection("competicao"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    for(var doc in resultado.docs){
      // print("TESTE REGIAO -> "+doc["nome"]);
      setState(() {
        listaCidadesFirebase.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    //print("TESTE -> "+listaTimesFirebase.toString());    
  }

  String? urlDownloadImage;
  //noticia e anuncio usam o mesmo model
  criarAnuncio() {
    // int idNoticia = idAtual;
    String titulo = _controllerTitulo.text;
    String descricao = _controllerDescricao.text;
    String urlImagem = urlDownloadImage?.toString() ?? "";
    String link = _controllerLink.text;
    // String exibir = _controllerExibir.text;
    String exibir = _controllerExibir.text;

    String fkCompeticao = cidadeSelecionada;
    String golCasa = "";
    String golFora = "";
    String timeCasa = "";
    String timeFora = "";
    String tag = "publicidade";

    //validar campos:
    if (exibir.isNotEmpty) {
      //criar partida
      Noticia noticia = Noticia(
        titulo: titulo, 
        descricao: descricao, 
        urlImagem: urlImagem, 
        link: link, 
        exibir: exibir,
        fkCompeticao: fkCompeticao, 
        timeCasa: timeCasa, 
        timeFora: timeFora, 
        golTimeCasa: golCasa, 
        golTimeFora: golFora, 
        tag: tag,
      );        

      //salvar informações do jogador no banco de dados
      _cadastrarFirebase(noticia);
    } else {      
      _chamarSnackBar("Preencha todos os campos!!!");
    }
  }

  //cadastrar informações no banco de dados
  Future<void> _cadastrarFirebase(Noticia noticia) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    //aqui estou usando o uid do usuário logado pra salvar como  id na colection de dados
    var addedDocRef = await db.collection("noticias").add({
      "id": "",
      "data": FieldValue.serverTimestamp(),

      "titulo": noticia.titulo,
      "descricao": noticia.descricao,
      "urlImagem": noticia.urlImagem,
      "link": noticia.link,
      "exibir": noticia.exibir,

      "fk_competicao": noticia.fkCompeticao,
      "time_casa": noticia.timeCasa,
      "time_fora": noticia.timeFora,
      "gol_time_casa": noticia.golTimeCasa,
      "gol_time_fora": noticia.golTimeFora,
      "tag": noticia.tag

    });

    db.collection("noticias").doc(addedDocRef.id).set({
      "id": addedDocRef.id,
      "data": FieldValue.serverTimestamp(),

      "titulo": noticia.titulo,
      "descricao": noticia.descricao,
      "urlImagem": noticia.urlImagem,
      "link": noticia.link,
      "exibir": noticia.exibir,

      "fk_competicao": noticia.fkCompeticao,
      "time_casa": noticia.timeCasa,
      "time_fora": noticia.timeFora,
      "gol_time_casa": noticia.golTimeCasa,
      "gol_time_fora": noticia.golTimeFora,
      "tag": noticia.tag

    });

    _chamarSnackBar("Publicidade registrada com Sucesso!!!");
  }

  //cria a snackBar com a mensagem de alerta
  var _snackBar;
  _chamarSnackBar(texto){
    _snackBar = SnackBar(content: Text(texto),);

    if(_snackBar != null){
      ScaffoldMessenger.of(context).showSnackBar(_snackBar); //chama o snackBar 
      //limpa snackbar
      _snackBar = "";
    }
  }

  //Teste camera:
  PickedFile? _image;
  File? imageFile;
 
  Future _recoveryImage(bool isCamera) async{
    PickedFile? imageSelected;
    var imageTemporary;
    if(isCamera) {
      _image = await ImagePicker.platform.pickImage(source: ImageSource.camera);
      imageTemporary = File(_image!.path);
    } else {
      print("GALERY!!!");
      _image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
      imageTemporary = File(_image!.path);
    }
 
    setState(() {
      imageFile = imageTemporary;
      _image = imageSelected;
    });
 
  }

  Future<void> uploadPhoto(File Image, String fileName) async {
    print("ENTROU!!! "+Image.uri.toString());
    try {
      var result = await storage.FirebaseStorage.instance.ref("noticias/$fileName").putFile(Image);
      print("RESULT!!! "+result.toString());
      final urlDownload = await result.ref.getDownloadURL();
      setState(() {
        urlDownloadImage = urlDownload;
        print("TESTE CAMERA URL: "+urlDownloadImage.toString());
      });
    } on core.FirebaseException catch(e) {
      print("Error: ${e.code}");
 
    }
  }


}