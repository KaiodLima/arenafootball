import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart' as core;

import 'package:arena_soccer/model/Jogador.dart';
import 'package:arena_soccer/model/Usuario.dart';
import 'package:arena_soccer/presentation/cadastro/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';

class ExibirJogadores extends StatefulWidget {
  String? nomeTime; //recebe a variável enviada da outra tela
  String? ano;
  Usuario? usuario;

  ExibirJogadores({
    Key? key,
    this.nomeTime,
    this.ano,
    this.usuario,
  }) : super(key: key); //construtor

  @override
  State<ExibirJogadores> createState() => _ExibirJogadoresState();
}

class _ExibirJogadoresState extends State<ExibirJogadores> {
  var player = User(); //usar o mobx

  TextEditingController _controllerNomejogador = TextEditingController();
  //recuperar jogador no firebase
  Jogador? _jogadorSelecionado;
  _chamarStatusJogador(String idJogadorSelecionado) async {
    _jogadorSelecionado = await _recuperarJogador(idJogadorSelecionado);
    player.setGol(_jogadorSelecionado?.getNGols ?? 0);
    player.setAssistencia(_jogadorSelecionado?.getNAssistencias ?? 0);
    _controllerNomejogador.clear();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: (widget.usuario?.getIsAdmin == true) 
          ? TextField(
            controller: _controllerNomejogador,
            textAlign: TextAlign.center,
            //autofocus: true,
            onSubmitted: (value) {
              criarJogador(value);
              _jogadorSelecionado?.nome = value;
            },
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "${_jogadorSelecionado?.nome}",
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(
                Icons.edit,
                color: Colors.green,
                size: 20,
              ),
            ),
          )
          : Text(
            "${_jogadorSelecionado?.nome}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //se tem imagem exibe, se não tem busca uma padrão no asset:
                  if (_jogadorSelecionado!.urlImagem!.isNotEmpty)
                    if (widget.usuario?.getIsAdmin == true)
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CachedNetworkImage(
                              imageUrl: _jogadorSelecionado!.urlImagem.toString(),
                              fit: BoxFit.scaleDown,
                              placeholder: (context, url) =>
                                  const Center(child: CircularProgressIndicator(
                                    color: Colors.green,
                                  )),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () async {
                                    await _addImage();
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.photo_camera,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      CachedNetworkImage(
                        imageUrl: _jogadorSelecionado!.urlImagem.toString(),
                        fit: BoxFit.scaleDown,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                  /*Container(
                      height: 100,
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.green),
                        image: DecorationImage(
                          fit: BoxFit.scaleDown,
                          image: NetworkImage(_jogadorSelecionado!.urlImagem.toString()),
                        ),
                      ),
                    )*/
                  else if (widget.usuario?.getIsAdmin == true)
                    CircleAvatar(
                      maxRadius: 70,
                      backgroundColor: Colors.white,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "lib/assets/images/avatar.png",
                            height: 100,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () async {
                                await _addImage();
                                // Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.photo_camera,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Image.asset(
                      "lib/assets/images/avatar.png",
                      height: 100,
                    ),
          
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    "Time: ${_jogadorSelecionado?.time}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.usuario?.getIsAdmin == true)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            onPressed: () {
                              player.removeGol();
                              criarJogador(null);
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      Observer(builder: (_) {
                        return Text(
                          // "Gols: ${_jogadorSelecionado!.nGols}",
                          "Gols: ${player.nGols.toString()}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        );
                      }),
                      if (widget.usuario?.getIsAdmin == true)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            onPressed: () {
                              player.addGol();
                              criarJogador(null);
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.usuario?.getIsAdmin == true)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            onPressed: () {
                              player.removeAssistencia();
                              criarJogador(null);
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      Observer(builder: (_) {
                        return Text(
                          // "Assistências: ${_jogadorSelecionado?.nAssistencias}",
                          "Assistências: ${player.nAssistencias}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        );
                      }),
                      if (widget.usuario?.getIsAdmin == true)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          child: IconButton(
                            onPressed: () {
                              player.addAssistencia();
                              criarJogador(null);
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                    ],
                  ),
                  //exemplo de hiperlink
                  /*GestureDetector(
                    child: Text("Link de Teste",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue)),
                    onTap: () async {
                      const url = 'https://www.youtube.com';
                      if (await canLaunch(url)) launch(url);
                    },
                  )*/
                  //outro exemplo:
                  /*InkWell(
                    child: new Text('Open Browser', style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue),),
                    onTap: () => launch('https://docs.flutter.io/flutter/services/UrlLauncher-class.html')
                  ),*/
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  Future<Jogador> _recuperarJogador(String idJogadorSelecionado) async {
    var collection = FirebaseFirestore.instance
        .collection("jogadores")
        .doc(idJogadorSelecionado); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez

    //print("TESTE -> ${resultado.get("nome")}");
    Jogador jogador = Jogador(
      idJogador: resultado.get("idJogador"),
      nome: resultado.get("nome"),
      time: resultado.get("time"),
      urlImagem: resultado.get("urlImagem"),
    );
    jogador.nGols = resultado.get("nGols");
    jogador.nAssistencias = resultado.get("nAssistencias");

    return jogador;
  }

  int? anoAtual;
  getAnoAtual(){
    anoAtual = DateTime.now().year;
    print('Ano atual: $anoAtual');

  }

  @override
  void initState() {
    getAnoAtual();
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 67, 28),
        title: Text("${widget.nomeTime}"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        //recupera os dados toda vez que o banco é modificado
        // stream: FirebaseFirestore.instance
        //     .collection("jogadores")
        //     .where("time", isEqualTo: widget.nomeTime.toString())
        //     .snapshots(), //passa uma stream de dados
        stream: (widget.ano.toString() != anoAtual.toString())
        ? FirebaseFirestore.instance.collection("jogadores${widget.ano}").where("time", isEqualTo: widget.nomeTime.toString()).snapshots()
        : FirebaseFirestore.instance.collection("jogadores").where("time", isEqualTo: widget.nomeTime.toString()).snapshots(), //passa uma stream de dados
        builder: (context, snapshot) {
          //verificação de estado
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<DocumentSnapshot> jogador = snapshot.data!.docs;

              if (jogador.isEmpty) {
                return const Center(
                  child: Text(
                    "Jogadores ainda não registrados!",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: jogador.length,
                  itemBuilder: (context, index) {
                    //monta interface
                    return GestureDetector(
                      onTap: () {
                        //quando um jogador é clicado:
                        _chamarStatusJogador(jogador[index].id.toString());
                      },
                      child: Column(
                        children: [
                          /*Container(
                          height: 100,
                          decoration: BoxDecoration(
                            //border: Border.all(color: Colors.green),
                            image: DecorationImage(
                              fit: BoxFit.scaleDown,
                              image: NetworkImage(time[index].get("urlImagem").toString()),
                            ),
                          ),
                        ),*/
                          if (jogador[index]
                              .get("urlImagem")
                              .toString()
                              .isNotEmpty)
                            ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              trailing: const Icon(
                                Icons.more_vert,
                                size: 30,
                              ), //adiciona ícone no final
                              //add imagem de contato
                              leading: CircleAvatar(
                                maxRadius: 30,
                                backgroundColor:
                                    const Color.fromARGB(255, 134, 143, 134),
                                backgroundImage: NetworkImage(
                                    jogador[index].get("urlImagem").toString()),
                              ),
                              title: Text(
                                jogador[index]
                                    .get("nome"), //recuperar título da noticia
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 110, 7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              subtitle: Text(jogador[index]
                                  .get("time")), //recuperar nome do jogador
                            )
                          else
                            ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              trailing: const Icon(
                                Icons.more_vert,
                                size: 30,
                              ), //adiciona ícone no final
                              //add imagem de contato
                              leading: const CircleAvatar(
                                maxRadius: 30,
                                backgroundColor:
                                    Color.fromARGB(255, 134, 143, 134),
                                //backgroundImage: NetworkImage(jogador[index].get("urlImagem").toString()),
                              ),
                              title: Text(
                                jogador[index]
                                    .get("nome"), //recuperar título da noticia
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 110, 7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              subtitle: Text(jogador[index]
                                  .get("time")), //recuperar nome do jogador
                            ),
                        ],
                      ),
                    );
                  },
                );
              }
          }
        },
      ),
    );
  }

  _addImage() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            Observer(builder: (_) {
              return Column(
                children: [
                  // imageFile != null
                  player.imagePlayer != null
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
                  imageFile == null
                      ? Row(
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
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra
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
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Container(
                                width: 150,
                                height: 50,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    //buscar na galeria
                                    print("Voltar!");
                                    setState(() {
                                      imageFile = null;
                                      player.addImagePlayer(null);
                                    });
                                    Navigator.pop(context);
                                  },
                                  label: const Text(
                                    "Voltar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(Colors
                                            .red), //essa merda toda pra mudar a cor do botão oporra
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
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    print("Salvar!");
                                    Random random = Random();
                                    int randomNumber = random.nextInt(100000);

                                    if(imageFile != null){
                                      await uploadPhoto(imageFile!, "jogadores${_jogadorSelecionado!.nome.toString() + randomNumber.toString()}");
                                    }

                                    criarJogador(null);
                                    Navigator.pop(context);
                                  },
                                  label: const Text(
                                    "Salvar",
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
                          ],
                        ),
                ],
              );
            }),
          ],
        );
      },
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
      _image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
      imageTemporary = File(_image!.path);
    }

    setState(() {
      imageFile = imageTemporary;
      _image = imageSelected;
      player.addImagePlayer(imageFile.toString());
    });
  }

