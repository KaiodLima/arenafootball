import 'dart:io';
import 'dart:math';

import 'package:arena_soccer/model/Noticia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:image_picker/image_picker.dart';

class NewsEditScreen extends StatefulWidget {
  final List<DocumentSnapshot>? dataNews;
  final int? index;

  NewsEditScreen({
    Key? key,
    this.dataNews,
    this.index,
  }) : super(key: key);

  @override
  State<NewsEditScreen> createState() => _NewsEditScreenState();
}

class _NewsEditScreenState extends State<NewsEditScreen> {

  TextEditingController _controllerIdNoticia = TextEditingController();
  Timestamp? _controllerData;
  TextEditingController _controllerTitulo = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();
  TextEditingController _controllerUrlImagem = TextEditingController();
  TextEditingController _controllerLink = TextEditingController();
  TextEditingController _controllerExibir = TextEditingController();
  TextEditingController _controllerTag = TextEditingController();

  //cadastrar informações do usuário no banco de dados
  Future<void> _salvarFirebase(Noticia noticia) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    //aqui estou usando o uid do usuário logado pra salvar como  id na colection de dados
    db.collection("noticias").doc(noticia.idNoticia.toString()).set({
      "id": noticia.idNoticia,
      "data": noticia.data,

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

    _chamarSnackBar("Noticia Atualizada com Sucesso!!!");
  }

  //capturar dados da partida
  atualizarNoticia() {
    String idNoticia = _controllerIdNoticia.text;
    Timestamp? data = _controllerData;
    String titulo = _controllerTitulo.text;
    String descricao = _controllerDescricao.text;
    String urlImagem = imageFile != null ? urlDownloadImage!.toString() : _controllerUrlImagem.text;
    String link = _controllerLink.text;
    String exibir = _controllerExibir.text;
    String fkCompeticao = cidadeSelecionada;
    String tag = _controllerTag.text;
    
    //validar campos:
    if (
    // (titulo.isNotEmpty && titulo.length >= 3) && 
    // (descricao.isNotEmpty && descricao.length >= 3) &&
    // (urlImagem.isNotEmpty && urlImagem.length >= 3) &&
    (exibir.isNotEmpty)) {
      //criar partida
      Noticia noticia = Noticia(
        idNoticia: idNoticia, 
        data: data,
        titulo: titulo,
        descricao: descricao,
        urlImagem: urlImagem,
        link: link, 
        exibir: exibir,
        timeCasa: "", 
        timeFora: "", 
        golTimeCasa: "", 
        golTimeFora: "", 
        tag: tag, 
        fkCompeticao: fkCompeticao,
        );        

      //salvar informações do jogador no banco de dados
      _salvarFirebase(noticia);
    } else {      
      _chamarSnackBar("Preencha todos os campos!!!");
    }
  }

  _iniciarDados(){
    int index = widget.index ?? 0;
    _controllerIdNoticia.text = widget.dataNews![index].id.toString();
    _controllerData = widget.dataNews![index].get("data");
    _controllerTitulo.text = widget.dataNews![index].get("titulo");
    _controllerDescricao.text = widget.dataNews![index].get("descricao");
    _controllerUrlImagem.text = widget.dataNews![index].get("urlImagem");
    _controllerLink.text = widget.dataNews![index].get("link");
    _controllerExibir.text = widget.dataNews![index].get("exibir");
    _controllerTag.text = widget.dataNews![index].get("tag");

  }

  @override
  void initState() {
    super.initState();
    _recuperarCidades();
    _iniciarDados();
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

  pageJogador() {
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
              widget.dataNews![widget.index ?? 0].id.toString(), 
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 8,),
        TextField(
          controller: _controllerTitulo,
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
        ),
        const SizedBox(height: 8,),
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
        TextField(
          controller: _controllerDescricao,
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
        ),
        const SizedBox(height: 8,),
        const SizedBox(
          height: 8,
        ), 
        const SizedBox(height: 16,),
        TextField(
          controller: _controllerTag,
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
        ),
        const SizedBox(height: 16,),
        TextField(
          controller: _controllerLink,
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
        ),
        const SizedBox(height: 16,),      
        TextField(
          controller: _controllerExibir,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Exibir noticia? (true ou false)",
            icon: Icon(
              Icons.visibility,
              color: Colors.green,
              size: 24.0,              
            ),
          ),
        ),
        const SizedBox(height: 16,),      
        ElevatedButton(
          onPressed: () async {
            Random random = Random();
            int randomNumber = random.nextInt(100000);

            if(_controllerTitulo.text.isNotEmpty){
              if(imageFile != null){
                await uploadPhoto(imageFile!, "noticias${_controllerTitulo.text+randomNumber.toString()}");
              }
              
              atualizarNoticia();
            }else{
              _chamarSnackBar("A noticia precisa de um titulo!!!");
            }
            
          },
          child: Text("ATUALIZAR"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra
          ),
        ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _chamarDropDownCity(),
              const SizedBox(height: 12,),
              if(imageFile == null)
                Image.network(
                  _controllerUrlImagem.text,
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 1,
                )
              else
                Image.asset(
                  "lib/assets/images/ic_arena.png",
                  height: 100,
                ), //height mexe com o tamanho da imagem
              const SizedBox(
                height: 16,
              ),
              pageJogador(),
              
            ],
          ),
        ),
      ),
    );
  }


  String cidadeSelecionada = 'Floresta';
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

  String? urlDownloadImage;
  Future<void> uploadPhoto(File Image, String fileName) async {
    try {
      var result = await storage.FirebaseStorage.instance.ref("noticias/$fileName").putFile(Image);

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