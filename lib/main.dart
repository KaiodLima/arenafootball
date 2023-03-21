import 'package:arena_soccer/app/front/presentation/pages/login/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {  
  //iniciar aplicação do firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  //iniciar app
  runApp(
    MaterialApp(
      //home: CalcularVotos(),
      //home: CadastroAdmin(),
      home: const Login(),
      //home: NewsCard(title: "", description: "", urlImage: "",),
      //home: GroupCards(groupCompetition: [], index: 1, title: "",),
      theme: ThemeData(
        fontFamily: "Roboto",
      ),
      debugShowCheckedModeBanner: false,
    )
  );
}