  String? urlDownloadImage;
  Future<void> uploadPhoto(File Image, String fileName) async {
    try {
      var result = await storage.FirebaseStorage.instance
          .ref("jogadores/$fileName")
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

  criarJogador(String? textController) {
    String idJogador = _jogadorSelecionado!.getIdjogador;
    String nomeJogador =  textController ?? _jogadorSelecionado!.getNome;
    String timeSelecionado = _jogadorSelecionado!.getTime;
    String urlImagem = urlDownloadImage?.toString() ?? _jogadorSelecionado!.getUrlImagem.toString();
    // int nGols = _jogadorSelecionado!.getNGols;
    // int nAssistencias = _jogadorSelecionado!.getNAssistencias;
    int nGols = player.nGols;
    int nAssistencias = player.nAssistencias;

    //validar campos:
    if (nomeJogador.isNotEmpty && nomeJogador.length >= 3) {
      if (timeSelecionado.isNotEmpty) {
        //criar jogador
        Jogador jogador = Jogador(
          idJogador: idJogador,
          nome: nomeJogador,
          time: timeSelecionado,
          urlImagem: urlImagem,
          nGols: nGols,
          nAssistencias: nAssistencias,
        );

        //salvar informações do jogador no banco de dados
        _cadastrarFirebase(jogador);
      } else {
        //print("Informe um Time!!!");
        _chamarSnackBar("Informe um Time!!!");
      }
    } else {
      //print("Preencha o campo NOME!!!");
      _chamarSnackBar("Preencha o campo NOME!!!");
    }
  }

  //cadastrar informações do usuário no banco de dados
  Future<void> _cadastrarFirebase(Jogador jogador) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    //aqui estou usando o uid do usuário logado pra salvar como  id na colection de dados
    db.collection("jogadores").doc(_jogadorSelecionado!.getIdjogador).set({
      "idJogador": jogador.idJogador,
      "nome": jogador.nome,
      "time": jogador.time,
      "urlImagem": jogador.urlImagem,
      "nGols": jogador.nGols,
      "nAssistencias": jogador.getNAssistencias,
    });

    // _chamarSnackBar("Sucesso!!!");
  }

  var _snackBar;
  _chamarSnackBar(texto) {
    _snackBar = SnackBar(
      content: Text(texto),
    );

    if (_snackBar != null) {
      ScaffoldMessenger.of(context).showSnackBar(_snackBar); //chama o snackBar
      //limpa snackbar
      _snackBar = "";
    }
  }
}
