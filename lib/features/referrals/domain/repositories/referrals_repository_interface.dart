import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/referrals/data/dtos/referral_dto.dart';

abstract class IReferralsRepository {
  Future<Either<Failure, String>> ensureCode(String uid);

  /// Código já conferido/criado desta conta no aparelho (nulo = ainda não).
  Future<Either<Failure, CachedValue<String>?>> getCachedCode(String uid);

  Future<Either<Failure, void>> saveCodeCache(String uid, String code);

  Stream<Either<Failure, ReferralDTO>> watchReferral(String uid);

  Stream<Either<Failure, List<ReferredFriendDTO>>> watchFriends(String uid);

  Future<Either<Failure, String>> getClaim(String uid);

  Future<Either<Failure, void>> claim(String uid, String code);

  DateTime? accountCreatedAt();

  Stream<Either<Failure, ReferralConfigDTO>> watchConfig();

  Future<Either<Failure, void>> setEnabled(bool enabled);
}
