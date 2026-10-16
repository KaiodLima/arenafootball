import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/domain/account_provider.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

class DeleteAccountUseCase {
  final IAuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  /// Provedor da conta logada: com senha, a tela pede a senha para confirmar.
  AccountProvider get provider => _repository.accountProvider;

  Future<Either<Failure, void>> call({String? password}) => _repository.deleteAccount(password: password);
}
