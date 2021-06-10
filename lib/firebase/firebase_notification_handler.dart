import 'dart:io';

import 'package:fcm_notification/firebase/notification_handler.dart';
import 'package:fcm_notification/home_page.dart';
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
        .subscribeToTopic('default_notification_channel_id')
        .whenComplete(() => print('Subscribe OK'));

    Future.delayed(Duration(seconds: 1), () {
      _messaging.configure(
          onBackgroundMessage:
              Platform.isIOS ? null : fcmBackgroundMessageHandler,
          onMessage: (Map<String, dynamic> message) async {
            PushNotification notification = PushNotification.fromJson(message);
            // On message, fire when we receive message from Firebase
            print('[onMessage]  $message');
            // if (Platform.isAndroid) {
            //   showNotification(notification.dataTitle, notification.dataBody,
            //       notification.customData);
            // } else if (Platform.isIOS) {
            //   showNotification(notification.title, notification.body,
            //       notification.customData);
            // }
            showAlertDialog(context, notification);
          },
          onResume: (Map<String, dynamic> message) async {
            PushNotification notification = PushNotification.fromJson(message);
            print('[onResume]  $message');
            // On Resume, fire when we open app from notification
            showAlertDialog(context, notification);
          },
          onLaunch: (Map<String, dynamic> message) async {
            PushNotification notification = PushNotification.fromJson(message);
            print('[onLaunch]  $message');
            showAlertDialog(context, notification);
          });
    });
  }

  void showAlertDialog(BuildContext context, PushNotification notification) {
    showDialog(
        context: context,
        child:  CupertinoAlertDialog(
          title: Text(notification.dataTitle),
          content: Text(notification.dataBody),
          actions: <Widget>[
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),)
            ),
            CupertinoDialogAction(
                textStyle: TextStyle(color: Colors.blue),
                isDefaultAction: true,
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (BuildContext ctx) => HomePage(notification: notification,)));
                },
                child: Text("OK",
                  style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),)
            ),
          ],
        ));
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
