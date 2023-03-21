import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MelhorDaPartida extends StatefulWidget {
  String? timeC; //recebe a variável enviada da outra tela
  String? timeF;
  String? tituloVotacao;

  MelhorDaPartida({this.timeC, this.timeF, this.tituloVotacao}); //construtor

  @override
  State<MelhorDaPartida> createState() => _MelhorDaPartidaState();
}

class _MelhorDaPartidaState extends State<MelhorDaPartida> {
  //recuperar nomes dos time no firebase
  List<String> _listaTimeC = [];
  List<String> _listaTimeF = [];
  _recuperarJogadores(String nomeTime) async {
    var collection = FirebaseFirestore.instance.collection("jogadores").where("time", isEqualTo: nomeTime); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez

    List<String> auxiliar = [];
    for (var doc in resultado.docs) {
      print("TESTE Melhor -> " + doc["nome"]);
      auxiliar.add(doc["nome"]); //adiciona em uma list
    }
    //print("TESTE -> "+listaTimesFirebase.toString());
    setState(() {
      if(nomeTime == widget.timeC){
        _listaTimeC = auxiliar;
      }else{
        _listaTimeF = auxiliar;
      }
    });
  }

  
  String _nomeJogador = "";
  String _timeJogador = "";
  Future<void> _salvarVoto() async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    //aqui estou usando o uid do usuário logado pra salvar como id na colection de dados
    db.collection("melhorjogador${widget.timeC}${widget.timeF}").doc(FirebaseAuth.instance.currentUser!.uid.toString()).set(
      {
        "nome": _nomeJogador,
        "time": _timeJogador,
      }
    );

    _chamarSnackBar("Voto registrado! Você votou em ${_nomeJogador}. Muito obrigado pelo seu voto.");
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
    
    _recuperarJogadores(widget.timeC.toString());
    _recuperarJogadores(widget.timeF.toString());
  }


  int _selecionadoTC = 0;  
  int _selecionadoTF = 0;
  bool _habilitaTC = true;
  bool _habilitaTF = false;
  @override
  Widget build(BuildContext context) {   

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.tituloVotacao}"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Atenção: O VOTO É ÚNICO! Você pode alterar sua opção de voto quantas vezes quiser, mas apenas o último voto é contabilizado!",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width * 0.45,
                    //color: Colors.red,            
                    child: ListView.builder(
                      itemCount: _listaTimeC.length,
                      itemBuilder: (context, index) {                             
                        return GestureDetector(
                          child: Card(
                            child: ListTile(
                              enabled: _habilitaTC,                      
                              selected: _selecionadoTC==index?true:false, //faz a comparação
                              selectedColor: Colors.white,
                              selectedTileColor: _habilitaTC? Colors.green:  Colors.white,
                              title: Text(
                                "${_listaTimeC[index].toString()}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("${widget.timeC}"),
                            ),
                          ),
                          onTap: (){
                            if(_habilitaTC){//com a lista habilitada escolhe o jogador
                              print("Jogador escolhido: "+_listaTimeC[index].toString());
                              setState(() {
                                _selecionadoTC = index;
                                //capturando dados
                                _nomeJogador = _listaTimeC[index].toString();  
                                _timeJogador = widget.timeC.toString();                    
                              });
                            }else{//se a lista está desabilitada e é clicada, desabilita a lista anterior e:
                              print("Habilita essa lista");
                              setState(() {
                                _habilitaTC = true;
                                _habilitaTF = false;
                                
                                _selecionadoTC = index;
                                //capturando dados
                                _nomeJogador = _listaTimeC[index].toString();  
                                _timeJogador = widget.timeC.toString(); 
                              });
                            }                   
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 11,),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    //color: Colors.green,
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: ListView.builder(
                      itemCount: _listaTimeF.length,
                      itemBuilder: (context, index) {                
                
                        return GestureDetector(
                          child: Card(
                            child: ListTile(
                              enabled: _habilitaTF,
                              selected: _selecionadoTF==index?true:false, //faz a comparação
                              selectedColor: Colors.white,
                              selectedTileColor:  _habilitaTF? Colors.green:  Colors.white,
                              //tileColor: Colors.blue,                  
                              title: Text(
                                "${_listaTimeF[index].toString()}",
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("${widget.timeF}", textAlign: TextAlign.end,),
                            ),
                          ),
                          onTap: (){
                            if(_habilitaTF){
                              print("Jogador escolhido: "+_listaTimeF[index].toString());                    
                              setState(() {
                                _selecionadoTF = index;
                                //capturando dados
                                _nomeJogador = _listaTimeF[index].toString();  
                                _timeJogador = widget.timeF.toString();               
                              });
                            }else{
                              print("Habilita essa lista");
                              setState(() {
                                _habilitaTC = false;
                                _habilitaTF = true;
                                
                                _selecionadoTF = index;
                                //capturando dados
                                _nomeJogador = _listaTimeF[index].toString();  
                                _timeJogador = widget.timeF.toString(); 
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              margin: const EdgeInsets.all(4),
              child: ElevatedButton(                
                child: Text("VOTAR", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra              
                ),
                onPressed: (){
                  if(_nomeJogador != "" && _timeJogador != ""){
                    //Salvar jogador selecionado
                    _salvarVoto();
                  }else{
                    _chamarSnackBar("Voto em branco! Tente novamente.");
                  }
                },
              ),
            ),
          ),
        ],
      ),
      
    );
  }
}
