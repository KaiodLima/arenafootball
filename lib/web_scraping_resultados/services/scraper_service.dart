import 'dart:developer';

import 'package:arena_soccer/web_scraping_resultados/model/package_model.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';

class ScraperService {
  
  static List<PackageModel> run({String? html, String? filter}){
    try{
      final soup = BeautifulSoup(html!);
      // final itens = soup.findAll('div', class_: 'header');
      // final itens = soup.findAll('div', class_: 'detail-header-content-block'); //funciona
      // final itens = soup.findAll('div', class_: 'sportName soccer');
      // final itens = soup.findAll('tbody');
      
      List<PackageModel> packages = [];

      switch (filter) {
        case "today":
          final itens = soup.findAll('tr', class_: 'child'); //dados que vem da home do site: soccer stats

          for(var item in itens){ //página da home
            Bs4Element? aux = item.previousSibling!;
            var chave = 0;
            var liga;
            while(chave == 0){
              if(aux != null){
                print("TESTE ITEM Atual -> "+aux.text.toString());
                // print("TESTE LIGA -> "+aux.previousSibling!.text.toString());
                if(aux.text.toString().contains('stats')){
                  if(aux.text.toString().contains(':')){
                    print("É JOGO !");
                    aux = aux.previousSibling!;
                  }else{
                    liga = aux.text.toString().split('stats').first;
                    print("TESTE LIGA -> "+liga.toString());
                    chave = 1;
                  }
                }else{
                  aux = aux.previousSibling!;
                  print("TESTE ITEM Aterior -> "+aux.text.toString());
                }
              }
            }
            //dados que vem da home do site: soccer stats
            final horario = item.children[0].text.toString();
            final casa = item.children[1].text.toString();
            final placar = item.children[2].a?.children[0].text.toString(); //descricao: o placar está dentro de um <a>, e é o primeiro filho desse elemento.
            // final fora = item.children[3].text.toString();
            final fora = item.children[3].text.toString();
            final jogadores = item.children[2].p?.text.toString(); //descricao: os jogadores que fizeram gol ficam dentro de um <p>
            // final gols = item.children[2].p?.children[0].text.toString();
            // print("CHILDREN -> "+item.children[1].toString()+" x "+item.children[3].toString());

            //testes:
            // final title = item.find('div', class_: 'event__titleBox')?.text??'';
            // final title = item.find('h1', class_: 'title')?.text??''; //funciona
            // final title = item.find('div', class_: 'event__header top')?.text??'';
            // final title = item.find('tr', class_: 'child')?.text??'erro';

            PackageModel model = PackageModel(horario: horario, casa: casa, fora: fora, placar: placar ?? "x", gols: jogadores?.trim().toString() ?? "", league: liga);
            packages.add(model);
          }
          break;
        case "yesterday":
          final blocoLeague = soup.findAll('tbody');
          final league = soup.findAll('tr', class_: "parent");
          final itens = soup.findAll('td', class_: "steam"); //dados que vem do filtro yesterday do site: soccer stats
          print("TESTE LEAGUE-> "+league.length.toString());
          print("TESTE ITENS-> "+itens.length.toString());
          print("TESTE BLOCO-> "+blocoLeague.length.toString());

          // for(var i = 0; i < league.length; i++){
          //   print("LEAGUE-> "+league[i].text.toString());
          // }
          // print("TESTE LEAGUE Only -> "+blocoLeague[10].text.toString()); //bloco completo, liga + jogos + info

          List<String?> lista = [];

          for(int cont=0; cont<league.length; cont++){
            Bs4Element? aux = league[cont];
            // print("NOME DA LIGA -> "+league[cont].text.toString()); //nome mais demais campos
            lista.add(aux.text.toString());
            
            // var stringCasa = league[cont].nextSibling!.nextSibling!.text.toString();
            // var stringFora = league[cont].nextSibling!.nextSibling!.nextSibling!.text.toString();
            // print("TESTE -> "+league[cont].text.toString());
            var element = league[cont].nextSibling;
            if(element != null && !(element.text.toString().contains('Scope'))){
              lista.add(element.text);
            }else{
              element = element!.nextSibling;
              lista.add(element?.text);
            }
            var chave = 0;
            while (chave == 0) {
              // print("ATUAL WHILE -> "+aux.text.toString()); //nome mais demais campos
              // print("Scope -> "+element.toString().contains('Scope').toString());
              // print("Status -> "+element.toString().contains('status').toString());
              if (element != null && !(element.text.toString().contains('stats'))) {
                // print('Conteúdo do elemento 1 in: ${element.text}');
                
                element = element.nextSibling;
                lista.add(element?.text);
                
                if(element != null && !(element.text.toString().contains('stats'))){
                  // print('Conteúdo do elemento 2 in: ${element.text}');
                  
                  element = element.nextSibling;
                  lista.add(element?.text);
                }else{
                  // print("SAI DENTRO");
                  chave = 1;
                }
              }else{
                // print("SAI FORA");
                chave = 1;
              }
            }

          }

          for(var i = 0; i < lista.length; i++){
            print("ITEM -> "+lista[i].toString());
          }

          print("TAMANHO LISTA -> "+lista.length.toString());

          var nomeLiga = "";
          for(int cont=0; cont<lista.length; cont++){
            if(lista[cont] != null && lista[cont].toString().isNotEmpty){
              if(lista[cont] != null && lista[cont]!.contains('stats')){
                // print("Item -> "+lista[cont].toString().split('stats').first);
                nomeLiga = lista[cont].toString().split('stats').first;
              }else {
                // print("Item -> "+lista[cont].toString());
                
                var stringCasa = "";
                var stringFora = "";
                if(lista[cont] != null && lista[cont]!.contains('analysis')){
                  stringCasa = lista[cont].toString().split('analysis').first;
                  stringFora = lista[cont+1].toString().split('analysis').first;
                }else{
                  stringCasa = lista[cont].toString();
                  stringFora = lista[cont+1].toString();
                }

                // var stringCasa = lista[cont].toString();
                // var stringFora = lista[cont+1].toString();
                var timeCasa = "";
                var timeFora = "";
                var golsTimeFora = "";
                var golsTimeCasa = "";
                if(stringCasa.isNotEmpty){
                  timeCasa = stringCasa.substring(0, stringCasa.length - 1);
                  golsTimeCasa = stringCasa[stringCasa.length - 1];
                }
                if(stringFora.isNotEmpty){
                  timeFora = stringFora.substring(0, stringFora.length - 1);
                  golsTimeFora = stringFora[stringFora.length - 1];
                }

                PackageModel model = PackageModel(
                  horario: "", 
                  casa: timeCasa,
                  fora: timeFora, 
                  placar: golsTimeCasa, 
                  gols: "", 
                  league: nomeLiga,
                );
                packages.add(model);
              }
            }
            
          }
          print("TAMANHO LISTA -> "+lista.length.toString());

          //yesterday:
          // for (var i = 0; i < itens.length; i++) {
          //   final casa = itens[i].text.toString();
          //   final gols_casa = itens[i].nextElement!.text.toString();
          //   // final fora = itens[i+1].text.toString();
          //   // final gols_fora = itens[i+1].nextElement!.text.toString();
            
          //   // print("TESTE ITEM::: "+itens[i].nextElement!.text.toString());

          //   PackageModel model = PackageModel(horario: "", casa: casa, fora: "", placar: gols_casa, gols: "");
          //   packages.add(model);
          // }
          break;
        case "tomorrow":
          final itens = soup.findAll('td', class_: "steam"); //dados que vem do filtro tomorrow do site: soccer stats
          print("TESTE ITENS-> "+itens.length.toString());
          for (var i = 0; i < itens.length; i++) {
            final casa = itens[i].text.toString();
            final hora = itens[i].nextElement!.text.toString();
            // final fora = itens[i+1].text.toString();
            // final gols_fora = itens[i+1].nextElement!.text.toString();
            
            // print("TESTE ITEM::: "+itens[i].nextElement!.text.toString());

            PackageModel model = PackageModel(horario: hora, casa: casa, fora: "", placar: "", gols: "");
            packages.add(model);
          }

          break;
        default:
      }

      return packages;
    }catch(error){
      log("ERRO! ScraperService: "+error.toString());
    }
    return [];
  }

}