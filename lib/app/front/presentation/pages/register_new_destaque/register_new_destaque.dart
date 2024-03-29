import 'dart:io';
import 'dart:math';

import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:arena_soccer/app/front/presentation/components/dropdown_field/dropdown_field.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_new_destaque/register_new_destaque_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';

class RegisterDestaque extends StatefulWidget {
  const RegisterDestaque({Key? key}) : super(key: key);

  @override
  State<RegisterDestaque> createState() => _RegisterDestaqueState();
}

class _RegisterDestaqueState extends State<RegisterDestaque> {
  // TextEditingController _controllerTitle = TextEditingController();
  // TextEditingController _controllerLink = TextEditingController();
  // TextEditingController _controllerExibir = TextEditingController();

  final _controller = RegisterNewDestaqueController(); //utilizo mobX

  @override
  void initState() {
    super.initState();
    // _recuperarCidades();
    _controller.recuperarDestaquesPriority();
  }

  pageFormularioDestaque() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller.controllerTitle,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Titulo",
            icon: Icon(
              Icons.account_box_outlined,
              color: Colors.green,
              size: 24.0,
              semanticLabel: 'Text to announce in accessibility modes',
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
        const SizedBox(height: 16,),
        TextField(
          controller: _controller.controllerLink,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Link",
            icon: Icon(
              Icons.account_box_outlined,
              color: Colors.green,
              size: 24.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
          ),
        ),
        const SizedBox(height: 8,),
        Observer(builder: (_) {
          return ArenaDropdownField(
            controllerDestaque: _controller,
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
            title: "CADASTRAR",
            isLoading: _controller.isLoading,
            function: () async {
              await _controller.changeLoading(true);
              Random random = Random();
              int randomNumber = random.nextInt(100000);

              if(imageFile != null){
                await uploadPhoto(imageFile!, "destaques${_controller.controllerTitle.text+randomNumber.toString()}");
              }
              _controller.createNewDestaque(context);
              _controller.chamarSnackBar("Destaque Cadastrado!!!", context);

              // Simulando uma operação assíncrona com o Future.delayed
              // await Future.delayed(Duration(seconds: 2));
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
        title: const Text("CADASTRAR DESTAQUE"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
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
                    pageFormularioDestaque(),
                    
                  ],
                ),
              ),
            ),
          ],
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
      var result = await storage.FirebaseStorage.instance.ref("destaques/$fileName").putFile(Image);
      print("RESULT!!! "+result.toString());
      final urlDownload = await result.ref.getDownloadURL();
      setState(() {
        _controller.urlDownloadImage = urlDownload;
        print("TESTE CAMERA URL: "+_controller.urlDownloadImage.toString());
      });
    } on core.FirebaseException catch(e) {
      print("Error: ${e.code}");
 
    }
  }

}
