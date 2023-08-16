import 'package:arena_soccer/app/front/presentation/components/arena_button.dart';
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
  String filter = "today"; //yesterday ou tomorrow ou today
  bool yesterdaySelected = false;
  bool todaySelected = true;
  bool tomorrowSelected = false;

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
    getpackages(filter: filter); //yesterday ou tomorrow ou today

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

  Widget callScreenMatchYesterday(list, i){
    return Column(
      children: [
        if(i<=0)
          Text(""+list[i].league.toString()),
        if(i>0 && list[i].league.toString() != list[i-1].league.toString())
          Text(""+list[i].league.toString()),
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(list[i].horario.toString()+" "+list[i].casa.toString()+" "+list[i].placar+" x "+list[i+1].placar+" "+list[i+1].casa.toString(), //yesterday
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

  Widget callScreenMatchToday(list, i){
    return Container(
      // decoration: BoxDecoration(
      //   color: (i%2 == 0) ? Colors.grey : Colors.white,
      // ),
      child: Column(
        children: [
          if(i<=0)
            Text(""+list[i].league.toString()),
          if(i>0 && list[i].league.toString() != list[i-1].league.toString())
            Text(""+list[i].league.toString()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.green,
                  child: Text(
                    ""+list[i].horario.toString(),
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 8,),
                Container(
                  color: Colors.amber,
                  child: Text(list[i].casa.toString()+" "+list[i].placar+list[i].fora.toString(), //today
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(i<=0)
            Divider(
              color: Colors.black,
              thickness: 2,
            ),
          if(i>0 && list[i].league.toString() != list[i+1].league.toString())
            Divider(
              color: Colors.black,
              thickness: 2,
            ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * 0.3;
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
      appBar: AppBar(
        title: Text("Resultados pelo mundo".toUpperCase()),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ArenaButton(height: 50, width: width, title: "Ontem", buttonColor: yesterdaySelected ? Color.fromARGB(255, 27, 67, 28) : Colors.green, borderRadius: 32, 
                function: (){
                  setState(() {
                    filter = "yesterday";
                    if(yesterdaySelected){
                      yesterdaySelected = false;
                    }else{
                      yesterdaySelected = true;
                      tomorrowSelected = false;
                      todaySelected = false;
                    }
                    getpackages(filter: filter); //yesterday ou tomorrow ou today
                  });
                }),
                SizedBox(width: 8),
                ArenaButton(height: 50, width: width, title: "Hoje", buttonColor: todaySelected ? Color.fromARGB(255, 27, 67, 28) : Colors.green, borderRadius: 32, 
                function: (){
                  setState(() {
                    filter = "today";
                    if(todaySelected){
                      todaySelected = false;
                    }else{
                      yesterdaySelected = false;
                      todaySelected = true;
                      tomorrowSelected = false;
                    }
                    getpackages(filter: filter); //yesterday ou tomorrow ou today
                  });
                }),
                SizedBox(width: 8),
                ArenaButton(height: 50, width: width, title: "Amanhã", buttonColor: tomorrowSelected ? Color.fromARGB(255, 27, 67, 28) : Colors.green, borderRadius: 32, 
                function: (){
                  setState(() {
                    filter = "tomorrow";
                    if(tomorrowSelected){
                      tomorrowSelected = false;
                    }else{
                      tomorrowSelected = true;
                      todaySelected = false;
                      yesterdaySelected = false;
                    }
                    getpackages(filter: filter); //yesterday ou tomorrow ou today
                  });
                }),
              ],
            ),
            SizedBox(height: 16),
            if(filter == "today")
              for (var i = 0; i < list.length/2; i++) //today
                callScreenMatchToday(list, i),
            if(filter == "yesterday")
              for (var i = 0; i < list.length; i++) //yesterday
                if(i%2 == 0) //yesterday
                  callScreenMatchYesterday(list, i)
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