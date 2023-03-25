import 'package:arena_soccer/presentation/cadastro/Cadastro.dart';
import 'package:arena_soccer/app/front/presentation/pages/home_screen/Inicio.dart';
import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:arena_soccer/web_scraping_resultados/pages/all_match_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../model/Usuario.dart';

class Login extends StatefulWidget {
  const Login({ Key? key }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  fazerLogin(){
    String emailUsuario = _controllerEmail.text;
    String senhaUsuario = _controllerSenha.text;
    //validar campos:    
    if(emailUsuario.isNotEmpty && emailUsuario.contains("@")){
      if(senhaUsuario.isNotEmpty && senhaUsuario.length >= 8){
        //chamar função de cadatro
        login(emailUsuario, senhaUsuario);
      }else{
        // print("Senha inválida! Utilize no mínimo 8 caracteres.");
        _chamarSnackBar("Senha inválida! Utilize no mínimo 8 caracteres.");
      }
    }else{
      // print("E-mail inválido!!!");
      _chamarSnackBar("E-mail inválido!!!");
    }    

    //print("Email: $emailUsuario Senha: $senhaUsuario");    

  }
  //logar usuário na aplicação
  Future<void> login(email, senha) async {
    //FirebaseAuth auth = await FirebaseAuth.instance;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if(userCredential != null){
        _chamarSnackBar("Usuário Logado!");
        //buscar dados do usuário:
        Usuario dataUser = await searchUser(userCredential.user!.uid);
        //ir para home
        _chamarHome(true, dataUser);        
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // print('No user found for that email.');
        // print("Nenhum usuário encontrado para esse e-mail.");
        _chamarSnackBar("Nenhum usuário encontrado para esse e-mail.");
      } else if (e.code == 'wrong-password') {
        // print('Wrong password provided for that user.');
        // print("Senha incorreta.");
        _chamarSnackBar("Senha incorreta.");
      }
    }

