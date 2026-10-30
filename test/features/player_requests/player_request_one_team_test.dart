import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_state.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

void main() {
  // Paulo já está no elenco do Açaí na Copa Verde (3).
  const paulo = PlayerDTO(
    name: 'Paulo',
    team: 'Açaí',
    teamId: 'acai',
    enrollments: [PlayerEnrollment(championshipId: 3, teamId: 'acai', team: 'Açaí')],
    hasEnrollmentField: true,
  );
  const form = PlayerRequestForm(
    championships: [
      ChampionshipDTO(id: 'cv', championshipId: 3, title: 'Copa Verde'),
      ChampionshipDTO(id: 'mu', championshipId: 5, title: 'Municipal'),
    ],
    selectedTeam: 'Mulekada',
    name: 'Paulo',
    position: PlayerPosition.forward,
    accountPlayer: paulo,
  );

  test('competição em que já está no elenco de um time: bloqueia', () {
    final copaVerde = form.copyWith(championshipId: () => 3);
    expect(copaVerde.error, PlayerRequestFormError.alreadyInChampionship);
    expect(copaVerde.enrollmentInSelected?.team, 'Açaí');
  });

  test('outra competição: libera (pode jogar pela Mulekada no Municipal)', () {
    expect(form.copyWith(championshipId: () => 5).error, isNull);
  });

  test('atleta antigo (sem inscrições) e conta sem atleta não bloqueiam', () {
    const legacy = PlayerDTO(name: 'Paulo', team: 'Açaí', teamId: 'acai');
    expect(form.copyWith(championshipId: () => 3, accountPlayer: () => legacy).error, isNull);
    expect(form.copyWith(championshipId: () => 3, accountPlayer: () => null).error, isNull);
  });
}
