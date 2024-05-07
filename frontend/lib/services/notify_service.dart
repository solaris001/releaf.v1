import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

late NotificationService notificationServiceInstance;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    // For iOS only
    final initializationSettingsIOS = DarwinInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        //! print(notificationResponse.toString());
      },
    );

    final notificationsPluginAndroidImpl =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (notificationsPluginAndroidImpl != null) {
      await notificationsPluginAndroidImpl.requestPermission();
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        importance: Importance.max,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
  }) async {
    return _notificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(),
    );
  }

  Future<void> repeatNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
  }) async {
    return _notificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute,
      _notificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    required DateTime scheduledNotificationDateTime,
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
  }) async {
    return _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduledNotificationDateTime,
        tz.local,
      ),
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleAndRepeatDailyNotification({
    required DateTime scheduledNotificationDateTime,
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    // Get the current timezone
    tz.initializeTimeZones();
    final timeZoneName = tz.local.name;

    // Get the current date and time
    final now = DateTime.now();

    // Create the scheduled date and time with the provided notification time
    var scheduledDate = tz.TZDateTime(
      tz.getLocation(timeZoneName),
      now.year,
      now.month,
      now.day,
      scheduledNotificationDateTime.hour,
      scheduledNotificationDateTime.minute,
    );

    // If the scheduled date is in the past, add a day to set it for the next day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Calculate the time difference between now and the scheduled time
    final timeDifference = scheduledDate.difference(now);

    // Schedule the initial notification
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    // Calculate the next day's scheduled date and time
    final nextDayScheduledDate = scheduledDate.add(const Duration(days: 1));

    // Schedule the repeating notification every day
    await _notificationsPlugin.zonedSchedule(
      id + 1, // Use a different ID for the repeating notification
      title,
      body,
      nextDayScheduledDate,
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      //repeat: RepeatInterval.daily,
    );
  }
}
