// import 'package:freeloot/consts.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> _firebaseMessagingBackgroundHandler(message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initMessaging() async {
  AndroidNotificationChannel channel;

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Create all necessary channels
  List<AndroidNotificationChannel> channels = [
    const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      playSound: true,
      enableLights: true,
      showBadge: true,
      enableVibration: true,
    ),
    const AndroidNotificationChannel(
      'channelId',
      'Ayah Notifications',
      importance: Importance.high,
      playSound: true,
    ),
    const AndroidNotificationChannel(
      'channelId2',
      'Zikr Notifications',
      importance: Importance.high,
      playSound: true,
    ),
    const AndroidNotificationChannel(
      'channelId3',
      'Sallah Notifications',
      importance: Importance.high,
      playSound: true,
    ),
  ];

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Create all channels
  for (var c in channels) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(c);
  }

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher')));

  // FirebaseMessaging.instance
  //     .getInitialMessage()
  //     .then((RemoteMessage? message) {});

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? android = message.notification?.android;
  //   if (notification != null && android != null) {
  //     flutterLocalNotificationsPlugin.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             channel.id,
  //             channel.name,

  //             visibility: NotificationVisibility.public,
  //             importance: Importance.max,
  //             icon: 'freeloot',
  //           ),
  //         ));
  //   }
  // });
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   print('A new onMessageOpenedApp event was published!');
  // });
  // FirebaseMessaging.instance.subscribeToTopic('all');

  // FirebaseMessaging.instance.getToken().then((token) async {
  //   Hive.box("name").put("token", token);
  // });
  //   FirebaseMessaging.instance.requestPermission();
}

checkNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
