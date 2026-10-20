import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../brand/app_brand.dart';

/// FCM トークンが取れた／更新されたときに呼ばれる。保存先（Firestore など）はアプリ側が決める。
typedef FcmTokenHandler = Future<void> Function(String token);

/// タップされた通知の `data` を受け取る。画面遷移はアプリ側のルーターで行う。
typedef NotificationTapHandler = void Function(Map<String, dynamic> data);

/// FCM とローカル通知のラッパー。Firebase の初期化（`Firebase.initializeApp`）は
/// 呼び出し側で済ませておく。チャンネル ID・名前は [AppBrand] から決まる。
class NotificationService {
  NotificationService({
    required this.brand,
    this.topics = const [],
    this.onToken,
    this.onTap,
    this.androidIcon = '@mipmap/ic_launcher',
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _local = localNotifications ?? FlutterLocalNotificationsPlugin();

  final AppBrand brand;

  /// 起動時に購読する FCM トピック。
  final List<String> topics;
  final FcmTokenHandler? onToken;
  final NotificationTapHandler? onTap;
  final String androidIcon;

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// 通知の許可を求め、受信の購読を始める。
  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _local.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings(androidIcon),
        iOS: const DarwinInitializationSettings(),
      ),
    );

    await _reportToken();
    _subscriptions
      ..add(FirebaseMessaging.onMessage.listen(_showForeground))
      ..add(FirebaseMessaging.onMessageOpenedApp
          .listen((m) => onTap?.call(m.data)))
      ..add(_messaging.onTokenRefresh.listen((t) => onToken?.call(t)));

    for (final topic in topics) {
      await _messaging.subscribeToTopic(topic);
    }
  }

  Future<void> _reportToken() async {
    final handler = onToken;
    if (handler == null) return;
    try {
      final token = await _messaging.getToken();
      if (token != null) await handler(token);
    } catch (_) {
      // トークンが取れなくてもアプリは動かす。
    }
  }

  void _showForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _local.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          brand.notificationChannelId,
          brand.notificationChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// サインアウト時など: トピック購読とトークンを破棄する。
  Future<void> unsubscribeAll() async {
    for (final topic in topics) {
      await _messaging.unsubscribeFromTopic(topic);
    }
    await _messaging.deleteToken();
  }

  Future<void> dispose() async {
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
  }
}
