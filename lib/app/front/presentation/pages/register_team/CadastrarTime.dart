import 'dart:io';
import 'dart:math';

import 'package:arena_soccer/model/Time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;

class CadastrarTime extends StatefulWidget {
  const CadastrarTime({ Key? key }) : super(key: key);

  @override
  State<CadastrarTime> createState() => _CadastrarTimeState();
}

class _CadastrarTimeState extends State<CadastrarTime> {
  TextEditingController _controllerIdPartida = TextEditingController();
  
  TextEditingController _controllerTimeNome = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();


  int idAtual = 0;

  //capturar dados do time
  criarTime() {
    String id_time = idAtual.toString();

    String nomeTime = _controllerTimeNome.text;
    String? descricaoTime = _controllerDescricao.text;
    String idCampeonato = cidadeSelecionada;
    String? urlImagem = urlDownloadImage?.toString() ?? "";
    
    //validar campos:
    if ((nomeTime.isNotEmpty && nomeTime.length >= 3)) {
      //criar time:
      Time timeNovo = Time(
        idTime: id_time+"_"+nomeTime.replaceAll(" ", "_"),
        nome: nomeTime,
        descricao: descricaoTime,
        fkCompeticao: idCampeonato,
        urlImagem: urlImagem,
      );

      _cadastrarFirebase(timeNovo);
    } else {      
      _chamarSnackBar("Preencha os campos obrigatórios!!!");
    }
  }

  //cadastrar informações no fireabase
  Future<void> _cadastrarFirebase(Time time) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    
    db.collection("times").doc(time.idTime).set({
      "id_partida": time.idTime,

      "nome": time.nome,
      "descricao": time.descricao,
      "fk_competicao": time.fkCompeticao,
      "urlImagem": time.urlImagem,

    });

    db.collection("classificacao").doc(time.idTime).set({
      "id_partida": time.idTime,

      "nome": time.nome,
      "descricao": time.descricao,
      "fk_competicao": time.fkCompeticao,
      "urlImagem": time.urlImagem,

      "vitorias": 0,
      "derrotas": 0,
      "empates": 0,
      "gols_feitos": 0,
      "gols_sofridos": 0,
      "pontos": 0,

      "fk_grupo": "",

    });

    _chamarSnackBar("Time registrado com Sucesso!!!");
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

  pageTeamForm() {
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
            Text(
              idAtual.toString(), 
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 16,),
        const Text(
          "Região:", 
          style: TextStyle(fontSize: 18),
        ),
        _chamarDropDownCity(false),
        const SizedBox(height: 16,),  
        TextField(
          controller: _controllerTimeNome,
          keyboardType: TextInputType.name,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Time",
            icon: Icon(
              Icons.shield,
              color: Colors.green,
              size: 24.0,              
            ),
          ),
        ),
        const SizedBox(height: 16,),      
        TextField(
          controller: _controllerDescricao,
          keyboardType: TextInputType.name,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Descrição",
            icon: Icon(
              Icons.description_outlined,
              color: Colors.green,
              size: 24.0,              
            ),
          ),
        ),
        const SizedBox(height: 16,),
        imageFile != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // maxRadius: 100,
                  // margin: const EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Image.file(
                    imageFile!,
                  ),
                ),
              ),
            )
          : Container(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Container(
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    //tirar foto
                    print("Câmera!");
                    _recoveryImage(true);
                    // Navigator.pop(context);
                  },
                  label: const Text(
                    "Câmera",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors
                            .green), //essa merda toda pra mudar a cor do botão oporra
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  // border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Container(
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.attach_file,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    //buscar na galeria
                    print("Galeria!");
                    _recoveryImage(false);
                    // Navigator.pop(context);
                  },
                  label: const Text(
                    "Galeria",
                    style: TextStyle(color: Colors.green),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors
                            .white), //essa merda toda pra mudar a cor do botão oporra
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32,),      
        ElevatedButton(
          onPressed: () async {
            print("Salvar!");
            Random random = Random();
            int randomNumber = random.nextInt(100000);

            if(imageFile != null){
              await uploadPhoto(imageFile!, "time_${_controllerTimeNome.text + randomNumber.toString()}");
            }
            
            criarTime();            
          },
          child: const Text("CADASTRAR"),
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
    _recuperarCidades();
    _recuperarIdAtual();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CADASTRAR TIME"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [              
              const SizedBox(height: 12,),
              Image.asset(
                "lib/assets/images/ic_arena.png",
                height: 100,
              ), //height mexe com o tamanho da imagem
              const SizedBox(
                height: 16,
              ),
              pageTeamForm(),
              
            ],
          ),
        ),
      ),
    );
  }

  String cidadeSelecionada = 'Floresta';
  _chamarDropDownCity(bool isRegister){

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


  String timeSelecionadoCasa = 'Lava Jato';
  _chamarDropDownTimesCasa(){
    
    return Container(    
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: timeSelecionadoCasa,
              icon: const Icon(Icons.change_circle_outlined, color: Colors.green,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 18, ),
              //underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              //dropdownColor: Colors.green,                            
              onChanged: (String? newValue) {
                setState(() {
                  timeSelecionadoCasa = newValue!;
                });
              },

              items: listaTimesFirebaseCasa.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

  //recuperar nomes dos times no firebase
  List<String> listaTimesFirebaseCasa = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimesCasa() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      setState(() {
        listaTimesFirebaseCasa.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    timeSelecionadoCasa = listaTimesFirebaseCasa.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }


  String timeSelecionadoFora = 'Lava Jato';
  _chamarDropDownTimesFora(){
    
    return Container(    
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: timeSelecionadoFora,
              icon: const Icon(Icons.change_circle_outlined, color: Colors.green,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 18, ),
              //underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              //dropdownColor: Colors.green,                            
              onChanged: (String? newValue) {
                setState(() {
                  timeSelecionadoFora = newValue!;
                });
              },

              items: listaTimesFirebaseFora.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

  //recuperar nomes dos times no firebase
  List<String> listaTimesFirebaseFora = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimesFora() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      setState(() {
        listaTimesFirebaseFora.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    timeSelecionadoFora = listaTimesFirebaseFora.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

  _recuperarIdAtual() async {
    var collection = FirebaseFirestore.instance.collection("times"); //cria instancia

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


  //Teste camera:
  PickedFile? _image;
  File? imageFile;

  Future _recoveryImage(bool isCamera) async {
    PickedFile? imageSelected;
    var imageTemporary;
    if (isCamera) {
      // print("CAMERA!!!");
      _image = await ImagePicker.platform.pickImage(source: ImageSource.camera);
      imageTemporary = File(_image!.path);
    } else {
      // print("GALERY!!!");
      _image =
          await ImagePicker.platform.pickImage(source: ImageSource.gallery);
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
      var result = await storage.FirebaseStorage.instance
          .ref("times/$fileName")
          .putFile(Image);

      final urlDownload = await result.ref.getDownloadURL();
      setState(() {
        urlDownloadImage = urlDownload;
        print("TESTE CAMERA URL: " + urlDownloadImage.toString());
      });
    } on core.FirebaseException catch (e) {
      print("Error: ${e.code}");
    }
  }
  
}