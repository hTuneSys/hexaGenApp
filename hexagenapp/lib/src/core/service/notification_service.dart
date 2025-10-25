// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    logger.info('Initializing notification service', category: LogCategory.app);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      await _createNotificationChannel();
      await _requestPermissions();

      _initialized = true;
      logger.info(
        'Notification service initialized',
        category: LogCategory.app,
      );
    } catch (e, stack) {
      logger.error(
        'Failed to initialize notification service',
        category: LogCategory.app,
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'hexaGen_channel',
      'hexaGen',
      description: 'Frequency generation notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      try {
        await androidPlugin.createNotificationChannel(channel);
        logger.info(
          'Android notification channel created: ${channel.id}',
          category: LogCategory.app,
        );

        final channels = await androidPlugin.getNotificationChannels();
        logger.info(
          'Available channels: ${channels?.map((c) => c.id).join(", ") ?? "none"}',
          category: LogCategory.app,
        );
      } catch (e, stack) {
        logger.error(
          'Failed to create notification channel',
          category: LogCategory.app,
          error: e,
          stackTrace: stack,
        );
      }
    } else {
      logger.warning(
        'Android plugin is null, cannot create channel',
        category: LogCategory.app,
      );
    }
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      logger.info(
        'Android notification permission: ${granted == true ? "granted" : "denied"}',
        category: LogCategory.app,
      );
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      logger.info(
        'iOS notification permission: ${granted == true ? "granted" : "denied"}',
        category: LogCategory.app,
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    logger.debug(
      'Notification tapped: ${response.payload}',
      category: LogCategory.app,
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    bool isError = false,
  }) async {
    if (!_initialized) {
      logger.warning(
        'Cannot show notification: Service not initialized',
        category: LogCategory.app,
      );
      return;
    }

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final permissionGranted =
          await androidPlugin.areNotificationsEnabled() ?? false;
      logger.info(
        'Notification permission status: $permissionGranted',
        category: LogCategory.app,
      );

      if (!permissionGranted) {
        logger.warning(
          'Cannot show notification: Permission not granted',
          category: LogCategory.app,
        );
        return;
      }

      final channels = await androidPlugin.getNotificationChannels();
      logger.info(
        'Available channels before show: ${channels?.map((c) => c.id).join(", ") ?? "none"}',
        category: LogCategory.app,
      );
    }

    logger.info(
      'Showing notification: $title - $body',
      category: LogCategory.app,
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
    logger.info('Notification ID: $notificationId', category: LogCategory.app);

    const androidDetails = AndroidNotificationDetails(
      'hexaGen_channel',
      'hexaGen',
      channelDescription: 'Frequency generation notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(notificationId, title, body, details);
      logger.info('Notification shown successfully', category: LogCategory.app);
    } catch (e, stack) {
      logger.error(
        'Failed to show notification',
        category: LogCategory.app,
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
