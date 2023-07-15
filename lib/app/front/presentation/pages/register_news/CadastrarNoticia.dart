import 'dart:io';

import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:arena_soccer/app/front/presentation/components/dropdown_field/dropdown_field.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_news/register_new_controller.dart';
import 'package:arena_soccer/presentation/cadastro/widgets/arena_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

class CadastrarNoticia extends StatefulWidget {
  const CadastrarNoticia({Key? key}) : super(key: key);

  @override
  State<CadastrarNoticia> createState() => _CadastrarNoticiaState();
}

class _CadastrarNoticiaState extends State<CadastrarNoticia> {
  final _controller = RegisterNewController(); //utilizo mobX

  pageNoticia() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 8,
        ),
        Observer(builder: (_) {
          return ArenaTextField(
            labelText: "Título",
            // controller: _controllerTitulo,
            onChaged: _controller.changeTitle,
            errorText: _controller.validateTitle,
            icon: Icon(
              Icons.text_fields_outlined,
              color: _controller.validateTitle() == null
                  ? Colors.green
                  : Colors.red,
              size: 24.0,
            ),
          );
        }),
        const SizedBox(
          height: 8,
        ),
        imageFile != null
            ? Container(
                margin: const EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 1,
                child: Image.file(imageFile!),
              )
            : Container(),
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
                    backgroundColor: MaterialStateProperty.all<Color>(Colors
                        .green), //essa merda toda pra mudar a cor do botão oporra
                  ),
                ),
              ),
              Container(
                width: 150,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.attach_file,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    //buscar na galeria
                    // getImageGalery();
                    _recoveryImage(false);
                  },
                  label: const Text(
                    "Galeria",
                    style: TextStyle(color: Colors.green),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors
                        .white), //essa merda toda pra mudar a cor do botão oporra
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
          controller: _controller.controllerDescricao,
          maxLines: 5,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Descricao",
            icon: Icon(
              Icons.text_fields_outlined,
              color: Colors.green,
              size: 24.0,
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
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
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
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
        ),
        const SizedBox(
          height: 16,
        ),
        Observer(builder: (_) {
          return ArenaDropdownField(
            controller: _controller,
            icon: Icon(
              Icons.visibility,
              color: _controller.validateExibition() == null
                  ? Colors.green
                  : Colors.red,
              size: 24.0,
            ),
          );
        }),
        const SizedBox(
          height: 16,
        ),
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

              if (_controller.title != null && _controller.title!.isNotEmpty) {
                if (imageFile != null) {
                  await uploadPhoto(imageFile!,
                      "noticias${_controller.controllerTitulo.text + randomNumber.toString()}");
                }
                _controller.criarNoticia(context);
              } else {
                _controller.chamarSnackBar("A notícia precisa de um título!!!", context);
              }

              // Simulando uma operação assíncrona com o Future.delayed
              // await Future.delayed(Duration(seconds: 2));
              await _controller.changeLoading(false);
            },
            buttonColor: Colors.green,
            fontSize: 16,
            borderRadius: 8,
          );
        }),
        const SizedBox(
          height: 2,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.recuperarCidades();
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
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Observer(builder: (_){
                return _controller.chamarDropDownCity(context);
              }),
              const SizedBox(
                height: 12,
              ),
              Image.asset(
                "lib/assets/images/ic_arena.png",
                height: 100,
              ), //height mexe com o tamanho da imagem
              const SizedBox(
                height: 16,
              ),
              pageNoticia(),
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

  //Teste camera:
  PickedFile? _image;
  File? imageFile;

  Future _recoveryImage(bool isCamera) async {
    PickedFile? imageSelected;
    var imageTemporary;
    if (isCamera) {
      _image = await ImagePicker.platform.pickImage(source: ImageSource.camera);
      imageTemporary = File(_image!.path);
    } else {
      print("GALERY!!!");
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
          .ref("noticias/$fileName")
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
