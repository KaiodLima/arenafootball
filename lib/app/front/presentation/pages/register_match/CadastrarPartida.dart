import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_match/register_new_match_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CadastrarPartida extends StatefulWidget {
  const CadastrarPartida({ Key? key }) : super(key: key);

  @override
  State<CadastrarPartida> createState() => _CadastrarPartidaState();
}

class _CadastrarPartidaState extends State<CadastrarPartida> {
  final _controller = RegisterNewMatchController(); //utilizo mobX

  // int idAtual = 0;

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
        Observer(builder: (_){
          return _chamarDropDownCity(false);
        }),
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
        Observer(builder: (_){
          return _chamarDropDownTimesCasa();
        }),
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
        Observer(builder: (_){
          return _chamarDropDownTimesFora();
        }),
        const SizedBox(height: 16,),      
        TextField(
          controller: _controller.controllerData,
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
          controller: _controller.controllerHorario,
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
          controller: _controller.controllerLocal,
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
        Observer(builder: (_) {
          final width = MediaQuery.of(context).size.width;

          return ArenaButton(
            height: 47,
            width: width,
            title: "CADASTRAR",
            isLoading: _controller.isLoading,
            function: () async {
              await _controller.changeLoading(true);
              
              _controller.criarPartida();
              _controller.chamarSnackBar("Partida Cadastrada com Sucesso!!!", context);

              // Simulando uma operação assíncrona com o Future.delayed
              await _controller.changeLoading(false);
            },
            buttonColor: Colors.green,
            fontSize: 16,
            borderRadius: 8,
          );
        }),
        const SizedBox(height: 2,),       
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.recuperarCidades();
    _controller.recuperarTimesCasa();
    _controller.recuperarTimesFora();
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
              value: _controller.cidadeSelecionada,
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
                  _controller.cidadeSelecionada = newValue!;
                  if(_controller.listaTimesFirebaseCasa.isEmpty){
                    _controller.recuperarTimesCasa();
                    _controller.recuperarTimesFora();
                  }else{
                    _controller.listaTimesFirebaseCasa.clear();
                    _controller.recuperarTimesCasa();
                    _controller.listaTimesFirebaseFora.clear();
                    _controller.recuperarTimesFora();
                  }
                }
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
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: _controller.timeSelecionadoCasa,
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
                _controller.timeSelecionadoCasa = newValue!;
              },

              items: _controller.listaTimesFirebaseCasa.map<DropdownMenuItem<String>>((String value) {
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
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(        
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
              value: _controller.timeSelecionadoFora,
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
                _controller.timeSelecionadoFora = newValue!;
              },

              items: _controller.listaTimesFirebaseFora.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
              }).toList(),
            ),
    );
  }

}