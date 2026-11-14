import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Tela "Meu perfil": o que está sendo gravado, o time do coração (escudo) e
/// os avisos de uma vez só.
class ProfileState extends Equatable {
  final bool savingName;
  final bool savingPhoto;
  final TeamDTO? team;

  const ProfileState({this.savingName = false, this.savingPhoto = false, this.team});

  ProfileState copyWith({bool? savingName, bool? savingPhoto, TeamDTO? team, bool clearTeam = false}) => ProfileState(
        savingName: savingName ?? this.savingName,
        savingPhoto: savingPhoto ?? this.savingPhoto,
        team: clearTeam ? null : team ?? this.team,
      );

  @override
  List<Object?> get props => [savingName, savingPhoto, team];
}

class NameSavedProfileState extends ProfileState {
  final String name;

  NameSavedProfileState(ProfileState from, {required this.name})
      : super(savingPhoto: from.savingPhoto, team: from.team);

  @override
  List<Object?> get props => [...super.props, name];
}

class PhotoSavedProfileState extends ProfileState {
  final String photoUrl;

  PhotoSavedProfileState(ProfileState from, {required this.photoUrl})
      : super(savingName: from.savingName, team: from.team);

  @override
  List<Object?> get props => [...super.props, photoUrl];
}

class ErrorProfileState extends ProfileState {
  final String errorMessage;

  ErrorProfileState(ProfileState from, {required this.errorMessage}) : super(team: from.team);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
