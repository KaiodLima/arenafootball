import 'dart:developer';

import 'package:http/http.dart' as http;

// const String urlBase = "https://www.flashscore.com.br/futebol/";
// const String urlBase = "https://www.livescore.in/br/";
// const String urlBase = "https://www.soccerstats.com/";
const String urlYesterday = "https://www.soccerstats.com/matches.asp?matchday=0&daym=yesterday"; //jogos do dia anterior
const String urlToday = "https://www.soccerstats.com/"; //jogos do dia atual
const String urlTomorrow = "https://www.soccerstats.com/matches.asp?matchday=2&daym=tomorrow";
// const String urlBase = "https://www.placardefutebol.com.br/campeonato-ingles";
// const String urlBase = "https://pub.dev/packages/beautiful_soup_dart/example";

class HttpService{


  static Future<String?> get({String? filter}) async {
    String urlBase = "";
    switch (filter) {
      case "today":
        urlBase = urlToday;
        break;
      case "yesterday":
        urlBase = urlYesterday;
        break;
      case "tomorrow":
        urlBase = urlTomorrow;
        break;
      default:
    }

    try{
      final response = await http.get(Uri.parse(urlBase));
      // print("TESTE RESPONSE::: "+response.body.toString());
      if(response.statusCode == 200){
        return response.body;
      }
    }catch(error){
      log("ERRO! HttpService: "+error.toString());
    }
    return null;
  }
}