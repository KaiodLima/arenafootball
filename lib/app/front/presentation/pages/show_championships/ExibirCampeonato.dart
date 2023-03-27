import 'package:arena_soccer/app/front/presentation/pages/show_groups/ExibirGrupos.dart';
import 'package:arena_soccer/model/Campeonato.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExibirCampeonato extends StatefulWidget {
  String? idCampeonato; //recebe a variável enviada da outra tela
  final String? regiao;
  final String? ano;

  ExibirCampeonato(this.idCampeonato, {
    Key? key,
    this.regiao,
    this.ano
  }) : super(key: key); //construtor

  @override
  State<ExibirCampeonato> createState() => _ExibirCampeonatoState();
}

class _ExibirCampeonatoState extends State<ExibirCampeonato> {  


  Future<Campeonato> _recuperarCampeonato() async {
    var collection = FirebaseFirestore.instance.collection("campeonatos").doc("${widget.idCampeonato}"); //cria instancia

    var resultado = await collection.get(); //busca os dados uma vez

    // print("TESTE -> ${resultado.get("titulo")}");
    Campeonato campeonato = Campeonato(resultado.get("titulo"), resultado.get("descricao"), resultado.get("urlImagem"));  
    campeonato.premio1 = resultado.get("premio1");
    campeonato.premio2 = resultado.get("premio2");
    campeonato.premio3 = resultado.get("premio3");
    campeonato.premioArtilheiro = resultado.get("premioArtilheiro");
    campeonato.premioGoleiro = resultado.get("premioGoleiro");
    campeonato.regras = resultado.get("regras");
    campeonato.ano = resultado.get("ano");

    return campeonato;
  }

  //recuperar campeonato no firebase
  Campeonato? _campeonatoSelecionado;  
  _chamarStatusCampeonato() async {
    await _recuperarCampeonato().then(
      (value){
        // print("Campeonato -> "+value.titulo.toString());        
        setState(() {
          _campeonatoSelecionado = value;          
          
        });
        
        
      }
    );
    //print("Campeonato -> "+_campeonatoSelecionado!.titulo.toString());

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

    _chamarStatusCampeonato();
    
  }

  @override
  Widget build(BuildContext context) {    

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre a Competição:"),
        backgroundColor: Colors.green,        
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text("${_campeonatoSelecionado == null ? "vazio" :  _campeonatoSelecionado!.titulo}", textAlign: TextAlign.start, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            )
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${_campeonatoSelecionado == null ? "vazio" :  _campeonatoSelecionado!.descricao}", //recuperar descrição da competição             
             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),             
            ),
          ), 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("PREMIAÇÃO:\n\n1º Lugar: ${_campeonatoSelecionado == null ? "vazio" :  _campeonatoSelecionado!.premio1}\n2º Lugar: ${_campeonatoSelecionado == null ? "vazio" :  _campeonatoSelecionado!.premio2}\n3º Lugar: ${_campeonatoSelecionado == null ? "vazio" :  _campeonatoSelecionado!.premio3}\n\nArtilheiro: ${_campeonatoSelecionado == null ? "vazio" :  _campeonatoSelecionado!.premioArtilheiro}\nMelhor Goleiro: ${_campeonatoSelecionado == null ? "vazio" :  _campeonatoSelecionado!.premioGoleiro}", //recuperar descrição da competição             
             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),             
            ),
          ), 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("REGRAS:\n\n${_campeonatoSelecionado == null ? "vazio" :  _campeonatoSelecionado!.regras}", //recuperar descrição da competição             
             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
             textAlign: TextAlign.justify,             
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text("GRUPOS"),
              onPressed: (){
                //chamar tela de grupos
                Navigator.push( context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                  MaterialPageRoute(
                    builder: (context) => ExibirGrupos(regiao: widget.regiao, ano: _campeonatoSelecionado == null ? "${anoAtual}" :  _campeonatoSelecionado!.ano,), 
                  ) //o outro parâmetro é a rota
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green), //essa merda toda pra mudar a cor do botão oporra  
              ),
            ),
          ),
        ],
      ),
    );
  }
}