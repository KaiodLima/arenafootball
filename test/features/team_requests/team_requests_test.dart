import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/approve_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_state.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/team_request_state.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_next_team_number_usecase.dart';

class _FakeRepository implements ITeamRequestsRepository {
  TeamDTO? approvedTeam;

  @override
  Future<Either<Failure, void>> approve({required TeamRequestDTO request, required TeamDTO team}) async {
    approvedTeam = team;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNextNumber implements GetNextTeamNumberUseCase {
  @override
  Future<Either<Failure, int>> call() async => const Right(12);
}

const _request = TeamRequestDTO(
  userId: 'dono1',
  userName: 'Kaio',
  name: ' Riacho FC ',
  region: 'Floresta',
  description: 'Desde 2010',
  imageUrl: 'https://img/escudo.png',
  contact: '(89) 99999-1234',
);

void main() {
  test('aprovar cria o time com o id padrão e o dono', () async {
    final repository = _FakeRepository();
    final result = await ApproveTeamRequestUseCase(repository, _FakeNextNumber())(_request);
    final team = repository.approvedTeam!;
    expect(result.right, team);
    expect(team.id, '12_Riacho_FC');
    expect(team.name, 'Riacho FC');
    expect(team.ownerId, 'dono1');
    expect(team.toMap()['idDono'], 'dono1');
    expect(team.toStandingsMap()['pontos'], 0);
  });

  test('time sem dono não grava idDono', () {
    expect(const TeamDTO(id: '1', name: 'Volta').toMap().containsKey('idDono'), isFalse);
  });

  test('link do WhatsApp: só dígitos, com 55 quando não tem DDI', () {
    expect(_request.whatsAppUrl, 'https://wa.me/5589999991234');
    expect(_request.copyWith(contact: '+55 89 99999-1234').whatsAppUrl, 'https://wa.me/5589999991234');
    expect(_request.copyWith(contact: '').whatsAppUrl, '');
  });

  test('formulário: nome, nome repetido na região e WhatsApp', () {
    const form = TeamRequestForm(existingTeams: ['Lava Jato', 'Volta']);
    expect(form.error, TeamRequestFormError.name);
    expect(form.copyWith(name: 'lava jató').takenName, 'Lava Jato');
    expect(form.copyWith(name: 'Lava Jato').error, TeamRequestFormError.nameTaken);
    expect(form.copyWith(name: 'Riacho', contact: '1234').error, TeamRequestFormError.contact);
    expect(form.copyWith(name: 'Riacho', contact: '(89) 99999-1234').error, isNull);
  });

  test('dono só do time do pedido aprovado', () {
    const pending = OwnedTeamState(request: TeamRequestDTO(userId: 'u', name: 'Volta', region: 'Floresta'));
    expect(pending.teamName, isNull);
    expect(pending.owns('Volta'), isFalse);

    final approved = OwnedTeamState(request: pending.request!.copyWith(status: PlayerRequestStatus.approved));
    expect(approved.teamName, 'Volta');
    expect(approved.owns('Volta'), isTrue);
    expect(approved.owns('Lava Jato'), isFalse);
    expect(approved.owns(''), isFalse);
  });
}
