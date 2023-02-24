import 'dart:convert';

import 'package:arena_soccer/Login.dart';
import 'package:arena_soccer/model/Time.dart';
import 'package:arena_soccer/model/Usuario.dart';
import 'package:arena_soccer/my_widgets/arena_button.dart';
import 'package:arena_soccer/presentation/cadastro/controller_cadastro.dart';
import 'package:arena_soccer/presentation/cadastro/widgets/arena_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({ Key? key }) : super(key: key);

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> with SingleTickerProviderStateMixin{
  // TextEditingController _controllerNome = TextEditingController();
  // TextEditingController _controllerEmail = TextEditingController();
  // TextEditingController _controllerSenha = TextEditingController();

  //capturar dados do novo usuário
  criarUsuario(){
    // String nomeUsuario = _controllerNome.text;
    // String emailUsuario = _controllerEmail.text;
    // String senhaUsuario = _controllerSenha.text;
    String? nomeUsuario = controleCadastro.user.nome;
    String? emailUsuario = controleCadastro.user.email;
    String? senhaUsuario = controleCadastro.user.senha;

    //validar campos:
    if(nomeUsuario!.isNotEmpty && nomeUsuario.length >= 3){
      if(emailUsuario!.isNotEmpty && emailUsuario.contains("@")){
        if(senhaUsuario!.isNotEmpty && senhaUsuario.length >= 8){
          //criar usuário
          Usuario usuario = Usuario(nome: nomeUsuario, email: emailUsuario, senha: senhaUsuario, timeQueTorce: timeSelecionado);

          //chamar função de cadastro
          registraUsuarioFirebase(usuario);
        }else{
          //print("Senha inválida! Utilize no mínimo 8 caracteres.");
          _chamarSnackBar("Senha inválida! Utilize no mínimo 8 caracteres.");
        }
      }else{
        //print("E-mail inválido!!!");
        _chamarSnackBar("E-mail inválido!!!");
      }
    }else{
      //print("Preencha o campo NOME!!!");
      _chamarSnackBar("Preencha o campo NOME!!!");
    }
    
  }

  //registrar usuário
  registraUsuarioFirebase(Usuario usuario) async {    
    //FirebaseAuth _auth = await FirebaseAuth.instance; //cria uma instancia do objeto de autenticação    

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usuario.email.toString(),
        password: usuario.senha.toString(),
      );

      if(userCredential != null){
        //salvar informações do usuário no banco de dados
        _cadastrarFirebase(usuario);
        //voltar para tela de Login
        _chamarTelaLogin();
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        //print('The password provided is too weak.');
        print('A senha fornecida é muito fraca.');
        // isSenhaOk = false;
        _chamarSnackBar('A senha fornecida é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        //print('The account already exists for that email.');
        print('A conta já existe para esse e-mail.');
        // isEmailOk = false;
        _chamarSnackBar('Já existe uma conta para esse e-mail.');
      }
    } catch (e) {
      print(e);
    }

    //método responsável por cria um acesso para autenticação
    /*_auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
      ).then(
        //retorna uma instancia do usuário/objeto criado
        (fireBaseUser){
          print("Usuário criado com Sucesso!");
          _chamarTelaLogin();
        }
      ).catchError(
        (error){
          print("Erro: "+error);
        }
      );*/

  }

  //cadastrar informações do usuário no banco de dados  
  Future<void> _cadastrarFirebase(Usuario usuario) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    //aqui estou usando o uid do usuário logado pra salvar como  id na colection de dados
    db.collection("usuarios").doc(FirebaseAuth.instance.currentUser!.uid.toString()).set(
      {
        "idUsuario": FirebaseAuth.instance.currentUser!.uid.toString(),
        "nome": usuario.getNome,
        "email": usuario.getEmail,
        "senha": usuario.getSenha,
        "time": usuario.getTimeQuetorce,
        "admin": false,
      }
    );
    //aqui gera um id aleatorio qualquer
    /*db.collection("usuarios").add(
      {
        "nome": usuario.nome,
        "email": usuario.email,
        "senha": usuario.senha,
      }
    );*/
    _chamarSnackBar("Usuário Cadastrado com Sucesso!!!");
  }


  _chamarTelaLogin(){
    //resolvido o bug de quando fazia login após o cadastro aparecer opção de voltar no appbar    
    Navigator.pushAndRemoveUntil( //remove as rotas pendentes até a rota atual
      context, 
      MaterialPageRoute(
        builder: (context) => Login(),
      ), 
      (route) => false,
    );
  
  }

  
  //cria a snackBar com a mensagem de alerta
  var _snackBar;
  _chamarSnackBar(texto){
    setState(() {
      selected = !selected;
    });
    _snackBar = SnackBar(content: Text(texto),);

    if(_snackBar != null){
      ScaffoldMessenger.of(context).showSnackBar(_snackBar); //chama o snackBar 
      //limpa snackbar
      _snackBar = "";
    }
  }


  //chamar caixa de opções
  String timeSelecionado = '';
  // List<String> listaTimes = ["Lava Jato", "X-9 Caiçara", "Real Parceiros", "Olho dagua A", "Olho dagua B",
  //  "Quarta Marcha", "Volta", "Veteranos", "Risadinha", "Gameleira", "Terra Plana"];
  _chamarDropDownTimes(){
    
    return Container(    
      margin: EdgeInsets.all(4),  
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: timeSelecionado,
              icon: const Icon(Icons.arrow_downward),
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
                  timeSelecionado = newValue!;
                });
              },

              items: listaTimesFirebase.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

  //recuperar nomes dos times no firebase
  List<String> listaTimesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimes() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    /*collection.snapshots().listen((event) { //fica escutando pra ver se houve alteração no banco
      resultado = event;
      
      for(var doc in resultado.docs){
        print("TESTE ON -> "+doc["nome"]);
        setState(() {
          listaTimesFirebase.add(doc["nome"]); //adiciona em uma list
        });
        
      }

    });*/

    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      setState(() {
        listaTimesFirebase.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    timeSelecionado = listaTimesFirebase.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

  String cidadeSelecionada = 'Floresta';
  _chamarDropDownCity(){

    return Container(
      margin: EdgeInsets.all(4),  
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: cidadeSelecionada,
              icon: const Icon(Icons.arrow_downward),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 18, ),
              // underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              //dropdownColor: Colors.green,                            
              onChanged: (String? newValue) {
                setState(() {
                  cidadeSelecionada = newValue!;
                  if(listaTimesFirebase.isEmpty){
                    _recuperarTimes();
                  }else{
                    listaTimesFirebase.clear();
                    _recuperarTimes();
                  }
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
      print("TESTE REGIAO -> "+doc["nome"]);
      setState(() {
        listaCidadesFirebase.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

  AnimationController? _controller;
  Animation<Offset>? _posicaoAnimation;

  inicializarAnimacao() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..repeat(reverse: true);

    _posicaoAnimation = Tween(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.linear),
    );

    _posicaoAnimation?.addListener(() {setState(() {
      
    });});

  }

  @override
  void initState() {
    inicializarAnimacao();
    super.initState();
    _recuperarCidades();
    _recuperarTimes();

  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool selected = true;

  final controleCadastro = ControleCadastro(); //utilizo mobX


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Conta"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [      
                Image.asset("lib/assets/images/ic_arena.png", height: 100,), //height mexe com o tamanho da imagem
                const SizedBox(height: 16,),
                // TextField(
                //   onChanged: (value) {
                //     print("TESTENAME::: "+value.toString());
                //     if(value.isEmpty){
                //       isNameOk = false;
                //     }else{
                //       isNameOk = true;
                //     }
                //     setState(() {
                      
                //     });
                //   },
                //   controller: _controllerNome,
                //   autofocus: true,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     focusedBorder: OutlineInputBorder( //bordar selecionada
                //         borderSide: BorderSide(
                //           color: Colors.blue,
                //           width: 2,
                //         ),
                //       ),
                //     enabledBorder: OutlineInputBorder( //bordar não selecionada
                //         borderSide: BorderSide(
                //           color: isNameOk? Colors.green: Colors.red,
                //         )
                //     ),
                //     labelText: "Nome",
                //     icon: Icon(
                //       Icons.account_box_outlined,
                //       color: Colors.green,
                //       size: 24.0,
                //       semanticLabel: 'Text to announce in accessibility modes',
                //     ),
                //   ),
                // ),
                const SizedBox(height: 8,),
                // TextField(
                //   onChanged: (value) {
                //     print("TESTE::: "+value.toString());
                //     if(value.isEmpty){
                //       isEmailOk = false;
                //     }else{
                //       isEmailOk = true;
                //     }
                //     setState(() {
                      
                //     });
                //   },
                //   controller: _controllerEmail,
                //   keyboardType: TextInputType.emailAddress,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     focusedBorder: OutlineInputBorder( //bordar selecionada
                //         borderSide: BorderSide(
                //           color: Colors.blue,
                //           width: 2,
                //         ),
                //     ),
                //     enabledBorder: OutlineInputBorder( //bordar não selecionada
                //         borderSide: BorderSide(
                //         color: isEmailOk ? Colors.green: Colors.red,
                //       ),
                //     ),
                //     labelText: "E-mail",
                //     hintText: "exemplo@exemplo.com",
                //     icon: Icon(
                //       Icons.email,
                //       color: Colors.green,
                //       size: 24.0,
                //       semanticLabel: 'Text to announce in accessibility modes',
                //     ),
                //   ),
                // ),
                const SizedBox(height: 8,),
                // TextField(
                //   onChanged: ((value) {
                //     print("TESTE::: "+value.toString());
                //     if(value.isEmpty){
                //       isSenhaOk = false;
                //     }else{
                //       isSenhaOk = true;
                //     }
                //     setState(() {
                      
                //     });
                //   }),
                //   controller: _controllerSenha,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     focusedBorder: OutlineInputBorder( //borda selecionada
                //         borderSide: BorderSide(
                //           color: Colors.blue,
                //           width: 2,
                //         ),
                //     ),
                //     enabledBorder: OutlineInputBorder( //borda não selecionada
                //         borderSide: BorderSide(
                //           color: isSenhaOk? Colors.green: Colors.red,
                //         ),
                //     ),
                //     labelText: "Senha",
                //     icon: Icon(
                //       Icons.key,
                //       color: Colors.green,
                //       size: 24.0,
                //       semanticLabel: 'Text to announce in accessibility modes',
                //     ),
                //   ),
                //   obscureText: true,
                // ),
                const SizedBox(height: 16,),
                Observer(
                  builder: (_){
                    return ArenaTextField(
                      labelText: "Nome",
                      onChaged: controleCadastro.user.changeName,
                      errorText: controleCadastro.validateName,
                      icon: Icon(
                        Icons.account_box_outlined,
                        color: controleCadastro.validateName() == null ? Colors.green : Colors.red,
                        size: 24.0,
                        semanticLabel: 'Text to announce in accessibility modes',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16,),
                Observer(
                  builder: (_){
                    return ArenaTextField(
                      labelText: "E-mail",
                      keyboardType: TextInputType.emailAddress,
                      onChaged: controleCadastro.user.changeEmail,
                      errorText: controleCadastro.validateEmail,
                      icon: Icon(
                        Icons.email,
                        color: controleCadastro.validateEmail() == null ? Colors.green : Colors.red,
                        size: 24.0,
                        semanticLabel: 'Text to announce in accessibility modes',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16,),
                Observer(
                  builder: (_){
                    return ArenaTextField(
                      labelText: "Senha",
                      onChaged: controleCadastro.user.changeSenha,
                      errorText: controleCadastro.validateSenha,
                      icon: Icon(
                        Icons.key,
                        color: controleCadastro.validateSenha() == null ? Colors.green : Colors.red,
                        size: 24.0,
                        semanticLabel: 'Text to announce in accessibility modes',
                      ),
                      obscureText: true,
                    );
                  },
                ),
                const SizedBox(height: 8,),
                const Text("Região:", style: TextStyle(fontSize: 16,),),
                _chamarDropDownCity(),
                const SizedBox(height: 8,),
                const Text("Time do coração:", style: TextStyle(fontSize: 16,),),
                _chamarDropDownTimes(),
                const SizedBox(height: 16,),
                SizedBox(
                  width: width*1,
                  height: 130,
                  child: Stack(
                    children: <Widget>[
                      AnimatedPositioned(
                        width: width*.92,
                        height: 60.0,
                        //left: selected ? 0.0 : width*.53,                        
                        top: selected ? 0.0 : 60.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.fastLinearToSlowEaseIn,
                        onEnd: () {
                          if(selected == false){
                            setState(() {
                              selected = !selected;
                            });
                          }
                        },
                        child: Observer(
                          builder: (_){
                            return ArenaButton(
                              height: 47,
                              width: width,
                              title: "CADASTRAR",
                              function: controleCadastro.enableButton ? criarUsuario : null,
                              textColor: Colors.white,
                              fontSize: 18,
                              buttonColor: controleCadastro.enableButton ? Colors.green : Colors.grey,
                              radius: 8,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // ElevatedButton(
                //       onPressed: (){
                //         criarUsuario();
                //       }, 
                //       child: const Text("CADASTRAR", style: TextStyle(color: Colors.white),),
                //       style: ButtonStyle(
                //         backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra
                //         shape: MaterialStateProperty.all<OutlinedBorder>(
                //           const RoundedRectangleBorder(
                //             side: BorderSide(
                //               color: Colors.green,
                //             ),
                //             borderRadius: BorderRadius.all(
                //               Radius.circular(8),
                //             ),
                //           ),
                //         ),
                //         fixedSize: MaterialStateProperty.all<Size>(Size(width, 47)),                    
                //       ),
                //     ),
                TextButton(
                  onPressed: (){
                    _chamarTelaLogin();
                  },
                  child: const Text("Já tenho uma conta!"),
                ),
                
              ],
            ),
          ),
        ),
    );
  }
}