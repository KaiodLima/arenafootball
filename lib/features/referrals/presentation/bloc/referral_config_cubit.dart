import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/referrals/data/dtos/referral_dto.dart';
import 'package:arena_soccer/features/referrals/domain/usecases/referral_usecases.dart';

/// "Indique amigos" ligado/desligado pelo admin (`config/indicacao`).
class ReferralConfigState extends Equatable {
  final bool enabled;
  final bool saving;

  const ReferralConfigState({this.enabled = false, this.saving = false});

  ReferralConfigState copyWith({bool? enabled, bool? saving}) =>
      ReferralConfigState(enabled: enabled ?? this.enabled, saving: saving ?? this.saving);

  @override
  List<Object?> get props => [enabled, saving];
}

/// Gravação do admin terminou ([failure] nulo = salvou).
class SavedReferralConfigState extends ReferralConfigState {
  final String? failure;

  const SavedReferralConfigState({required super.enabled, this.failure});

  @override
  List<Object?> get props => [...super.props, failure];
}

/// Global: o menu, o álbum e o link de convite seguem o liga/desliga; o
/// painel do admin grava por aqui.
class ReferralConfigCubit extends Cubit<ReferralConfigState> {
  final WatchReferralConfigUseCase watchReferralConfigUseCase;
  final SetReferralEnabledUseCase setReferralEnabledUseCase;
  StreamSubscription<Either<Failure, ReferralConfigDTO>>? _subscription;

  ReferralConfigCubit(this.watchReferralConfigUseCase, this.setReferralEnabledUseCase)
      : super(const ReferralConfigState());

  void start() {
    _subscription ??= watchReferralConfigUseCase().listen((response) {
      // Erro de leitura: fica como está (desligado até ler).
      if (isClosed || response.isLeft) return;
      emit(state.copyWith(enabled: response.right.enabled));
    });
  }

  Future<void> setEnabled(bool enabled) async {
    if (state.saving) return;
    final previous = state.enabled;
    emit(state.copyWith(enabled: enabled, saving: true));
    final response = await setReferralEnabledUseCase(enabled);
    if (isClosed) return;
    emit(response.fold(
      (failure) => SavedReferralConfigState(enabled: previous, failure: failure.toString()),
      (_) => SavedReferralConfigState(enabled: enabled),
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
