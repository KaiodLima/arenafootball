import 'dart:io';

import 'package:arena_soccer/model/Noticia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

class CadastrarNoticia extends StatefulWidget {
  const CadastrarNoticia({ Key? key }) : super(key: key);

  @override
  State<CadastrarNoticia> createState() => _CadastrarNoticiaState();
}

class _CadastrarNoticiaState extends State<CadastrarNoticia> {
  TextEditingController _controllerIdNoticia = TextEditingController();
  TextEditingController _controllerTitulo = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();
  TextEditingController _controllerUrlImagem = TextEditingController();
  TextEditingController _controllerLink = TextEditingController();
  TextEditingController _controllerExibir = TextEditingController();
  TextEditingController _controllerTag = TextEditingController();

  int idAtual = 0;

  String? urlDownloadImage;
  //capturar dados da notícia
  criarNoticia() {
    int idNoticia = idAtual;
    // int id_noticia = int.parse(_controllerIdNoticia.text);
    String titulo = _controllerTitulo.text;
    String descricao = _controllerDescricao.text;
    //String urlImagem = _controllerUrlImagem.text;
    String urlImagem = urlDownloadImage?.toString() ?? "";
    // String urlImagem = "";
    String link = _controllerLink.text;
    String exibir = _controllerExibir.text;
    String fkCompeticao = cidadeSelecionada;
    String tag = _controllerTag.text;
    
    //validar campos:
    if ((idNoticia != 0) && 
    // (titulo.isNotEmpty && titulo.length >= 3) && 
    // (descricao.isNotEmpty && descricao.length >= 3) &&
    // (urlImagem.isNotEmpty && urlImagem.length >= 3) &&
    (exibir.isNotEmpty)) {
      //criar partida
      Noticia noticia = Noticia(
        idNoticia: idNoticia, 
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
      _cadastrarFirebase(noticia);
    } else {      
      _chamarSnackBar("Preencha todos os campos!!!");
    }
  }

  //cadastrar informações do usuário no banco de dados
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

    _chamarSnackBar("Noticia Cadastrada com Sucesso!!!");
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
              idAtual.toString(), 
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        // TextField(
        //   controller: _controllerIdNoticia,
        //   //autofocus: true,
        //   decoration: const InputDecoration(
        //     border: OutlineInputBorder(),
        //     labelText: "ID",
        //     icon: Icon(
        //       Icons.numbers,
        //       color: Colors.green,
        //       size: 24.0,              
        //     ),
        //   ),
        // ),
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
        // TextField(
        //   controller: _controllerUrlImagem,
        //   //autofocus: true,
        //   decoration: const InputDecoration(
        //     border: OutlineInputBorder(),
        //     labelText: "Caminho da imagem",
        //     icon: Icon(
        //       Icons.image,
        //       color: Colors.green,
        //       size: 24.0,              
        //     ),
        //   ),
        // ),
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
              criarNoticia();
            }else{
              _chamarSnackBar("A noticia precisa de um titulo!!!");
            }
            
          },
          child: Text("CADASTRAR"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra
          ),
        ),
        const SizedBox(height: 2,),       
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _recuperarIdAtual();
    _recuperarCidades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CADASTRAR NOTICIA"),
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

  // ImagePicker imagePicker = ImagePicker();
  // File? selectedImage;
  // getImageCamera() async {
  //   final PickedFile? temporaryImage = await imagePicker.getImage(source: ImageSource.camera);
  //   if(temporaryImage != null){
  //     setState(() {
  //       selectedImage = File(temporaryImage.path);
  //     });
  //     upLoadFile();
  //   }
  // }

  // getImageGalery() async {
  //   final PickedFile? temporaryImage = await imagePicker.getImage(source: ImageSource.gallery);
  //   if(temporaryImage != null){
  //     setState(() {
  //       selectedImage = File(temporaryImage.path);
  //     });
  //     upLoadFile();
  //   }
  // }

  // // UploadTask? uploadTask;
  // upLoadFile() async {
  //   final path = 'gs://arenasoccerflutter.appspot.com/noticias${_controllerTitulo.text}';
  //   final file = File(selectedImage!.path);

  //   final ref = FirebaseStorage.instance.ref().child(path);
  //   uploadTask = ref.putFile(file);

  //   final snapshot = await uploadTask!.whenComplete(() => null);

  //   final urlDownload = await snapshot.ref.getDownloadURL();
  //   setState(() {
  //     urlDownloadImage = urlDownload;
  //   });
  // }


  _recuperarIdAtual() async {
    var collection = FirebaseFirestore.instance.collection("noticias"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    // for(var doc in resultado.docs){
    //   print("TESTE REGIAO -> "+doc["nome"]);
    //   setState(() {

    //   });
      
    // }
    //print("TESTE -> "+listaTimesFirebase.toString());
    // print("TESTE -> "+resultado.docs.length.toString());

    setState(() {
      idAtual = resultado.docs.length+1;  
    });
    
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