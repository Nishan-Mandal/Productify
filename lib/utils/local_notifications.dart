import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: ((id, title, body, payload) =>
                null));

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static Future<String> _loadAssetAsFile(String asset) async {
    final byteData = await rootBundle.load(asset);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${asset.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  static void scheduleTask(String id, DateTime scheduleDateTime, String title,
      String body, bool isRepeat, String repeatType) async {
    final String bigPicturePath =
        await _loadAssetAsFile('assets/images/reminder.png');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath));

    var androidDetails = AndroidNotificationDetails(
      '${DateTime.now().microsecondsSinceEpoch}',
      'Notification Channel Name',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      sound: RawResourceAndroidNotificationSound('reminder'),
      playSound: true,
      enableVibration: true,
      styleInformation: bigPictureStyleInformation,
    );
    var iosDetails = DarwinNotificationDetails();
    var notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    if (isRepeat) {
      switch (repeatType) {
        case 'daily':
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            int.parse(id),
            title,
            body,
            payload: id,
            tz.TZDateTime.from(scheduleDateTime, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
          break;

        case 'weekly':
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            int.parse(id),
            title,
            body,
            payload: id,
            tz.TZDateTime.from(scheduleDateTime, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
          break;

        case 'monthly':
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            int.parse(id),
            title,
            body,
            payload: id,
            tz.TZDateTime.from(scheduleDateTime, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime,
            matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
          );
          break;

        default:
          break;
      }
    } else {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(id),
        title,
        body,
        payload: id,
        tz.TZDateTime.from(scheduleDateTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
    }
  }

  // close a specific channel notification
  static Future cancel(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(int.parse(id));
  }

  // close all the notifications available
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
