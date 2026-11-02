import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/referrals/domain/referral_code.dart';
import 'package:arena_soccer/features/referrals/domain/usecases/referral_usecases.dart';
import 'package:arena_soccer/features/referrals/presentation/bloc/referral_state.dart';

class ReferralCubit extends Cubit<ReferralState> {
  final EnsureReferralCodeUseCase ensureReferralCodeUseCase;
  final WatchReferralUseCase watchReferralUseCase;
  final WatchReferredFriendsUseCase watchReferredFriendsUseCase;
  final GetReferralClaimUseCase getReferralClaimUseCase;
  final ClaimReferralUseCase claimReferralUseCase;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  String _userId = '';

  ReferralCubit(
    this.ensureReferralCodeUseCase,
    this.watchReferralUseCase,
    this.watchReferredFriendsUseCase,
    this.getReferralClaimUseCase,
    this.claimReferralUseCase,
  ) : super(const ReferralState());

  /// Carrega o código (cria na 1ª vez), o "Fui indicado" e acompanha o saldo
  /// e os indicados da conta [userId].
  Future<void> load(String userId) async {
    _userId = userId;
    _subscriptions
      ..add(watchReferralUseCase(userId).listen((response) {
        if (isClosed) return;
        response.fold(
          (failure) => emit(ErrorReferralState(state, failure.toString())),
          (referral) => emit(state.copyWith(referral: referral)),
        );
      }))
      ..add(watchReferredFriendsUseCase(userId).listen((response) {
        if (isClosed || response.isLeft) return;
        emit(state.copyWith(friends: response.right));
      }));
    final codeRequest = ensureReferralCodeUseCase(userId);
    final claim = await getReferralClaimUseCase(userId);
    final code = await codeRequest;
    if (isClosed) return;
    var next = state.copyWith(loading: false);
    if (code.isRight) next = next.copyWith(code: code.right);
    if (claim.isRight) next = next.copyWith(claimedCode: claim.right.code, newAccount: claim.right.newAccount);
    final failure = code.isLeft ? code.left : (claim.isLeft ? claim.left : null);
    emit(failure == null ? next : ErrorReferralState(next, failure.toString()));
  }

  /// "Fui indicado": confere no app e grava o código de quem indicou.
  Future<void> claim(String input) async {
    if (state.claiming || _userId.isEmpty) return;
    final code = ReferralCode.normalize(input);
    final error = claimReferralUseCase.check(uid: _userId, code: code, current: state.claimedCode);
    if (error != null) {
      emit(ClaimErrorReferralState(state, error));
      return;
    }
    emit(state.copyWith(claiming: true));
    final response = await claimReferralUseCase(_userId, code);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorReferralState(state.copyWith(claiming: false), failure.toString())),
      (_) => emit(ClaimedReferralState(state.copyWith(claiming: false, claimedCode: code))),
    );
  }

  @override
  Future<void> close() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    return super.close();
  }
}
