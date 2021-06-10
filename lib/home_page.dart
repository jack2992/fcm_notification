import 'package:fcm_notification/model/push_notification.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final PushNotification notification;
  const HomePage({Key key, this.notification}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PushNotification _notification;
  @override
  void initState() {
    // TODO: implement initState
    _notification = widget.notification;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Notification with FCM'),
      ),
      body: Container(
        child: Text(
          '[Custom data]: ${_notification.customData}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
