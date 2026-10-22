import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';

/// Conquistas sugeridas, criadas pelo admin com um toque quando o catálogo
/// está vazio (depois ele edita, desativa ou cria outras).
List<AchievementDTO> suggestedAchievements() {
  var order = 0;
  AchievementDTO a(
    String title,
    String description,
    AchievementCategory category,
    String icon,
    AchievementTier tier,
    AchievementMetric metric,
    int goal,
    int points,
  ) =>
      AchievementDTO(
        title: title,
        description: description,
        category: category,
        icon: icon,
        tier: tier,
        metric: metric,
        goal: goal,
        points: points,
        order: order++,
      );

  const fan = AchievementCategory.fan;
  const voting = AchievementCategory.voting;
  const sharing = AchievementCategory.sharing;
  const news = AchievementCategory.news;
  const athlete = AchievementCategory.athlete;
  const bronze = AchievementTier.bronze;
  const silver = AchievementTier.silver;
  const gold = AchievementTier.gold;
  const legend = AchievementTier.legend;

  return [
    a('Primeiro passo', 'Escolha o seu time do coração.', fan, 'heart', bronze, AchievementMetric.favoriteTeam, 1, 10),
    a('Cara do time', 'Coloque a sua foto na carteirinha.', fan, 'camera', bronze, AchievementMetric.cardPhoto, 1, 10),
    a('Presença', 'Abra o app em 7 dias diferentes.', fan, 'calendar', bronze, AchievementMetric.activeDays, 7, 20),
    a('Frequentador', 'Abra o app em 30 dias diferentes.', fan, 'stadium', silver, AchievementMetric.activeDays, 30,
        50),
    a('Arquibancada cativa', 'Abra o app em 100 dias diferentes.', fan, 'crown', gold, AchievementMetric.activeDays,
        100, 150),
    a('Embalado', 'Abra o app 7 dias seguidos.', fan, 'fire', silver, AchievementMetric.bestStreak, 7, 40),
    a('Ininterrupto', 'Abra o app 30 dias seguidos.', fan, 'bolt', gold, AchievementMetric.bestStreak, 30, 120),
    a('Primeiro voto', 'Vote no melhor jogador de uma partida.', voting, 'vote', bronze, AchievementMetric.votes, 1,
        10),
    a('Jurado', 'Vote em 10 partidas.', voting, 'whistle', silver, AchievementMetric.votes, 10, 40),
    a('Comissão técnica', 'Vote em 50 partidas.', voting, 'medal', gold, AchievementMetric.votes, 50, 120),
    a('Voz da galera', 'Vote em 150 partidas.', voting, 'megaphone', legend, AchievementMetric.votes, 150, 300),
    a('Espalha a notícia', 'Compartilhe algo do app.', sharing, 'share', bronze, AchievementMetric.shares, 1, 10),
    a('Assessor de imprensa', 'Faça 25 compartilhamentos.', sharing, 'megaphone', silver, AchievementMetric.shares, 25,
        50),
    a('Influenciador', 'Faça 100 compartilhamentos.', sharing, 'rocket', gold, AchievementMetric.shares, 100, 150),
    a('Leitor', 'Leia 10 notícias.', news, 'news', bronze, AchievementMetric.newsRead, 10, 15),
    a('Bem informado', 'Leia 100 notícias.', news, 'eye', silver, AchievementMetric.newsRead, 100, 60),
    a('Em campo', 'Tenha a sua conta ligada a um atleta.', athlete, 'ball', silver, AchievementMetric.athlete, 1, 50),
    a('Primeiro gol', 'Marque o seu primeiro gol na temporada.', athlete, 'target', silver,
        AchievementMetric.athleteGoals, 1, 40),
    a('Artilheiro', 'Marque 10 gols na temporada.', athlete, 'trophy', gold, AchievementMetric.athleteGoals, 10, 120),
    a('Garçom', 'Dê 5 assistências na temporada.', athlete, 'handshake', silver, AchievementMetric.athleteAssists, 5,
        50),
    a('Dono da bola', 'Tenha o seu time aprovado no app.', athlete, 'shield', gold, AchievementMetric.teamOwner, 1,
        100),
  ];
}
