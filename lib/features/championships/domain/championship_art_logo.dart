import 'dart:io';

import 'package:equatable/equatable.dart';

/// Uma logo das artes do campeonato no formulário: a já gravada ([url]) ou a
/// escolhida agora ([file], enviada ao salvar).
class ChampionshipArtLogo extends Equatable {
  final String url;
  final File? file;

  const ChampionshipArtLogo({this.url = '', this.file});

  bool get isNew => file != null;

  @override
  List<Object?> get props => [url, file?.path];
}
