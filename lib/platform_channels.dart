import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ranepa_timetable/timeline_models.dart';

class PlatformChannels {
  static const methodChannel =
      const MethodChannel('ru.coolone.ranepatimetable/methodChannel');

  static void updateDb([dynamic args]) async {
    var resp;
    List<String> jsons = [];

    for (var mArg in args) jsons.add(json.encode(mArg));

    try {
      debugPrint("Channel req.. args: ${jsons.toString()}");
      resp = await methodChannel.invokeMethod("updateDb", jsons.toString());
    } on PlatformException catch (e) {
      resp = e.message;
    }

    debugPrint("Get resp: " + resp.toString());

    await PlatformChannels.getDb();
  }

  static Future<List<List<TimelineModel>>> getDb() =>
      methodChannel.invokeMethod("getDb").then((jsonStr) {
        var listLessons = List<TimelineModel>();
        for (var mLessonStr in json.decode(jsonStr)) {
          listLessons.add(TimelineModel.fromJson(mLessonStr));
        }

        var d = 5;
        return <List<TimelineModel>>[listLessons];
      });

  static void refreshWidget() {
    methodChannel.invokeMethod("refreshWidget");
  }
}
