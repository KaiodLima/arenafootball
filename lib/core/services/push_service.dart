import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';

/// Assinatura de tópicos (o [PushService] real; um fake nos testes).
abstract class TopicClient {
  Future<void> subscribe(String topic);

  Future<void> unsubscribe(String topic);
}

/// Mantém o aparelho inscrito exatamente nos tópicos desejados: guarda os
/// assinados e, a cada mudança (região, time), assina os novos e cancela os
/// que saíram. As chamadas são enfileiradas (nunca duas ao mesmo tempo).
class PushTopicSync {
  static const String _storeKey = 'push_topics';

  final TopicClient _client;
  Future<void> _queue = Future.value();

  PushTopicSync(this._client);

  Future<void> sync(Set<String> desired) => _queue = _queue.then((_) => _sync(desired));

  Future<void> _sync(Set<String> desired) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = (prefs.getStringList(_storeKey) ?? const []).toSet();
      for (final topic in desired.difference(current)) {
        await _client.subscribe(topic);
      }
      for (final topic in current.difference(desired)) {
        await _client.unsubscribe(topic);
      }
      await prefs.setStringList(_storeKey, desired.toList()..sort());
    } catch (e) {
      // Sem rede ou sem Play Services: tenta de novo na próxima mudança.
      AppLogger.e('sync topics', name: 'PushTopicSync', error: e);
    }
  }
}

/// Notificações push (FCM): permissão, exibição com o app aberto (no Android
/// o FCM só mostra sozinho em segundo plano; no iOS o sistema mostra também em
/// primeiro plano), toque (abre a aba do `data.aba`) e tópicos. Nunca derruba
/// o app: falhas só vão para o log.
class PushService implements TopicClient {
  static const String channelId = 'arena_default';

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;
  final _tabRequests = StreamController<String>.broadcast();
  String? _pendingTab;
  int _nextId = 0;

  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  PushService(this._messaging, [FlutterLocalNotificationsPlugin? local])
      : _local = local ?? FlutterLocalNotificationsPlugin();

  /// Aba pedida por um toque em notificação com o app já aberto.
  Stream<String> get tabRequests => _tabRequests.stream;

  /// Aba da notificação que abriu o app (uma vez só).
  String? takePendingTab() {
    final tab = _pendingTab;
    _pendingTab = null;
    return tab;
  }

  Future<void> init() async {
    try {
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_arena'),
          // A permissão do iOS é pedida pelo FCM em [requestPermission].
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) => _openTab(response.payload),
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            channelId,
            'Arena Football',
            description: 'Gols, partidas, votações e avisos',
            importance: Importance.high,
          ));
      if (_isIOS) {
        await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      }
      FirebaseMessaging.onMessage.listen(_showForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((message) => _openTab(message.data['aba']?.toString()));
      final initial = await _messaging.getInitialMessage();
      _pendingTab = initial?.data['aba']?.toString();
    } catch (e) {
      AppLogger.e('init', name: 'PushService', error: e);
    }
  }

  /// Pede a permissão de notificação (iOS e Android 13+; nas versões antigas do
  /// Android já vem concedida).
  Future<void> requestPermission() async {
    try {
      await _messaging.requestPermission();
    } catch (e) {
      AppLogger.e('requestPermission', name: 'PushService', error: e);
    }
  }

  void _openTab(String? tab) {
    if (tab != null && tab.isNotEmpty) _tabRequests.add(tab);
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    // No iOS o próprio sistema mostra (setForegroundNotificationPresentationOptions).
    if (notification == null || _isIOS) return;
    try {
      await _local.show(
        id: _nextId++,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Arena Football',
            importance: Importance.high,
            priority: Priority.high,
            // Barra de status: silhueta do estádio da logo; ao lado do texto,
            // a logo colorida (ícone do app).
            icon: 'ic_stat_arena',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
        ),
        payload: message.data['aba']?.toString(),
      );
    } catch (e) {
      AppLogger.e('show', name: 'PushService', error: e);
    }
  }

  @override
  Future<void> subscribe(String topic) async {
    await _waitApnsToken();
    await _messaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribe(String topic) async {
    await _waitApnsToken();
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// No iOS o FCM só assina tópicos depois que a Apple entrega o token APNs,
  /// que chega alguns segundos após a abertura. Sem token (sem permissão ou
  /// simulador), o erro do FCM chega ao [PushTopicSync], que tenta de novo.
  Future<void> _waitApnsToken() async {
    if (!_isIOS) return;
    for (var attempt = 0; attempt < 10; attempt++) {
      if (await _messaging.getAPNSToken() != null) return;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
