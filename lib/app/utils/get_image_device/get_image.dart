// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:firebase_core/firebase_core.dart' as core;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:image_picker/image_picker.dart';

class GetImageDevice {
  PickedFile? image;
  File? imageFile;
  String? urlDownloadImage;

  GetImageDevice({
    required this.image,
    required this.imageFile,
    this.urlDownloadImage,
  });


  Future recoveryImage(bool isCamera) async {
    PickedFile? imageSelected;
    var imageTemporary;
    if (isCamera) {
      image = await ImagePicker.platform.pickImage(source: ImageSource.camera);
      imageTemporary = File(image!.path);
    } else {
      print("GALERY!!!");
      image =
          await ImagePicker.platform.pickImage(source: ImageSource.gallery);
      imageTemporary = File(image!.path);
    }

    imageFile = imageTemporary;
    image = imageSelected;
  }

  Future<String?> uploadPhoto(File Image, String fileName) async {
    print("Upload!!!");
    try {
      var result = await storage.FirebaseStorage.instance
          .ref("noticias/$fileName")
          .putFile(Image);

      final urlDownload = await result.ref.getDownloadURL();
      urlDownloadImage = urlDownload;
      
      print("TESTE CAMERA URL: " + urlDownloadImage.toString());
      return urlDownloadImage;
    } on core.FirebaseException catch (e) {
      print("Error: ${e.code}");
      return null;
    }
  }
  
}
