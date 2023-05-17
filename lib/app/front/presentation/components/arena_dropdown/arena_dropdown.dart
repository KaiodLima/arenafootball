import 'package:arena_soccer/app/front/presentation/components/arena_dropdown/arena_dropdown_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArenaDropdownButton extends StatefulWidget {
  final double? width;
  final double? height;
  ControllerArenaDropdownButton controller;

  ArenaDropdownButton({
    Key? key,
    required this.height,
    required this.width,
    required this.controller
  }) : super(key: key);

  @override
  State<ArenaDropdownButton> createState() => _ArenaDropdownButtonState();
}

class _ArenaDropdownButtonState extends State<ArenaDropdownButton> {
  
  @override
  void initState() {
    _recuperarCidades();
    super.initState();
  }

  //recuperar nomes das cidades no firebase
  final List<String> listaCidadesFirebase = []; //precisa estar assinalada com o final pra os valores persistirem
  _recuperarCidades() async {
    var collection = FirebaseFirestore.instance.collection("competicao"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez    

    for(var doc in resultado.docs){
      setState(() {
        listaCidadesFirebase.add(doc["nome"]); //adiciona em uma list
      });
      
    }

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: _chamarDropDownCity(),
    );
  }

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
              value: widget.controller.selectedItem??"Floresta",
              icon: const Icon(Icons.change_circle_outlined, color: Colors.white,),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              //elevation: 16,
              style: const TextStyle(color: Colors.white, fontSize: 18,),
              // underline: Container(height: 2, color: Colors.green,),
              underline: Container(),
              alignment: AlignmentDirectional.center,
              dropdownColor: Colors.green,
              onChanged: (String? newValue) async {
                setState(() {
                  widget.controller.selectedItem = newValue!;
                });

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('regiaoPadrao', widget.controller.selectedItem.toString());
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
}