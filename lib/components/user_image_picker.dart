import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File image)
      onImagePick; //envia a informação para o componente pai

  const UserImagePicker({Key? key, required this.onImagePick})
      : super(key: key);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _image; //a imagem pode ser null

  //função que irá manipular a imagem:
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery, //pegar imagem da galeria do dispositivo
      imageQuality: 60,
      maxWidth: 150,
    );
    //verifica se o arquivo é null
    if (pickedImage != null) {
      setState(() {
        //a variável _image recebe o caminho do arquivo escolhido
        _image = File(pickedImage.path);
      });
      //notifica o componente pai que a imagem foi selecionada
      widget.onImagePick(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          backgroundImage: _image != null
              ? FileImage(_image!)
              : null, //caso a imagem não seja null, exibe ela.
        ),
        TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.image,
                color: Colors.blue,
              ),
              SizedBox(
                width: 8,
              ),
              Text("Selecionar uma imagem"),
            ],
          ),
          onPressed: _pickImage,
        ),
      ],
    );
  }
}
