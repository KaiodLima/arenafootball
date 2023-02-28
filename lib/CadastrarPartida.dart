import 'package:arena_soccer/model/Partida.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastrarPartida extends StatefulWidget {
  const CadastrarPartida({ Key? key }) : super(key: key);

  @override
  State<CadastrarPartida> createState() => _CadastrarPartidaState();
}

class _CadastrarPartidaState extends State<CadastrarPartida> {
  TextEditingController _controllerIdPartida = TextEditingController();
  TextEditingController _controllerTimeC = TextEditingController();
  TextEditingController _controllerTimeF = TextEditingController();
  TextEditingController _controllerHorario = TextEditingController();
  TextEditingController _controllerLocal = TextEditingController();
  TextEditingController _controllerData = TextEditingController();

  // int idAtual = 0;

  int buscarIdCampeonato(String regiao){
    switch (regiao) {
      case "Floresta":
        return 1;
      case "Santo inacio":
        return 2;
      default:
        return 0;
    }
  }

  //capturar dados da partida
  criarPartida() {
    // String id_partida = idAtual.toString();
    // String id_partida = _controllerIdPartida.text;
    String timeC = timeSelecionadoCasa;
    String timeF = timeSelecionadoFora;
    // String timeC = _controllerTimeC.text;
    // String timeF = _controllerTimeF.text;
    String horario = _controllerHorario.text;
    String local = _controllerLocal.text;
    String data = _controllerData.text;
    int idCampeonato = buscarIdCampeonato(cidadeSelecionada);
    
    //validar campos:
    if ((timeC.isNotEmpty && timeC.length >= 3) && (timeF.isNotEmpty && timeF.length >= 3)) {
      //criar partida
      Partida partida = Partida(
        // idPartida: id_partida, 
        timeC: timeC, 
        timeF: timeF, 
        horario: horario, 
        local: local, 
        data: data,
        fkPartida: cidadeSelecionada,
        idCampeonato: idCampeonato,
      );

      //salvar informações do jogador no banco de dados
      _cadastrarFirebase(partida);
    } else {      
      _chamarSnackBar("Preencha todos os campos!!!");
    }
  }

  //cadastrar informações do usuário no banco de dados
  Future<void> _cadastrarFirebase(Partida partida) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    
    var addedDocRef = await db.collection("partidas2023").add({
      "id_partida": "",
      "dataRegistro": FieldValue.serverTimestamp(),

      "timeC": partida.timeC,
      "timeF": partida.timeF,
      "horario": partida.horario,
      "id_campeonato":partida.getIdCampeonato,
      "local": partida.local,
      "data": partida.data,

      "golTimeCasa": 0,
      "golTimeFora": 0,

      "quantidadeVotos": "",
      "tituloVotacao": "",
      "votacao": "false",
      "melhorJogador": "",

      "fk_competicao":partida.fkPartida,

    });
    
    db.collection("partidas2023").doc(addedDocRef.id).set({
      "id_partida": addedDocRef.id,
      "dataRegistro": FieldValue.serverTimestamp(),

      "timeC": partida.timeC,
      "timeF": partida.timeF,
      "horario": partida.horario,
      "id_campeonato":partida.getIdCampeonato,
      "local": partida.local,
      "data": partida.data,

      "golTimeCasa": 0,
      "golTimeFora": 0,

      "quantidadeVotos": "",
      "tituloVotacao": "",
      "votacao": "false",
      "melhorJogador": "",

      "fk_competicao":partida.fkPartida,

    });

    _chamarSnackBar("Partida Cadastrada com Sucesso!!!");
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