    /*try {
      auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      ).then(
        //retorna uma instancia do usuário/objeto criado
        (fireBaseUser){
          _chamarHome();
          print("Usuário logado com Sucesso!");        
        }
      ).catchError(
        (error){
          print("Erro: "+error.toString());
        }
      );

    } catch (e) {
      print("Erro: "+e.toString());
    }*/

  }
  //chamar tela inicial/home
  _chamarHome(bool isAuthenticated, Usuario? user){
    //o pushReplacement substitui a rota atual pela próxima, ou seja, não vai haver botão volta no appbar
    Navigator.pushReplacement(
      context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
      MaterialPageRoute(
        builder: (context) => Inicio(isAuthenticated: isAuthenticated, usuario: user),
      ) //o outro parâmetro é a rota
    );
    //Navigator.pop(context); //fecha a tela atual e abre uma nova
  }

  //chamar tela de cadastro
  _chamarTelaCadastro(){
    //Navigator.pop(context); //fecha a tela atual e abre uma nova
    Navigator.push(
      context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
      MaterialPageRoute(
        builder: (context) => const Cadastro(),
      ) //o outro parâmetro é a rota
    );    
  }

  //Fiz esse script pra poder inserir novos campos em todos os regitros antigos:
  // void addNewFieldInFirebaseUsuario() async {
  //   var collection = FirebaseFirestore.instance.collection("usuarios"); //cria instancia
  //   var resultado = await collection.get(); //busca os dados uma vez

  //   for(var doc in resultado.docs){
  //     // print("USER -> "+doc.id);
  //     // print("USER -> "+doc["nome"]);
  //     FirebaseFirestore db = await FirebaseFirestore.instance;
      
  //     db.collection("usuarios").doc(doc.id.toString()).set(
  //       {
  //         "idUsuario": doc.id.toString(),
  //         "nome": doc["nome"],
  //         "email": doc["email"],
  //         "senha": doc["senha"],
  //         "time": doc["time"],
  //         "admin": false,
  //       }
  //     );
  //   }

  // }
  // void addNewFieldInFirebasePartida() async {
  //   var collection = FirebaseFirestore.instance.collection("partidas"); //cria instancia
  //   var resultado = await collection.get(); //busca os dados uma vez

  //   for(var doc in resultado.docs){
  //     // print("USER -> "+doc.id);
  //     // print("USER -> "+doc["nome"]);
  //     FirebaseFirestore db = await FirebaseFirestore.instance;
      
  //     db.collection("partidas").doc(doc.id.toString()).set(
  //       {
  //         "id_partida": doc.id.toString(),
  //         "id_campeonato": doc["id_campeonato"] ?? 1,
  //         "fk_competicao": doc["fk_competicao"],

  //         "data": doc["data"],
  //         "horario": doc["horario"],
  //         "local": doc["local"],
  //         "melhorJogador": doc["melhorJogador"],
  //         "quantidadeVotos": doc["quantidadeVotos"],
  //         "timeC": doc["timeC"],
  //         "timeF": doc["timeF"],
  //         "votacao": doc["votacao"],
  //         "tituloVotacao": doc["tituloVotacao"],
  //         "golTimeCasa": doc["golTimeCasa"] ?? 0,
  //         "golTimeFora": doc["golTimeFora"] ?? 0,
  //       }
  //     );
  //   }

  // }
  // void addNewFieldInFirebaseJogador() async {
  //   var collection = FirebaseFirestore.instance.collection("jogadores"); //cria instancia
  //   var resultado = await collection.get(); //busca os dados uma vez

  //   for(var doc in resultado.docs){
  //     // print("USER -> "+doc.id);
  //     // print("USER -> "+doc["nome"]);
  //     FirebaseFirestore db = await FirebaseFirestore.instance;
      
  //     db.collection("jogadores").doc(doc.id.toString()).set(
  //       {
  //         "idJogador":  doc.id.toString(),
  //         "nome":  doc["nome"],
  //         "time":  doc["time"],
  //         "urlImagem":  doc["urlImagem"],
  //         "nGols":  doc["nGols"],
  //         "nAssistencias":  doc["nAssistencias"],
  //       }
  //     );
  //   }

  // }
  // void addNewFieldInFirebaseTime() async {
  //   var collection = FirebaseFirestore.instance.collection("times"); //cria instancia
  //   var resultado = await collection.get(); //busca os dados uma vez

  //   for(var doc in resultado.docs){
  //     // print("USER -> "+doc.id);
  //     // print("USER -> "+doc["nome"]);
  //     FirebaseFirestore db = await FirebaseFirestore.instance;
      
  //     db.collection("times").doc(doc.id.toString()).set(
  //       {
  //         "idTime":  doc.id.toString(),

  //         "nome":  doc["nome"],
  //         "descricao":  doc["descricao"],
  //         "urlImagem":  doc["urlImagem"],
  //         "fk_competicao":  doc["fk_competicao"],
  //       }
  //     );
  //   }

  // }
  // void addNewFieldInFirebaseNoticia() async {
  //   var collection = FirebaseFirestore.instance.collection("noticias"); //cria instancia
  //   var resultado = await collection.get(); //busca os dados uma vez

  //   for(var doc in resultado.docs){
  //     // print("USER -> "+doc.id);
  //     // print("USER -> "+doc["nome"]);
  //     FirebaseFirestore db = await FirebaseFirestore.instance;

  //     db.collection("noticias").doc(doc.id.toString()).set(
  //       {
  //         "id":  int.parse(doc.id),
  //         "data": FieldValue.serverTimestamp(),

  //         "titulo": doc["titulo"] ?? "",
  //         "descricao": doc["descricao"] ?? "",
  //         "urlImagem": doc["urlImagem"] ?? "",
  //         "link": doc["link"] ?? "",
  //         "exibir": doc["exibir"] ?? "",

  //         "fk_competicao": "",
  //         "time_casa": "",
  //         "time_fora": "",
  //         "gol_time_casa": "",
  //         "gol_time_fora": "",
  //         "tag": doc["tag"] ?? "",
  //       }
  //     );
  //   }

  // }

  duplicarCollection() async {
    final origem = FirebaseFirestore.instance.collection('jogadores');
    final destino = FirebaseFirestore.instance.collection('jogadores2022');

    origem.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        destino.doc(doc.id).set(data).then((value) {
          print('Documento copiado com sucesso!');
        }).catchError((error) {
          print('Erro ao copiar documento: $error');
        });
      });
    }).catchError((error) {
      print('Erro ao obter documentos: $error');
    });

  }

  //buscar dado do usuário logado:
  Future<Usuario> searchUser(String idUser) async {
    var collection = FirebaseFirestore.instance.collection("usuarios").where("idUsuario", isEqualTo: idUser); //cria instancia
    var resultado = await collection.get(); //busca os dados uma vez

    Usuario user = Usuario(
      idUsuario: resultado.docs.first.get("idUsuario").toString(),
      nome: resultado.docs.first.get("nome").toString(),
      email: resultado.docs.first.get("email").toString(),
      senha: resultado.docs.first.get("senha").toString(),
      timeQueTorce: resultado.docs.first.get("time").toString(),
      isAdmin: resultado.docs.first.get("admin"),
    );

    return user;
  }

  //verifica se o usuário está logado
  Future<void> _verificaUsuarioLogado() async {
    User? userCurrent = await FirebaseAuth.instance.currentUser;

    if(userCurrent != null){
      //buscar usuário:
      Usuario? user = await searchUser(userCurrent.uid.toString());
      //ir para home:
      _chamarHome(true, user);      
    }

  }

  @override
  void initState() {
    // duplicarCollection();
    super.initState();
    // addNewFieldInFirebaseNoticia();
    _verificaUsuarioLogado();

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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea( //impede que o conteúdo sobreponha a barra de status do dispositivo
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [      
                    Image.asset("lib/assets/images/ic_arena.png", height: 100,), //height mexe com o tamanho da imagem
                    const SizedBox(height: 16,),
                    TextField(
                      controller: _controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Insira seu E-mail",
                        hintText: "exemplo@exemplo.com",
                        icon: Icon(
                          Icons.email,
                          color: Colors.green,
                          size: 24.0,
                          semanticLabel: 'Text to announce in accessibility modes',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8,),
                    TextField(
                      controller: _controllerSenha,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Insira sua Senha",  
                        icon: Icon(
                          Icons.key,
                          color: Colors.green,
                          size: 24.0,
                          semanticLabel: 'Text to announce in accessibility modes',
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24,),
                    ArenaButton(
                      height: 47,
                      width: width,
                      title: "ENTRAR",
                      fontSize: 16,
                      textColor: Colors.white,
                      buttonColor: Colors.green,                      
                      function: fazerLogin,
                      radius: 8,
                    ),
                    const SizedBox(height: 8,),
                    ArenaButton(
                      height: 47,
                      width: width,
                      title: "CRIAR CONTA",
                      fontSize: 16,
                      textColor: Colors.green,
                      buttonColor: Colors.white,
                      buttonBorderColor: Colors.green,
                      function: _chamarTelaCadastro,
                      radius: 8,
                    ),
                    const SizedBox(height: 8,),
                    TextButton(
                      onPressed: (){
                        _chamarHome(false, null); //usuário não autenticado
                      },
                      child: const Text("Pular"),
                    ),
                    const SizedBox(height: 18,),
                    // TextButton(
                    //   onPressed: (){
                    //     Navigator.push(
                    //       context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                    //       MaterialPageRoute(
                    //         builder: (context) => const AllMatchScreen(),
                    //       ) //o outro parâmetro é a rota
                    //     );
                    //   },
                    //   child: const Text("Teste All Matchs - Clique aqui!"),
                    // ),
                    
                  ],
                ),
            ),
          ),
          ),
    );
  }
}