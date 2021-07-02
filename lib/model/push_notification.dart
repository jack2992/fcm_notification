import 'dart:io';

class PushNotification {
  PushNotification({
    this.title,
    this.body,
    this.dataTitle,
    this.dataBody,
    this.customData,
  });

  String title;
  String body;
  String dataTitle;
  String dataBody;
  String customData;

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: Platform.isAndroid ? json["notification"]["title"] : json["aps"]["alert"]["title"],
      body: Platform.isAndroid ? json["notification"]["body"] : json["aps"]["alert"]["body"],
      dataTitle: Platform.isAndroid ? json["data"]["title"] : json["title"],
      dataBody: Platform.isAndroid ? json["data"]["body"] : json["body"],
      customData: Platform.isAndroid ? json["data"]["custom_data"] : json["custom_data"],
    );
  }
}
