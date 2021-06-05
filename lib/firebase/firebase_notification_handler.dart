import 'dart:io';

import 'package:fcm_notification/firebase/notification_handler.dart';
import 'package:fcm_notification/model/push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotifications {
  FirebaseMessaging _messaging;
  BuildContext myContext;

  void setupFirebase(BuildContext context) {
    _messaging = FirebaseMessaging();
    NotificationHandler.initNotification(context);
    firebaseCloudMessagingListener(context);
    myContext = context;
  }

  void firebaseCloudMessagingListener(BuildContext context) {
    _messaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true),
    );
    _messaging.onIosSettingsRegistered.listen((event) {
      print('Setting registered: ${event}');
    });

    //_Get token
    _messaging.getToken().then((value) => print('Token: ${value}'));

    //Subscribe to topic
    _messaging
        .subscribeToTopic('com.dev.fcm')
        .whenComplete(() => print('Subscribe OK'));

    Future.delayed(Duration(seconds: 1), () {
      _messaging.configure(
          onBackgroundMessage:
              Platform.isIOS ? null : fcmBackgroundMessageHandler,
          onMessage: (Map<String, dynamic> message) async {
            PushNotification notification = PushNotification.fromJson(message);
            // On message, fire when we receive message from Firebase
            if (Platform.isAndroid) {
              showNotification(notification.dataTitle, notification.dataBody,
                  notification.customData);
            } else if (Platform.isIOS) {
              showNotification(notification.title, notification.body,
                  notification.customData);
            }
          },
          onResume: (Map<String, dynamic> message) async {
            PushNotification notification = PushNotification.fromJson(message);
            // On Resume, fire when we open app from notification
            if (Platform.isIOS) {
              showDialog(
                  context: myContext,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text(notification.title),
                        content: Text(notification.body),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text('OK'),
                          ),
                        ],
                      ));
            }
          },
          onLaunch: (Map<String, dynamic> message) async {
            PushNotification notification = PushNotification.fromJson(message);
            if (Platform.isIOS) {
              showDialog(
                  context: myContext,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text(notification.title),
                        content: Text(notification.body),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text('OK'),
                          ),
                        ],
                      ));
            }
          });
    });
  }

  static Future fcmBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    dynamic data = message['data']; // Get data from notification json
    showNotification(data['title'], data['body'], data['custom_data']);
    return Future.value();
  }
}

Future<void> showNotification(title, body, customData) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'channelId',
    'channelName',
    'channelDescription',
    autoCancel: false,
    ongoing: true,
    importance: Importance.max,
    priority: Priority.high,
  );
  var iosPlatformSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iosPlatformSpecifics);
  await NotificationHandler.flutterLocalNotificationPlugin
      .show(0, title, body, platformChannelSpecifics, payload: customData);
}
