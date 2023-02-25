import 'package:arena_soccer/model/Jogador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastroAdmin extends StatefulWidget {
  const CadastroAdmin({Key? key}) : super(key: key);

  @override
  State<CadastroAdmin> createState() => _CadastroAdminState();
}

class _CadastroAdminState extends State<CadastroAdmin> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerTime = TextEditingController();
  TextEditingController _controllerUrlImagem = TextEditingController();
  TextEditingController _controllerBusca = TextEditingController();
  TextEditingController _controllerGols = TextEditingController();
  TextEditingController _controllerPasses = TextEditingController();

  bool isSelectedPlayer = false;

  String _idJogador = "";
  List<Jogador> jogadores = [];
  //recuperar jogador no firebase  
  _buscarJogador(String jogador) async {
    // String nomeJogador = _controllerBusca.text;
    String nomeJogador = jogador;
    int chave = 0;
    //print("${nomeJogador}");

    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db.collection("jogadores").get(); //recupera todos os jogadores

    for(var item in querySnapshot.docs){
      var jogador = item.get("nome");
      //print("TESTE JO -> "+jogador.toString());
      if(nomeJogador == jogador.toString()){ //filtra o jogador pesquisado
        print("ACHEI -> "+jogador.toString());
        _controllerNome.text = item.get("nome");
        _controllerUrlImagem.text = item.get("urlImagem");
        _controllerGols.text = item.get("nGols").toString();
        _controllerPasses.text = item.get("nAssistencias").toString();
        setState(() {
          _controllerTime.text = item.get("time");
          // timeSelecionado = item.get("time");
          _idJogador = item.id;
        });
        chave = 1;     
        //_editarJogadorFirebase(); //chama editar jogador
      }
      if(chave == 0){
        _controllerNome.text = "";
        _controllerUrlImagem.text = "";
        _controllerGols.text = "";
        _controllerPasses.text = "";
        setState(() {
          timeSelecionado = "Lava Jato";
          _controllerTime.text = "Lava Jato";
          _idJogador = "";
        });
      }

    }
    

  }

  //editar informações do jogador no banco de dados
  Future<void> _editarJogadorFirebase() async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    
    db.collection("jogadores").doc(_idJogador).set(
      {
        "idJogador":  _idJogador,
        "nome": _controllerNome.text,
        "time": timeSelecionado,
        "urlImagem": _controllerUrlImagem.text,
        "nGols": int.parse(_controllerGols.text),
        "nAssistencias": int.parse(_controllerPasses.text),
      }
    );

    _chamarSnackBar("Jogador Atualizado!!!");
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
    
    var addedDocRef = await db.collection("jogadores").add({
      "idJogador": "",
      "nome": jogador.nome,
      "time": jogador.time,
      "urlImagem": jogador.urlImagem,
      "nGols": 0,
      "nAssistencias": 0,
    });

    db.collection("jogadores").doc(addedDocRef.id).set({
      "idJogador": addedDocRef.id,
      "nome": jogador.nome,
      "time": jogador.time,
      "urlImagem": jogador.urlImagem,
      "nGols": 0,
      "nAssistencias": 0,
    });

    _chamarSnackBar("Jogador Cadastrado!!!");
  }

  //recuperar nomes dos time no firebase
  final List<String> listaTimesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimes() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez

    for (var doc in resultado.docs) {
      //print("TESTE -> " + doc["nome"]);
      setState(() {
        listaTimesFirebase.add(doc["nome"]); //adiciona em uma list
      });
    }
    timeSelecionado = listaTimesFirebase.first.toString();
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
    _recuperarCidades();
    _recuperarTimesSearch();
    // _recuperarJogadores();
    _recuperarTimes();
  }

  pageJogador() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controllerNome,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nome",
            icon: Icon(
              Icons.account_box_outlined,
              color: Colors.green,
              size: 24.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
          ),
        ),
        const SizedBox(height: 8,),
        Row(
          children: [
            Container(              
              width: MediaQuery.of(context).size.width * 0.35, // retorna o tamanho da largura da tela
              child: TextField(
                controller: _controllerGols,
                keyboardType: TextInputType.number,
                //autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Gols",
                  icon: Icon(
                    Icons.sports_soccer_outlined,
                    color: Colors.green,
                    size: 24.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(              
                width: MediaQuery.of(context).size.width * 0.45, // retorna o tamanho da largura da tela
                child: TextField(
                  controller: _controllerPasses,
                  keyboardType: TextInputType.number,
                  //autofocus: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Assistencias",
                    icon: Icon(
                      Icons.account_box_outlined,
                      color: Colors.green,
                      size: 24.0,
                      semanticLabel: 'Text to announce in accessibility modes',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        _chamarDropDownCity(true),
        const Text("Time:", textAlign: TextAlign.start, style: TextStyle(fontSize: 16),),
        _chamarDropDown(),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
          onPressed: () {
            criarJogador();            
          },
          child: Text("CADASTRAR"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Colors.green), //essa merda toda pra mudar a cor do botão oporra
          ),
        ),
        const SizedBox(height: 2,),
        // ElevatedButton(
        //   onPressed: () {
        //     _editarJogadorFirebase();
        //   },
        //   child: const Text("ATUALIZAR"),
        //   style: ButtonStyle(
        //     backgroundColor: MaterialStateProperty.all<Color>(
        //         Colors.green), //essa merda toda pra mudar a cor do botão oporra
        //   ),
        // ),
        /*TextButton(
          onPressed: () {
            //_chamarTelaLogin();
          },
          child: Text("Voltar"),
        ),*/
      ],
    );
  }

  widgetSearch(){
    return Padding(
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
                        _buscarJogador("");
                      },
                    ),
                  ],
                ),
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CADASTRAR JOGADOR"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          reverse: isSelectedPlayer,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // widgetSearch(),
              // Padding(
              //   padding: const EdgeInsets.only(left: 12, right: 12),
              //   child: _chamarDropDownCity(false),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 12, right: 12),
              //   child: _chamarDropDownTimesSearch(),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 12, right: 12),
              //   child: _chamarDropDownPlayers(),
              // ),
              // const SizedBox(height: 2,),
              // Padding(
              //   padding: EdgeInsets.all(6),
              //   child: _chamarDropDown(),
              // ),
              // ElevatedButton(                      
              //   style: ButtonStyle(
              //     fixedSize: MaterialStateProperty.all<Size>(const Size.fromHeight(50)),
              //     backgroundColor: MaterialStateProperty.all<Color>(
              //         Colors.green), //essa merda toda pra mudar a cor do botão oporra
              //   ),
              //   child: const Text("BUSCAR"),
              //   onPressed: (){
              //     _buscarJogador();
              //   },
              // ),
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

  String cidadeSelecionada = 'Floresta';
  _chamarDropDownCity(bool isRegister){

    return Container(
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: cidadeSelecionada,
              icon: const Icon(Icons.change_circle_outlined, color: Colors.green,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 18,),
              // underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              dropdownColor: Colors.green,
              onChanged: (String? newValue) {
                if(isRegister){
                  setState(() {
                    cidadeSelecionada = newValue!;
                    if(listaTimesFirebase.isEmpty){
                      _recuperarTimes();
                    }else{
                      listaTimesFirebase.clear();
                      _recuperarTimes();
                    }
                  });
                  
                }else{
                  setState(() {
                    cidadeSelecionada = newValue!;
                    if(listaTimesFirebaseSearch.isEmpty){
                      _recuperarTimesSearch();
                    }else{
                      listaTimesFirebaseSearch.clear();
                      _recuperarTimesSearch();
                      listaJogadoresFirebase.clear();
                      // _recuperarJogadores();
                    }
                  });
                }
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
      // print("TESTE REGIAO -> "+doc["nome"]);
      setState(() {
        listaCidadesFirebase.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

  String timeSelecionadoSearch = 'Lava Jato';
  _chamarDropDownTimesSearch(){
    
    return Container(    
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: timeSelecionadoSearch,
              icon: const Icon(Icons.change_circle_outlined, color: Colors.green,),
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
                  timeSelecionadoSearch = newValue!;
                  if(listaJogadoresFirebase.isEmpty){
                    _recuperarJogadores();
                  }else{
                    listaJogadoresFirebase.clear();
                    _recuperarJogadores();
                  }
                });
              },

              items: listaTimesFirebaseSearch.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

  //recuperar nomes dos times no firebase
  List<String> listaTimesFirebaseSearch = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimesSearch() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      setState(() {
        listaTimesFirebaseSearch.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    timeSelecionadoSearch = listaTimesFirebaseSearch.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

  String jogadorSelecionado = 'Kaio Lima';
  _chamarDropDownPlayers(){

    return Container(
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: jogadorSelecionado,
              icon: const Icon(Icons.change_circle_outlined, color: Colors.green,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 18,),
              // underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              dropdownColor: Colors.green,
              onChanged: (String? newValue) {
                setState(() {
                  
                  jogadorSelecionado = newValue!;
                  isSelectedPlayer = true;
                  _buscarJogador(jogadorSelecionado);
                });
              },

              items: listaJogadoresFirebase.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

  //recuperar nomes dos jogadores no firebase
  final List<String> listaJogadoresFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarJogadores() async {
    print("TIME SELECIONADO: "+timeSelecionadoSearch);
    var collection = FirebaseFirestore.instance.collection("jogadores").where("time", isEqualTo: timeSelecionadoSearch); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    for(var doc in resultado.docs){
      // print("TESTE REGIAO -> "+doc["nome"]);
      setState(() {
        listaJogadoresFirebase.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    jogadorSelecionado = listaJogadoresFirebase.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());
  }
}