  pageJogador() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row(
        //   children: [
        //     const Icon(
        //       Icons.numbers,
        //       color: Colors.green,
        //       size: 24.0,              
        //     ),
        //     Text(
        //       idAtual.toString(), 
        //       style: const TextStyle(fontSize: 18),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 16,),
        const Text(
          "Região:", 
          style: TextStyle(fontSize: 18),
        ),
        _chamarDropDownCity(false),
        // TextField(
        //   controller: _controllerIdPartida,
        //   //autofocus: true,
        //   decoration: const InputDecoration(
        //     border: OutlineInputBorder(),
        //     labelText: "ID",
        //     icon: Icon(
        //       Icons.numbers,
        //       color: Colors.green,
        //       size: 24.0,              
        //     ),
        //   ),
        // ),
        const SizedBox(height: 16,),
        // TextField(
        //   controller: _controllerTimeC,
        //   //autofocus: true,
        //   decoration: const InputDecoration(
        //     border: OutlineInputBorder(),
        //     labelText: "Time A",
        //     icon: Icon(
        //       Icons.shield,
        //       color: Colors.green,
        //       size: 24.0,              
        //     ),
        //   ),
        // ),
        Row(
          children: const [
            Icon(
              Icons.shield,
              color: Colors.green,
              size: 24.0,              
            ),
            SizedBox(width: 8,),
            Text(
              "Time Casa:", 
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        _chamarDropDownTimesCasa(),
        const SizedBox(height: 16,),
        // TextField(
        //   controller: _controllerTimeF,
        //   //autofocus: true,
        //   decoration: const InputDecoration(
        //     border: OutlineInputBorder(),
        //     labelText: "Time B",
        //     icon: Icon(
        //       Icons.shield_outlined,
        //       color: Colors.green,
        //       size: 24.0,              
        //     ),
        //   ),
        // ),
        Row(
          children: const [
            Icon(
              Icons.shield_outlined,
              color: Colors.green,
              size: 24.0,              
            ),
            SizedBox(width: 8,),
            Text(
              "Time Fora:", 
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        _chamarDropDownTimesFora(),
        const SizedBox(height: 16,),      
        TextField(
          controller: _controllerData,
          keyboardType: TextInputType.datetime,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Data",
            icon: Icon(
              Icons.calendar_month,
              color: Colors.green,
              size: 24.0,              
            ),
          ),
        ),
        const SizedBox(height: 16,),      
        TextField(
          controller: _controllerHorario,
          keyboardType: TextInputType.datetime,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Hora",
            icon: Icon(
              Icons.lock_clock,
              color: Colors.green,
              size: 24.0,              
            ),
          ),
        ),
        const SizedBox(height: 16,),      
        TextField(
          controller: _controllerLocal,
          //autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Local",
            icon: Icon(
              Icons.stadium,
              color: Colors.green,
              size: 24.0,              
            ),
          ),
        ),
        const SizedBox(height: 16,),      
        ElevatedButton(
          onPressed: () {
            criarPartida();            
          },
          child: Text("CADASTRAR"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra
          ),
        ),
        const SizedBox(height: 2,),       
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _recuperarCidades();
    _recuperarTimesCasa();
    _recuperarTimesFora();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CADASTRAR PARTIDA"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [              
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
                  
                  
                }else{
                  setState(() {
                    cidadeSelecionada = newValue!;
                    if(listaTimesFirebaseCasa.isEmpty){
                      _recuperarTimesCasa();
                      _recuperarTimesFora();
                    }else{
                      listaTimesFirebaseCasa.clear();
                      _recuperarTimesCasa();
                      listaTimesFirebaseFora.clear();
                      _recuperarTimesFora();
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


  String timeSelecionadoCasa = 'Lava Jato';
  _chamarDropDownTimesCasa(){
    
    return Container(    
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: timeSelecionadoCasa,
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
                  timeSelecionadoCasa = newValue!;
                });
              },

              items: listaTimesFirebaseCasa.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

  //recuperar nomes dos times no firebase
  List<String> listaTimesFirebaseCasa = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimesCasa() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      setState(() {
        listaTimesFirebaseCasa.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    timeSelecionadoCasa = listaTimesFirebaseCasa.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }


  String timeSelecionadoFora = 'Lava Jato';
  _chamarDropDownTimesFora(){
    
    return Container(    
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: timeSelecionadoFora,
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
                  timeSelecionadoFora = newValue!;
                });
              },

              items: listaTimesFirebaseFora.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

  //recuperar nomes dos times no firebase
  List<String> listaTimesFirebaseFora = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimesFora() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez
    
    for(var doc in resultado.docs){
      print("TESTE TIME -> "+doc["nome"]);
      setState(() {
        listaTimesFirebaseFora.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    timeSelecionadoFora = listaTimesFirebaseFora.last; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

}