import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/watch_my_partner_request_usecase.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_state.dart';

/// Global: acompanha `solicitacoes_parceiro/{uid}` da conta logada (o
/// `OwnedTeamSync` chama [follow] quando a sessão muda). As telas usam o
/// [PartnerState] para liberar ao parceiro o que ele pode publicar.
class PartnerCubit extends Cubit<PartnerState> {
  final WatchMyPartnerRequestUseCase watchMyPartnerRequestUseCase;
  StreamSubscription<Either<Failure, PartnerRequestDTO?>>? _subscription;
  String? _userId;

  PartnerCubit(this.watchMyPartnerRequestUseCase) : super(const PartnerState());

  void follow(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _subscription?.cancel();
    emit(const PartnerState());
    if (userId == null) return;
    // Falha de leitura: segue como "não é parceiro" (as regras é que protegem).
    _subscription = watchMyPartnerRequestUseCase(userId).listen((response) {
      if (response.isRight) emit(PartnerState(request: response.right));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
