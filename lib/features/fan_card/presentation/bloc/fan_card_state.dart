import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Carteirinha de torcedor: o time do coração (escudo e cores) e o ano em
/// que a conta foi criada. Os dados do usuário vêm do `SessionCubit`.
class FanCardState extends Equatable {
  final TeamDTO? team;
  final int? memberSince;
  final bool loading;

  /// Enviando a foto nova.
  final bool savingPhoto;

  const FanCardState({this.team, this.memberSince, this.loading = true, this.savingPhoto = false});

  FanCardState copyWith({TeamDTO? team, int? memberSince, bool? loading, bool? savingPhoto}) {
    return FanCardState(
      team: team ?? this.team,
      memberSince: memberSince ?? this.memberSince,
      loading: loading ?? this.loading,
      savingPhoto: savingPhoto ?? this.savingPhoto,
    );
  }

  @override
  List<Object?> get props => [team, memberSince, loading, savingPhoto];
}

/// Foto trocada: a página atualiza a sessão e avisa.
class PhotoSavedFanCardState extends FanCardState {
  final String photoUrl;

  PhotoSavedFanCardState(FanCardState from, {required this.photoUrl})
      : super(team: from.team, memberSince: from.memberSince, loading: false);

  @override
  List<Object?> get props => [...super.props, photoUrl];
}

class ErrorFanCardState extends FanCardState {
  final String errorMessage;

  ErrorFanCardState(FanCardState from, {required this.errorMessage})
      : super(team: from.team, memberSince: from.memberSince, loading: false);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
