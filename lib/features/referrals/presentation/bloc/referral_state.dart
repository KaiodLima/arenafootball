import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/referrals/data/dtos/referral_dto.dart';
import 'package:arena_soccer/features/referrals/domain/usecases/referral_usecases.dart';

/// Tela "Indique amigos": o código da conta, o saldo e os indicados (ao vivo)
/// e o "Fui indicado" (código já usado e se a conta ainda pode usar um).
class ReferralState extends Equatable {
  final String code;
  final ReferralDTO referral;
  final List<ReferredFriendDTO> friends;

  /// Código de quem indicou a conta ('' = ninguém).
  final String claimedCode;

  /// Conta criada há até 7 dias (pode dizer quem a indicou).
  final bool newAccount;
  final bool loading;
  final bool claiming;

  const ReferralState({
    this.code = '',
    this.referral = const ReferralDTO(),
    this.friends = const [],
    this.claimedCode = '',
    this.newAccount = false,
    this.loading = true,
    this.claiming = false,
  });

  /// Mostra o campo "Fui indicado".
  bool get canClaim => newAccount && claimedCode.isEmpty;

  ReferralState copyWith({
    String? code,
    ReferralDTO? referral,
    List<ReferredFriendDTO>? friends,
    String? claimedCode,
    bool? newAccount,
    bool? loading,
    bool? claiming,
  }) {
    return ReferralState(
      code: code ?? this.code,
      referral: referral ?? this.referral,
      friends: friends ?? this.friends,
      claimedCode: claimedCode ?? this.claimedCode,
      newAccount: newAccount ?? this.newAccount,
      loading: loading ?? this.loading,
      claiming: claiming ?? this.claiming,
    );
  }

  @override
  List<Object?> get props => [code, referral, friends, claimedCode, newAccount, loading, claiming];
}

/// Falha de leitura/gravação (mensagem para o snackbar).
class ErrorReferralState extends ReferralState {
  final String message;

  ErrorReferralState(ReferralState from, this.message)
      : super(
          code: from.code,
          referral: from.referral,
          friends: from.friends,
          claimedCode: from.claimedCode,
          newAccount: from.newAccount,
          loading: from.loading,
          claiming: from.claiming,
        );

  @override
  List<Object?> get props => [...super.props, message];
}

/// "Fui indicado" recusado no app (código inválido, próprio, conta antiga...).
class ClaimErrorReferralState extends ReferralState {
  final ClaimReferralError error;

  ClaimErrorReferralState(ReferralState from, this.error)
      : super(
          code: from.code,
          referral: from.referral,
          friends: from.friends,
          claimedCode: from.claimedCode,
          newAccount: from.newAccount,
          loading: from.loading,
        );

  @override
  List<Object?> get props => [...super.props, error];
}

/// Código de quem indicou gravado (as functions conferem quando houver time).
class ClaimedReferralState extends ReferralState {
  ClaimedReferralState(ReferralState from)
      : super(
          code: from.code,
          referral: from.referral,
          friends: from.friends,
          claimedCode: from.claimedCode,
          newAccount: from.newAccount,
          loading: from.loading,
        );
}
