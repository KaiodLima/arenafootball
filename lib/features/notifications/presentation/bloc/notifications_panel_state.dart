import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/notifications/data/dtos/push_log_dto.dart';
import 'package:arena_soccer/features/notifications/domain/push_action.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/send_manual_push_usecase.dart';

/// Formulário do aviso manual. [region] vazia = todas as regiões.
class ManualNoticeForm extends Equatable {
  final String title;
  final String body;
  final String region;

  const ManualNoticeForm({this.title = '', this.body = '', this.region = ''});

  bool get canSend {
    final t = title.trim();
    final b = body.trim();
    return t.isNotEmpty &&
        b.isNotEmpty &&
        t.length <= SendManualPushUseCase.titleMax &&
        b.length <= SendManualPushUseCase.bodyMax;
  }

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty;

  ManualNoticeForm copyWith({String? title, String? body, String? region}) => ManualNoticeForm(
        title: title ?? this.title,
        body: body ?? this.body,
        region: region ?? this.region,
      );

  @override
  List<Object?> get props => [title, body, region];
}

/// Estado do painel: liga/desliga, histórico, regiões e o aviso manual,
/// preservados em todas as transições.
class NotificationsPanelState extends Equatable {
  final Map<PushAction, bool> config;
  final bool configLoaded;
  final List<PushLogDTO> history;
  final bool historyLoaded;
  final List<String> regions;
  final ManualNoticeForm notice;
  final bool sending;

  const NotificationsPanelState({
    this.config = const {},
    this.configLoaded = false,
    this.history = const [],
    this.historyLoaded = false,
    this.regions = const [],
    this.notice = const ManualNoticeForm(),
    this.sending = false,
  });

  bool isEnabled(PushAction action) => config[action] ?? action.defaultEnabled;

  NotificationsPanelState copyWith({
    Map<PushAction, bool>? config,
    bool? configLoaded,
    List<PushLogDTO>? history,
    bool? historyLoaded,
    List<String>? regions,
    ManualNoticeForm? notice,
    bool? sending,
  }) {
    return NotificationsPanelState(
      config: config ?? this.config,
      configLoaded: configLoaded ?? this.configLoaded,
      history: history ?? this.history,
      historyLoaded: historyLoaded ?? this.historyLoaded,
      regions: regions ?? this.regions,
      notice: notice ?? this.notice,
      sending: sending ?? this.sending,
    );
  }

  @override
  List<Object?> get props => [config, configLoaded, history, historyLoaded, regions, notice, sending];
}

/// Falha de leitura ou gravação (a tela mostra no snackbar).
class ErrorNotificationsPanelState extends NotificationsPanelState {
  final String errorMessage;

  ErrorNotificationsPanelState(NotificationsPanelState base, this.errorMessage)
      : super(
          config: base.config,
          configLoaded: base.configLoaded,
          history: base.history,
          historyLoaded: base.historyLoaded,
          regions: base.regions,
          notice: base.notice,
          sending: false,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Aviso entregue para a Cloud Function enviar.
class NoticeSentNotificationsPanelState extends NotificationsPanelState {
  NoticeSentNotificationsPanelState(NotificationsPanelState base)
      : super(
          config: base.config,
          configLoaded: base.configLoaded,
          history: base.history,
          historyLoaded: base.historyLoaded,
          regions: base.regions,
          notice: base.notice,
          sending: false,
        );
}
