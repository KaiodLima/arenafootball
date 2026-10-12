import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/create_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_next_team_number_usecase.dart';

/// Aprova o pedido: cria o time na temporada atual com o mesmo id dos
/// cadastros do admin (`{número}_{Nome}`), já com o dono, e marca o pedido.
/// Devolve o time criado.
class ApproveTeamRequestUseCase {
  final ITeamRequestsRepository _repository;
  final GetNextTeamNumberUseCase _getNextTeamNumber;

  ApproveTeamRequestUseCase(this._repository, this._getNextTeamNumber);

  Future<Either<Failure, TeamDTO>> call(TeamRequestDTO request) async {
    final number = await _getNextTeamNumber();
    if (number.isLeft) return Left(number.left);
    final name = request.name.trim();
    final team = TeamDTO(
      id: CreateTeamUseCase.buildId(number.right, name),
      name: name,
      description: request.description,
      region: request.region,
      imageUrl: request.imageUrl,
      ownerId: request.userId,
      primaryColor: request.primaryColor,
      secondaryColor: request.secondaryColor,
    );
    final response = await _repository.approve(request: request, team: team);
    return response.map((_) => team);
  }
}
