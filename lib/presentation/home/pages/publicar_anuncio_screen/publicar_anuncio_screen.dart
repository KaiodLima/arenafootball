import 'dart:math';
import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:arena_soccer/app/front/presentation/components/dropdown_field/dropdown_field.dart';
import 'package:arena_soccer/presentation/home/pages/publicar_anuncio_screen/publicar_anuncio_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class PublicarAnuncioScreen extends StatefulWidget {
  const PublicarAnuncioScreen({Key? key}) : super(key: key);

  @override
  State<PublicarAnuncioScreen> createState() => _PublicarAnuncioScreenState();
}

class _PublicarAnuncioScreenState extends State<PublicarAnuncioScreen> {
  final _controller = PublicCardScreenController(); //utilizo mobX

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

  @override
  void initState() {
    super.initState();
    _controller.recuperarCidades();
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
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text("Cadastrar Card de Publicidade:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              const SizedBox(height: 8,),
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
              const SizedBox(height: 16,),
              const Text("Região:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              const SizedBox(height: 8,),
              Observer(builder: (_){
                return _chamarDropDownCity();
              }),
              const SizedBox(height: 32,),
              // const Text("Time da Casa:", style: TextStyle(fontSize: 24, color: Colors.white,),),
              SizedBox(
                width: width*1,
                // height: height*.2,
                child: TextField(
                  controller: _controller.controllerTitulo,
                  onChanged: (value){

                  },
                  cursorColor: Colors.white,
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
                    labelText: "Titulo",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                    icon: Icon(
                      Icons.text_fields_outlined,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              Observer(builder: (_){
                return _controller.imageFile != null? Container(          
                  margin: const EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 1,
                  child: Image.file(_controller.imageFile!),
                ): Container();
              }),
              // _controller.imageFile != null? Container(          
              //   margin: const EdgeInsets.all(10),
              //   height: MediaQuery.of(context).size.height * 0.3,
              //   width: MediaQuery.of(context).size.width * 1,
              //   child: Image.file(_controller.imageFile!),
              // ): Container(),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,          
                  children: [              
                    Container(
                      width: 150,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () {                    
                          //Tirar foto:
                          // getImageCamera();
                          _controller.recoveryImage(true);
                                      
                        },
                        label: const Text("Tirar foto"),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra
                        ),
                      ),
                    ),              
                    Container(                
                      width: 150,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.attach_file, color: Colors.green,),
                        onPressed: () {
                          //buscar na galeria
                          // getImageGalery();
                          _controller.recoveryImage(false);
                                      
                        },
                        label: const Text("Galeria", style: TextStyle(color: Colors.green),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.white), //essa merda toda pra mudar a cor do botão oporra                
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8,),
              SizedBox(
                width: width*1,
                child: TextField(
                  controller: _controller.controllerDescricao,
                  maxLines: 5,
                  cursorColor: Colors.white,
                  //autofocus: true,
                  style: const TextStyle(color: Colors.white),
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
                    labelText: "Descricao",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.white, ),
                    icon: Icon(
                      Icons.text_fields_outlined,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              SizedBox(
                width: width*1,
                // height: height*.2,
                child: TextField(
                  controller: _controller.controllerLink,
                  onChanged: (value){

                  },
                  cursorColor: Colors.white,
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
                    labelText: "Link",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                    icon: Icon(
                      Icons.link,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              SizedBox(
                width: width*1,
                // height: height*.2,
                child: Observer(builder: (_) {
                  return ArenaDropdownField(
                    controllerPublic: _controller,
                    textColorInactive: Colors.grey,
                    icon: Icon(
                      Icons.visibility,
                      color: _controller.validateExibition() == null
                          ? Colors.green
                          : Colors.red,
                      size: 24.0,
                    ),
                  );
                }),
                // child: TextField(
                //   controller: _controller.controllerExibir,
                //   onChanged: (value){

                //   },
                //   cursorColor: Colors.white,
                //   decoration: const InputDecoration(
                //     border: OutlineInputBorder(),
                //     focusedBorder: OutlineInputBorder( //quando a borda é selecionada
                //       borderSide: BorderSide(
                //         color: Colors.green,
                //         width: 2,
                //       ),
                //     ),
                //     enabledBorder: OutlineInputBorder( //quando a borda não está selecionada
                //       borderSide: BorderSide(
                //         color: Colors.green,
                //       ),
                //     ),
                //     labelText: "Exibir (true ou false)",
                //     labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                //     // icon: Icon(
                //     //   Icons.sort,
                //     //   color: Colors.white,
                //     //   size: 24.0,
                //     // ),
                //   ),
                //   textAlign: TextAlign.start,
                //   style: const TextStyle(
                //     fontSize: 18,
                //     color: Colors.white,
                //   ),
                // ),
              ),
              const SizedBox(height: 16,),
              Observer(
                builder: (context) {
                  return ArenaButton(
                    height: 47,
                    width: width,
                    isLoading: _controller.isLoading,
                    title: "Publicar",
                    fontSize: 16,
                    textColor: Colors.white,
                    buttonColor: Colors.green,                      
                    borderRadius: 8,
                    function: () async {
                      await _controller.changeLoading(true);
                      Random random = Random();
                      int randomNumber = random.nextInt(100000);
                      
                      if(_controller.imageFile != null){
                        await _controller.uploadPhoto(_controller.imageFile!, "noticias${_controller.controllerTitulo.text+randomNumber.toString()}");
                      }
                      await _controller.changeLoading(false);
                      
                      _controller.criarAnuncio(context);
                      _controller.chamarSnackBar("Publicidade registrada com Sucesso!!!", context);
                    },
                  );
                }
              ),

            ],
          ),
        ),
      ),
    );
  }

}