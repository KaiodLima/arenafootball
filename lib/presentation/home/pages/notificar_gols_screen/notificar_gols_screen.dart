import 'package:arena_soccer/model/Noticia.dart';
import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:arena_soccer/presentation/home/pages/notificar_gols_screen/notificar_gols_screen_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class NotificarGolsScreen extends StatefulWidget {
  const NotificarGolsScreen({ Key? key }) : super(key: key);

  @override
  State<NotificarGolsScreen> createState() => _NotificarGolsScreenState();
}

class _NotificarGolsScreenState extends State<NotificarGolsScreen> {
  final _controller = NotificarGolsScreenController(); //utilizo mobX
  
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
              value: _controller.cidadeSelecionada,
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
                  _controller.cidadeSelecionada = newValue!;
                  if(_controller.listaTimesFirebase.isEmpty){
                    _controller.recuperarTimes();
                  }else{
                    _controller.listaTimesFirebase.clear();
                    _controller.recuperarTimes();
                  }
                });
              },

              items: _controller.listaCidadesFirebase.map<DropdownMenuItem<String>>((String value) {
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
              value: _controller.timeSelecionadoCasa,
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
                  _controller.timeSelecionadoCasa = newValue!;
                });
              },

              items: _controller.listaTimesFirebase.map<DropdownMenuItem<String>>((String value) {
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
              value: _controller.timeSelecionadoFora,
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
                  _controller.timeSelecionadoFora = newValue!;
                });
              },

              items: _controller.listaTimesFirebase.map<DropdownMenuItem<String>>((String value) {
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
    _controller.recuperarCidades();
    _controller.recuperarTimes();
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
              Observer(builder: (_){
                return _chamarDropDownCity();
              }),
              const SizedBox(height: 8,),
              const Text("Time da Casa:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              Observer(builder: (_){
                return _chamarDropDownTimesCasa();
              }),
              const Text("Time Visitante:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              Observer(builder: (_){
                return _chamarDropDownTimesFora();
              }),
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
                        controller: _controller.controllerGolCasa,
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
                        controller: _controller.controllerGolFora,
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
                borderRadius: 8,
                function: () async {
                  await _controller.changeLoading(true);
                  
                  _controller.criarCardGol(context);
                  await _controller.changeLoading(false);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }


  TextEditingController _controllerId = TextEditingController();
  TextEditingController _controllerExibir = TextEditingController();
  
}