/// Dia consultado no soccerstats.com.
enum ResultsDay {
  yesterday('https://www.soccerstats.com/matches.asp?matchday=0&daym=yesterday'),
  today('https://www.soccerstats.com/'),
  tomorrow('https://www.soccerstats.com/matches.asp?matchday=2&daym=tomorrow');

  final String url;

  const ResultsDay(this.url);
}
