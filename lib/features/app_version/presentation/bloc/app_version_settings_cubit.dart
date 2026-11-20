import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/features/app_version/domain/usecases/app_version_usecases.dart';

/// Resultado do salvar (snackbar).
enum AppVersionSaveResult { none, saved, failed }

class AppVersionSettingsState extends Equatable {
  final bool loaded;

  /// A config gravada (para saber se o mínimo subiu) e a em edição.
  final AppVersionConfig saved;
  final AppVersionConfig draft;

  /// Build instalado no aparelho do admin (referência) e o nome da versão.
  final int installed;
  final String installedName;
  final bool saving;
  final AppVersionSaveResult result;
  final String? failure;

  const AppVersionSettingsState({
    this.loaded = false,
    this.saved = const AppVersionConfig(),
    this.draft = const AppVersionConfig(),
    this.installed = 0,
    this.installedName = '',
    this.saving = false,
    this.result = AppVersionSaveResult.none,
    this.failure,
  });

  bool get dirty => draft != saved;

  /// O mínimo subiu (quem estiver abaixo fica bloqueado): pede confirmação.
  bool get raisesMinimum => draft.minAndroid > saved.minAndroid || draft.minIos > saved.minIos;

  AppVersionSettingsState copyWith({
    bool? loaded,
    AppVersionConfig? saved,
    AppVersionConfig? draft,
    int? installed,
    String? installedName,
    bool? saving,
    AppVersionSaveResult? result,
    String? failure,
  }) =>
      AppVersionSettingsState(
        loaded: loaded ?? this.loaded,
        saved: saved ?? this.saved,
        draft: draft ?? this.draft,
        installed: installed ?? this.installed,
        installedName: installedName ?? this.installedName,
        saving: saving ?? this.saving,
        result: result ?? AppVersionSaveResult.none,
        failure: failure,
      );

  @override
  List<Object?> get props => [loaded, saved, draft, installed, installedName, saving, result, failure];
}

/// Painel do admin → "Versão do app": builds mínimo e recomendado por
/// plataforma e a mensagem do aviso.
class AppVersionSettingsCubit extends Cubit<AppVersionSettingsState> {
  final GetAppVersionConfigUseCase _get;
  final SaveAppVersionConfigUseCase _save;
  final GetInstalledBuildUseCase _installed;

  AppVersionSettingsCubit(this._get, this._save, this._installed) : super(const AppVersionSettingsState());

  Future<void> load() async {
    final installed = await _installed();
    final name = await _installed.name();
    final response = await _get();
    if (isClosed) return;
    response.fold(
      (failure) =>
          emit(state.copyWith(loaded: true, installed: installed, installedName: name, failure: failure.toString())),
      (config) =>
          emit(state.copyWith(loaded: true, installed: installed, installedName: name, saved: config, draft: config)),
    );
  }

  /// Edição: mínimo nunca acima do recomendado (sobe o recomendado junto).
  void edit(AppVersionConfig Function(AppVersionConfig draft) change) {
    var next = change(state.draft);
    if (next.minAndroid > next.recommendedAndroid) next = next.copyWith(recommendedAndroid: next.minAndroid);
    if (next.minIos > next.recommendedIos) next = next.copyWith(recommendedIos: next.minIos);
    emit(state.copyWith(draft: next));
  }

  /// "Usar a versão deste aparelho": o recomendado da plataforma [ios] = build instalado.
  void useInstalledAsRecommended({required bool ios}) {
    final build = state.installed;
    if (build <= 0) return;
    edit((d) => ios ? d.copyWith(recommendedIos: build) : d.copyWith(recommendedAndroid: build));
  }

  Future<void> save() async {
    if (state.saving || !state.draft.isValid) return;
    emit(state.copyWith(saving: true));
    final draft = state.draft;
    final response = await _save(draft);
    if (isClosed) return;
    response.fold(
      (failure) =>
          emit(state.copyWith(saving: false, result: AppVersionSaveResult.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(saving: false, saved: draft, result: AppVersionSaveResult.saved)),
    );
  }
}
