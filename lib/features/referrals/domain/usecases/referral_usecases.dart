import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/referrals/data/dtos/referral_dto.dart';
import 'package:arena_soccer/features/referrals/domain/referral_code.dart';
import 'package:arena_soccer/features/referrals/domain/repositories/referrals_repository_interface.dart';

/// Código de convite da conta (cria na 1ª vez).
class EnsureReferralCodeUseCase {
  final IReferralsRepository _repository;

  EnsureReferralCodeUseCase(this._repository);

  Future<Either<Failure, String>> call(String uid) => _repository.ensureCode(uid);
}

/// Saldo de pacotinhos extras, indicados e a situação da indicação da conta.
class WatchReferralUseCase {
  final IReferralsRepository _repository;

  WatchReferralUseCase(this._repository);

  Stream<Either<Failure, ReferralDTO>> call(String uid) => _repository.watchReferral(uid);
}

/// Amigos que entraram pelo convite (mais recentes primeiro).
class WatchReferredFriendsUseCase {
  final IReferralsRepository _repository;

  WatchReferredFriendsUseCase(this._repository);

  Stream<Either<Failure, List<ReferredFriendDTO>>> call(String uid) => _repository.watchFriends(uid);
}

/// Situação do "Fui indicado": o código já usado e se a conta ainda pode usar um.
class GetReferralClaimUseCase {
  final IReferralsRepository _repository;

  GetReferralClaimUseCase(this._repository);

  Future<Either<Failure, ({String code, bool newAccount})>> call(String uid, {DateTime? now}) async {
    final claim = await _repository.getClaim(uid);
    final newAccount = ReferralCode.isNewAccount(_repository.accountCreatedAt(), now ?? DateTime.now());
    return claim.map((code) => (code: code, newAccount: newAccount));
  }
}

/// Indicações ligadas/desligadas pelo admin (`config/indicacao`).
class WatchReferralConfigUseCase {
  final IReferralsRepository _repository;

  WatchReferralConfigUseCase(this._repository);

  Stream<Either<Failure, ReferralConfigDTO>> call() => _repository.watchConfig();
}

/// Admin liga/desliga as indicações.
class SetReferralEnabledUseCase {
  final IReferralsRepository _repository;

  SetReferralEnabledUseCase(this._repository);

  Future<Either<Failure, void>> call(bool enabled) => _repository.setEnabled(enabled);
}

/// Erro do "Fui indicado" conferido no app (as functions conferem de novo).
enum ClaimReferralError { invalid, own, oldAccount, alreadyClaimed }

/// "Fui indicado": grava o código de quem indicou a conta.
class ClaimReferralUseCase {
  final IReferralsRepository _repository;

  ClaimReferralUseCase(this._repository);

  /// Conferência local: nulo = pode gravar.
  ClaimReferralError? check({required String uid, required String code, required String current, DateTime? now}) {
    if (current.isNotEmpty) return ClaimReferralError.alreadyClaimed;
    if (!ReferralCode.isValid(code)) return ClaimReferralError.invalid;
    if (ReferralCode.isOwn(uid, code)) return ClaimReferralError.own;
    if (!ReferralCode.isNewAccount(_repository.accountCreatedAt(), now ?? DateTime.now())) {
      return ClaimReferralError.oldAccount;
    }
    return null;
  }

  Future<Either<Failure, void>> call(String uid, String code) => _repository.claim(uid, code);
}
