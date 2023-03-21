import 'package:arena_soccer/model/Noticia.dart';
import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificarGolsScreen extends StatefulWidget {
  const NotificarGolsScreen({ Key? key }) : super(key: key);

  @override
  State<NotificarGolsScreen> createState() => _NotificarGolsScreenState();
}

class _NotificarGolsScreenState extends State<NotificarGolsScreen> {
  String cidadeSelecionada = 'Floresta';
  String timeSelecionadoCasa = '';
  String timeSelecionadoFora = '';

  TextEditingController controllerGolCasa = TextEditingController();
  TextEditingController controllerGolFora = TextEditingController();

  // int idAtual = 0;

  _chamarDropDownCity(){

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
              icon: const Icon(Icons.change_circle_outlined, color: Colors.white,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.white, fontSize: 18,),
              // underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              dropdownColor: Colors.green,
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
  _chamarDropDownTimesCasa(){
    return Container(    
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: timeSelecionadoCasa,
              icon: const Icon(Icons.arrow_downward, color: Colors.white,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.white, fontSize: 18, ),
              //underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              dropdownColor: Colors.green,                            
              onChanged: (String? newValue) {
                setState(() {
                  timeSelecionadoCasa = newValue!;
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
  _chamarDropDownTimesFora(){
    return Container(    
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: timeSelecionadoFora,
              icon: const Icon(Icons.arrow_downward, color: Colors.white,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.white, fontSize: 18, ),
              //underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              dropdownColor: Colors.green,
              onChanged: (String? newValue) {
                setState(() {
                  timeSelecionadoFora = newValue!;
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
  @override
  void initState() {
    super.initState();
    _recuperarCidades();
    _recuperarTimes();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const  Color.fromARGB(255, 27, 67, 28),
      appBar: AppBar(        
        //backgroundColor: Colors.green,
        backgroundColor: const Color.fromARGB(255, 27, 67, 28),
        elevation: 0,
        title: Image.asset(
          //"lib/assets/images/ic_logo.png",
          "lib/assets/images/ic_arena.png",
          width: 110,
          height: 40,
        ),
        centerTitle: true,        
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text("Cadastrar Card de Gol:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              // const SizedBox(height: 8,),
              // SizedBox(
              //   // width: width*0.2,
              //   // height: height*.2,
              //   child: Text(
              //     "ID #"+idAtual.toString(),
              //     style: const TextStyle(
              //       fontSize: 24,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 8,),
              Container(
                // height: height*0.12,
                width: width*1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    // Container(
                    //   width: width*0.2,
                    //   height: height*.2,
                    //   child: TextField(
                    //     controller: _controllerId,
                    //     keyboardType: TextInputType.number,
                    //     onChanged: (value){

                    //     },
                    //     decoration: const InputDecoration(
                    //       border: OutlineInputBorder(),
                    //       focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                    //         borderSide: BorderSide(
                    //           color: Colors.green,
                    //           width: 2,
                    //         ),
                    //       ),
                    //       enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                    //         borderSide: BorderSide(
                    //           color: Colors.green,
                    //         ),
                    //       ),
                    //       labelText: "ID",
                    //       labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                    //     ),
                    //     textAlign: TextAlign.center,
                    //     style: const TextStyle(
                    //       fontSize: 18,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 16,),
                    const SizedBox(width: 16,),
                    // Container(
                    //   width: width*0.2,
                    //   height: height*.2,
                    //   child: TextField(
                    //     controller: _controllerExibir,
                    //     keyboardType: TextInputType.number,
                    //     onChanged: (value){

                    //     },
                    //     decoration: const InputDecoration(
                    //       border: OutlineInputBorder(),
                    //       focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                    //         borderSide: BorderSide(
                    //           color: Colors.green,
                    //           width: 2,
                    //         ),
                    //       ),
                    //       enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                    //         borderSide: BorderSide(
                    //           color: Colors.green,
                    //         ),
                    //       ),
                    //       labelText: "Exibir",
                    //       labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                    //     ),
                    //     textAlign: TextAlign.center,
                    //     style: const TextStyle(
                    //       fontSize: 18,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8,),
              const Text("Região:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              _chamarDropDownCity(),
              const SizedBox(height: 8,),
              const Text("Time da Casa:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              _chamarDropDownTimesCasa(),
              const Text("Time Visitante:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              _chamarDropDownTimesFora(),
              const SizedBox(height: 16,),
              // Text("Placar Atual:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              // const SizedBox(height: 8,),

              const SizedBox(height: 16,),
              const Text("Placar:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              const SizedBox(height: 8,),
              Container(
                height: height*0.12,
                width: width*1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: width*0.2,
                      height: height*.2,
                      child: TextField(
                        controller: controllerGolCasa,
                        keyboardType: TextInputType.number,
                        onChanged: (value){

                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                            borderSide: BorderSide(
                              color: Colors.green,
                            ),
                          ),
                          // labelText: "Casa",
                          // labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16,),
                    const Text("X", style: TextStyle(fontSize: 24, color: Colors.white,),),
                    const SizedBox(width: 16,),
                    Container(
                      width: width*0.2,
                      height: height*.2,
                      child: TextField(
                        controller: controllerGolFora,
                        keyboardType: TextInputType.number,
                        onChanged: (value){

                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                            borderSide: BorderSide(
                              color: Colors.green,
                            ),
                          ),
                          // labelText: "Casa",
                          // labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ArenaButton(
                height: 47,
                width: width,
                title: "Publicar",
                fontSize: 16,
                textColor: Colors.white,
                buttonColor: Colors.green,                      
                radius: 8,
                function: criarNoticia,
              ),

            ],
          ),
        ),
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

  //recuperar nomes dos times no firebase
  List<String> listaTimesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarTimes() async {
    var collection = FirebaseFirestore.instance.collection("times").where("fk_competicao", isEqualTo: cidadeSelecionada); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez

    for(var doc in resultado.docs){
      // print("TESTE TIME -> "+doc["nome"]);
      setState(() {
        listaTimesFirebase.add(doc["nome"]); //adiciona em uma list
      });
      
    }
    timeSelecionadoCasa = listaTimesFirebase.first; //a primeira opção do dropdown deve ser iniciada sempre com o primeiro registro da lista
    timeSelecionadoFora = listaTimesFirebase.last;
    //print("TESTE -> "+listaTimesFirebase.toString());    

  }

  TextEditingController _controllerId = TextEditingController();
  TextEditingController _controllerExibir = TextEditingController();
  
  //capturar dados da noticia
  criarNoticia() {
    // int id_noticia = int.parse(_controllerId.text);
    // int idNoticia = idAtual;
    String titulo = "";
    String descricao = "";
    String urlImagem = "";
    String link = "";
    // String exibir = _controllerExibir.text;
    String exibir = "true";

    String fkCompeticao = cidadeSelecionada;
    String golCasa = controllerGolCasa.text;
    String golFora = controllerGolFora.text;
    String timeCasa = timeSelecionadoCasa;
    String timeFora = timeSelecionadoFora;
    String tag = "gol";

    print(" TESTE KAIO::: "+fkCompeticao+" "+golCasa+" "+golFora+" "+timeCasa+" "+timeFora+" "+tag);
    
    //validar campos:
    if (exibir.isNotEmpty) {
      //criar partida
      Noticia noticia = Noticia(
        titulo: titulo, 
        descricao: descricao, 
        urlImagem: urlImagem, 
        link: link, 
        exibir: exibir,
        fkCompeticao: fkCompeticao, 
        timeCasa: timeCasa, 
        timeFora: timeFora, 
        golTimeCasa: golCasa, 
        golTimeFora: golFora, 
        tag: tag,
      );        

      //salvar informações do jogador no banco de dados
      _cadastrarFirebase(noticia);
    } else {      
      _chamarSnackBar("Preencha todos os campos!!!");
    }
  }

  //cadastrar informações no banco de dados
  Future<void> _cadastrarFirebase(Noticia noticia) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    //aqui estou usando o uid do usuário logado pra salvar como  id na colection de dados
    var addedDocRef = await  db.collection("noticias").add({
      "id": "",
      "data": FieldValue.serverTimestamp(),

      "titulo": noticia.titulo,
      "descricao": noticia.descricao,
      "urlImagem": noticia.urlImagem,
      "link": noticia.link,
      "exibir": noticia.exibir,

      "fk_competicao": noticia.fkCompeticao,
      "time_casa": noticia.timeCasa,
      "time_fora": noticia.timeFora,
      "gol_time_casa": noticia.golTimeCasa,
      "gol_time_fora": noticia.golTimeFora,
      "tag": noticia.tag

    });

    db.collection("noticias").doc(addedDocRef.id).set({
      "id": addedDocRef.id,
      "data": FieldValue.serverTimestamp(),

      "titulo": noticia.titulo,
      "descricao": noticia.descricao,
      "urlImagem": noticia.urlImagem,
      "link": noticia.link,
      "exibir": noticia.exibir,

      "fk_competicao": noticia.fkCompeticao,
      "time_casa": noticia.timeCasa,
      "time_fora": noticia.timeFora,
      "gol_time_casa": noticia.golTimeCasa,
      "gol_time_fora": noticia.golTimeFora,
      "tag": noticia.tag

    });

    _chamarSnackBar("Gol registrado com Sucesso!!!");
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

}