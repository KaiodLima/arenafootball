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
            //dados que vem da home do site: soccer stats
            final horario = item.children[0].text.toString();
            final casa = item.children[1].text.toString();
            final fora = item.children[3].text.toString();
            final placar = item.children[2].a?.children[0].text.toString(); //descricao: o placar está dentro de um <a>, e é o primeiro filho desse elemento.
            final jogadores = item.children[2].p?.text.toString(); //descricao: os jogadores que fizeram gol ficam dentro de um <p>
            // final gols = item.children[2].p?.children[0].text.toString();
            print("CHILD -> "+item.children.toString());

            //testes:
            // final title = item.find('div', class_: 'event__titleBox')?.text??'';
            // final title = item.find('h1', class_: 'title')?.text??''; //funciona
            // final title = item.find('div', class_: 'event__header top')?.text??'';
            // final title = item.find('tr', class_: 'child')?.text??'erro';

            PackageModel model = PackageModel(horario: horario, casa: casa, fora: fora, placar: placar ?? "x", gols: jogadores?.trim().toString() ?? "");
            packages.add(model);
          }
          break;
        case "yesterday":
          final itens = soup.findAll('td', class_: "steam"); //dados que vem do filtro yesterday do site: soccer stats
          print("TESTE ITENS-> "+itens.length.toString());
          //yesterday:
          for (var i = 0; i < itens.length; i++) {
            final casa = itens[i].text.toString();
            final gols_casa = itens[i].nextElement!.text.toString();
            // final fora = itens[i+1].text.toString();
            // final gols_fora = itens[i+1].nextElement!.text.toString();
            
            // print("TESTE ITEM::: "+itens[i].nextElement!.text.toString());

            PackageModel model = PackageModel(horario: "", casa: casa, fora: "", placar: gols_casa, gols: "");
            packages.add(model);
          }
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