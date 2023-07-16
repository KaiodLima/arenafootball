import 'dart:io';
import 'dart:math';

import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_team/register_new_team_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;

class CadastrarTime extends StatefulWidget {
  const CadastrarTime({ Key? key }) : super(key: key);

  @override
  State<CadastrarTime> createState() => _CadastrarTimeState();
}

class _CadastrarTimeState extends State<CadastrarTime> {
  // TextEditingController _controllerIdPartida = TextEditingController();
  final _controller = RegisterNewTeamController(); //utilizo mobX
  
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
            Observer(builder: (_){
              return Text(
                _controller.idAtual.toString(), 
                style: const TextStyle(fontSize: 18),
              );
            }),
          ],
        ),
        const SizedBox(height: 16,),
        const Text(
          "Região:", 
          style: TextStyle(fontSize: 18),
        ),
        Observer(builder: (_){
          return _chamarDropDownCity(false);
        }),
        const SizedBox(height: 16,),  
        TextField(
          controller: _controller.controllerTimeNome,
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
          controller: _controller.controllerDescricao,
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
        Observer(builder: (_) {
          final width = MediaQuery.of(context).size.width;

          return ArenaButton(
            height: 47,
            width: width,
            title: "CADASTRAR",
            isLoading: _controller.isLoading,
            function: () async {
              await _controller.changeLoading(true);
              print("Salvar!");
              Random random = Random();
              int randomNumber = random.nextInt(100000);

              if(imageFile != null){
                await uploadPhoto(imageFile!, "time_${_controller.controllerTimeNome.text + randomNumber.toString()}");
              }
              
              _controller.criarTime(context);
              _controller.chamarSnackBar("Time registrado com Sucesso!!!", context);

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
  void initState() {
    super.initState();
    _controller.recuperarCidades();
    _controller.recuperarIdAtual();
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
              value: _controller.timeSelecionadoCasa,
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
                _controller.timeSelecionadoCasa = newValue!;
              },

              items: _controller.listaTimesFirebaseCasa.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

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
              value: _controller.timeSelecionadoFora,
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
                  _controller.timeSelecionadoFora = newValue!;
                });
              },

              items: _controller.listaTimesFirebaseFora.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
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

  
  Future<void> uploadPhoto(File Image, String fileName) async {
    try {
      var result = await storage.FirebaseStorage.instance
          .ref("times/$fileName")
          .putFile(Image);

      final urlDownload = await result.ref.getDownloadURL();
      setState(() {
        _controller.urlDownloadImage = urlDownload;
        print("TESTE CAMERA URL: " + _controller.urlDownloadImage.toString());
      });
    } on core.FirebaseException catch (e) {
      print("Error: ${e.code}");
    }
  }
  
}