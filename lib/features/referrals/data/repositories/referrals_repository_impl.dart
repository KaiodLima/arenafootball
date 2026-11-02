import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/referrals/data/datasources/referrals_datasource.dart';
import 'package:arena_soccer/features/referrals/data/dtos/referral_dto.dart';
import 'package:arena_soccer/features/referrals/domain/repositories/referrals_repository_interface.dart';

class ReferralsRepositoryImpl implements IReferralsRepository {
  final ReferralsDataSource _dataSource;

  ReferralsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, String>> ensureCode(String uid) => _dataSource.ensureCode(uid);

  @override
  Stream<Either<Failure, ReferralDTO>> watchReferral(String uid) => _dataSource.watchReferral(uid);

  @override
  Stream<Either<Failure, List<ReferredFriendDTO>>> watchFriends(String uid) => _dataSource.watchFriends(uid);

  @override
  Future<Either<Failure, String>> getClaim(String uid) => _dataSource.getClaim(uid);

  @override
  Future<Either<Failure, void>> claim(String uid, String code) => _dataSource.claim(uid, code);

  @override
  DateTime? accountCreatedAt() => _dataSource.accountCreatedAt();

  @override
  Stream<Either<Failure, ReferralConfigDTO>> watchConfig() => _dataSource.watchConfig();

  @override
  Future<Either<Failure, void>> setEnabled(bool enabled) => _dataSource.setEnabled(enabled);
}
