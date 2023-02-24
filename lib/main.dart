import 'package:arena_soccer/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {  
  //iniciar aplicação do firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  //iniciar app
  runApp(
    const MaterialApp(
      //home: CalcularVotos(),
      //home: CadastroAdmin(),
      home: Login(),
      //home: NewsCard(title: "", description: "", urlImage: "",),
      //home: GroupCards(groupCompetition: [], index: 1, title: "",),
      debugShowCheckedModeBanner: false,
    )
  );
}
