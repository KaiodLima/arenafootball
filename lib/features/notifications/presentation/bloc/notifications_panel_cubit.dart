import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/notifications/domain/push_action.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/send_manual_push_usecase.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/set_push_action_usecase.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/watch_push_config_usecase.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/watch_push_history_usecase.dart';
import 'package:arena_soccer/features/notifications/presentation/bloc/notifications_panel_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';

/// Painel de notificações (admin): quais ações enviam push, o histórico de
/// envios e o aviso manual.
class NotificationsPanelCubit extends Cubit<NotificationsPanelState> {
  final WatchPushConfigUseCase watchPushConfigUseCase;
  final SetPushActionUseCase setPushActionUseCase;
  final WatchPushHistoryUseCase watchPushHistoryUseCase;
  final SendManualPushUseCase sendManualPushUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  NotificationsPanelCubit(
    this.watchPushConfigUseCase,
    this.setPushActionUseCase,
    this.watchPushHistoryUseCase,
    this.sendManualPushUseCase,
    this.getRegionsUseCase,
  ) : super(const NotificationsPanelState());

  void _emit(NotificationsPanelState next) {
    if (!isClosed) emit(next);
  }

  Future<void> load() async {
    _subscriptions.add(watchPushConfigUseCase().listen((response) => response.fold(
          (failure) => _emit(ErrorNotificationsPanelState(state, failure.toString())),
          (config) => _emit(state.copyWith(config: config, configLoaded: true)),
        )));
    _subscriptions.add(watchPushHistoryUseCase().listen((response) => response.fold(
          (failure) => _emit(ErrorNotificationsPanelState(state.copyWith(historyLoaded: true), failure.toString())),
          (history) => _emit(state.copyWith(history: history, historyLoaded: true)),
        )));
    final regions = await getRegionsUseCase();
    if (regions.isRight) _emit(state.copyWith(regions: regions.right));
  }

  /// Mostra na hora; volta se a gravação falhar.
  Future<void> toggle(PushAction action, bool enabled) async {
    final before = state.config;
    _emit(state.copyWith(config: {...before, action: enabled}));
    final response = await setPushActionUseCase(action, enabled);
    if (response.isLeft) _emit(ErrorNotificationsPanelState(state.copyWith(config: before), response.left.toString()));
  }

  void changeNoticeTitle(String value) => _emit(state.copyWith(notice: state.notice.copyWith(title: value)));

  void changeNoticeBody(String value) => _emit(state.copyWith(notice: state.notice.copyWith(body: value)));

  void changeNoticeRegion(String region) => _emit(state.copyWith(notice: state.notice.copyWith(region: region)));

  /// Cria o aviso (a Cloud Function envia e registra no histórico). Depois de
  /// enviar, limpa o texto e mantém o destino.
  Future<void> sendNotice() async {
    final notice = state.notice;
    if (!notice.canSend || state.sending) return;
    _emit(state.copyWith(sending: true));
    final response = await sendManualPushUseCase(title: notice.title, body: notice.body, region: notice.region);
    if (response.isLeft) {
      _emit(ErrorNotificationsPanelState(state, response.left.toString()));
      return;
    }
    _emit(NoticeSentNotificationsPanelState(
      state.copyWith(notice: ManualNoticeForm(region: notice.region)),
    ));
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
