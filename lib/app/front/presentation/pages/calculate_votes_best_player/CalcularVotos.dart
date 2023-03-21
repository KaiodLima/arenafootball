import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../model/Jogador.dart';

class CalcularVotos extends StatefulWidget {
  const CalcularVotos({ Key? key }) : super(key: key);

  @override
  State<CalcularVotos> createState() => _CalcularVotosState();
}

class _CalcularVotosState extends State<CalcularVotos> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerTime = TextEditingController();
  TextEditingController _controllerUrlImagem = TextEditingController();
  TextEditingController _controllerBusca = TextEditingController();
  TextEditingController _controllerVotos = TextEditingController();


  //recuperar jogador no firebase  
  _buscarJogador() async {
    String nomeJogador = _controllerBusca.text;
    int chave = 0;
    //print("${nomeJogador}");

    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db.collection("jogadores").get(); //recupera todos os jogadores

    for(var item in querySnapshot.docs){
      var jogador = item.get("nome");
      var id = item.id;
      print("TESTE ID -> "+id.toString());
      if(nomeJogador == jogador.toString()){ //filtra o jogador pesquisado
        
        _controllerNome.text = item.get("nome");
        setState(() {
          _controllerTime.text = item.get("time");
          
        });
        chave = 1;     
        
      }
      if(chave == 0){
        _controllerNome.text = "";
        setState(() {
          _controllerTime.text = "";
        });
      }

    }
   _buscarVotos();

  }


//recuperar jogador no firebase
int votos = 0;
  _buscarVotos() async {
    String nomeJogador = _controllerBusca.text;
    int chave = 0;
    //print("${nomeJogador}");

    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db.collection("melhorjogador${timeSelecionado}${timeSelecionado2}").where("nome", isEqualTo: nomeJogador).get(); //recupera todos os jogadores

    for(var item in querySnapshot.docs){
      var jogador = item.get("nome");
      print("TESTE JO -> "+jogador.toString());
      if(nomeJogador == jogador.toString()){ //filtra o jogador pesquisado
        
        _controllerNome.text = item.get("nome");
        setState(() {
          _controllerTime.text = item.get("time");
          votos = votos+1;
        });
        chave = 1;     
        
      }
      if(chave == 0){
        _controllerNome.text = "";
        setState(() {
          _controllerTime.text = "";
        });
      }

    }
   setState(() {
     _controllerVotos.text = votos.toString();
     votos = 0;
   });

  }

  //capturar dados do novo jogador
  criarJogador() {
    String nomeJogador = _controllerNome.text;
    //String urlImagemJogador = _controllerUrlImagem.text;
    //validar campos:
    if (nomeJogador.isNotEmpty && nomeJogador.length >= 3) {
      if (timeSelecionado.isNotEmpty) {
        //criar jogador
        Jogador jogador = Jogador(nome: nomeJogador, time: timeSelecionado, urlImagem: "");

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

  Future<void> _cadastrarFirebase(Jogador jogador) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    db.collection("jogadores").add({
      "nome": jogador.nome,
      "time": jogador.time,
      "urlImagem": jogador.urlImagem,
      "nGols": 0,
      "nAssistencias": 0,
      "idJogador": "",
    });

    _chamarSnackBar("Jogador Cadastrado!!!");
  }

  //recuperar nomes dos time no firebase
  final List<String> listaTimesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimes() async {
    var collection =
        FirebaseFirestore.instance.collection("times"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez

    for (var doc in resultado.docs) {
      //print("TESTE -> " + doc["nome"]);
      setState(() {
        listaTimesFirebase.add(doc["nome"]); //adiciona em uma list
      });
    }
    //print("TESTE -> "+listaTimesFirebase.toString());
  }

  //chamar caixa de opções
  String timeSelecionado = 'Lava Jato';
  _chamarDropDown() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
        value: timeSelecionado,
        //icon: const Icon(Icons.arrow_downward),
        isExpanded: true,
        borderRadius: BorderRadius.circular(16),
        //elevation: 16,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        //underline: Container(height: 2, color: Colors.green,),
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
  
  //chamar caixa de opções
  String timeSelecionado2 = 'Lava Jato';
  _chamarDropDown2() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
        value: timeSelecionado2,
        //icon: const Icon(Icons.arrow_downward),
        isExpanded: true,
        borderRadius: BorderRadius.circular(16),
        //elevation: 16,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        //underline: Container(height: 2, color: Colors.green,),
        alignment: AlignmentDirectional.center,
        //dropdownColor: Colors.green,
        onChanged: (String? newValue) {
          setState(() {
            timeSelecionado2 = newValue!;
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
  void initState() {
    super.initState();
    _recuperarTimes();
  }

  pageJogador() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controllerNome,
          readOnly: true,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nome",
            icon: Icon(
              Icons.account_box_outlined,
              color: Colors.green,
              size: 24.0,              
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
          controller: _controllerTime,
          readOnly: true,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Time",
            icon: Icon(
              Icons.shield_moon_outlined,
              color: Colors.green,
              size: 24.0,              
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
          controller: _controllerVotos,
          readOnly: true,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Número de Votos",
            icon: Icon(
              Icons.numbers,
              color: Colors.green,
              size: 24.0,              
            ),
          ),
        ),
        /*TextButton(
          onPressed: () {
            //_chamarTelaLogin();
          },
          child: Text("Voltar"),
        ),*/
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CALCULAR VOTOS"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(                      
                      child: Container(
                        height: 50,
                        child: TextField(
                          controller: _controllerBusca,
                          decoration: const InputDecoration(
                            labelText: "Pesquisar",
                            border: OutlineInputBorder(),
                            icon: Icon(
                              Icons.search,
                              color: Colors.green,
                              size: 24.0,              
                            ),
                          ),
                        ),
                      )
                    ),
                    const SizedBox(width: 4,),
                    ElevatedButton(                      
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(const Size.fromHeight(50)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green), //essa merda toda pra mudar a cor do botão oporra
                      ),
                      child: const Text("BUSCAR"),
                      onPressed: (){
                        _buscarJogador();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12,),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(                  
                  children: [
                    Container(
                      //color: Colors.green,
                      margin: const EdgeInsets.only(left: 0, right: 16),
                      width: MediaQuery.of(context).size.width * 0.35, // retorna o tamanho da largura da tela
                      child: Column(
                        children: [
                          const Text("Time A:", style: TextStyle(fontSize: 16),),
                          _chamarDropDown(),
                        ],
                      ),
                    ),
                    Container(
                      //color: Colors.green,
                      margin: const EdgeInsets.only(right: 0, left: 16),
                      width: MediaQuery.of(context).size.width * 0.35, // retorna o tamanho da largura da tela
                      child: Column(
                        children: [
                          const Text("Time B:", style: TextStyle(fontSize: 16),),
                          _chamarDropDown2(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12,),
              Image.asset(
                "lib/assets/images/ic_arena.png",
                height: 100,
              ), //height mexe com o tamanho da imagem
              const SizedBox(
                height: 16,
              ),
              pageJogador(),

              
            ],
          ),
        ),
      ),
    );
  }
}