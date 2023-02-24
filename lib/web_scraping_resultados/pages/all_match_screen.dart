import 'dart:ui';

import 'package:arena_soccer/web_scraping_resultados/model/package_model.dart';
import 'package:arena_soccer/web_scraping_resultados/services/http_service.dart';
import 'package:arena_soccer/web_scraping_resultados/services/scraper_service.dart';
import 'package:flutter/material.dart';

class AllMatchScreen extends StatefulWidget {
  const AllMatchScreen({ Key? key }) : super(key: key);

  @override
  State<AllMatchScreen> createState() => _AllMatchScreenState();
}

class _AllMatchScreenState extends State<AllMatchScreen> {

  // bool loading = false;
  List<PackageModel> list = [];
  Future<void> getpackages({String? filter}) async {
    print("ENTROU GETPACKAGE!");
    list.clear();
    // loading = true;
    final htmlPage = await HttpService.get(filter: filter);
    if(htmlPage != null){
      print("HTML NOT NULL");
      setState(() {
        list = ScraperService.run(html: htmlPage, filter: filter);
      });
      
    }
    // print("TESTE::: "+list.toString());
    // for (var item in list) {
    //   print("SUB-TESTE::: "+item.horario.toString());
    // }

  }

  @override
  void initState() {
    getpackages(filter: "yesterday");

    super.initState();
  }

  Widget callScreenEmAndamento(teste){
    return Column(
      children: [
        if(teste.horario.toString().contains("'") || teste.horario.toString().contains("FT") || teste.horario.toString().contains("HT"))
          Card(
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(""+teste.horario.toString(), style: const TextStyle(
                        fontSize: 18,
                      ),),
                      const SizedBox(width: 8,),
                      Text(""+teste.casa.toString(), style: const TextStyle(
                        fontSize: 18,
                      ),),
                      const SizedBox(width: 8,),
                      Text(""+teste.placar.toString(), style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),),
                      const SizedBox(width: 8,),
                      Text(""+teste.fora.toString(), style: const TextStyle(
                        fontSize: 18,
                      ),),
                    ],
                  ),
                  const SizedBox(width: 8,),
                  if(teste.gols.toString().isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Center(
                        child: Text(""+teste.gols.toString(), style: const TextStyle(
                          fontSize: 18,
                        ),),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget callScreenEncerrada(teste){
    return Column(
      children: [
        if(teste.horario.toString().contains(":"))
          Card(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(""+teste.horario.toString(), style: const TextStyle(
                    fontSize: 18,
                  ),),
                  const SizedBox(width: 8,),
                  Text(""+teste.casa.toString(), style: const TextStyle(
                    fontSize: 18,
                  ),),
                  const SizedBox(width: 8,),
                  Text(""+teste.placar.toString(), style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),),
                  const SizedBox(width: 8,),
                  Text(""+teste.fora.toString(), style: const TextStyle(
                    fontSize: 18,
                  ),),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget callScreenMatch(list, i){
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(list[i].horario.toString()+" "+list[i].casa.toString()+" "+list[i].placar+" x "+list[i+1].placar+" "+list[i+1].casa.toString(),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //páginal principal do site:
    // return Scaffold(
    //   body: SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         const Text("EM ANDAMENTO", style: TextStyle(
    //           fontSize: 18,
    //         ),),
    //         for(var teste in list)
    //           callScreenEmAndamento(teste),
            
    //         const Text("PARTIDAS ENCERRADAS", style: TextStyle(
    //           fontSize: 18,
    //         ),),
    //         for(var teste in list)
    //           callScreenEncerrada(teste),
              
    //       ],
    //     ),
    //   ),
    // );

    //filtro yesterday:
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("PARTIDAS ENCERRADAS", style: TextStyle(
              fontSize: 18,
            ),),
            for (var i = 0; i < list.length; i++)
              if(i%2 == 0)
                callScreenMatch(list, i)
              //else
                //callScreenMatch(list, i)
            
            // for(var teste in list)
            //   Text(""+teste.casa.toString()+" "+teste.placar),
              
          ],
        ),
      ),
    );

  }
}