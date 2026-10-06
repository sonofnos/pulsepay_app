import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Stands in for push: show() is the same call path an FCM/APNs handler
// would use once a real push backend is wired up.
class AppNotifications {
  AppNotifications._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  static bool _permissionRequested = false;

  static Future<void> _ensurePermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;

    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> show({required String title, required String body}) async {
    await init();
    await _ensurePermission();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pulsepay_events',
        'PulsePay events',
        channelDescription: 'Wallet, trade, and bill-payment status updates',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
