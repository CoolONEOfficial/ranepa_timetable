import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ranepa_timetable/drawer_timetable.dart';
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
  }

  static Future<List<List<TimelineModel>>> getDb() =>
      methodChannel.invokeMethod("getDb").then((jsonStr) {
        var listDays = List<List<TimelineModel>>.generate(
            DrawerTimetable.dayCount, (_) => List<TimelineModel>());
        var mLessonDay;
        var mTimtetableId = -1;
        for (var mLessonStr in json.decode(jsonStr)) {
          var mLesson = TimelineModel.fromJson(mLessonStr);
          if (mLesson.date.day != mLessonDay) mTimtetableId++;
          listDays[mTimtetableId].add(mLesson);
        }

        return listDays;
      });

  static void refreshWidget() {
    methodChannel.invokeMethod("refreshWidget");
  }
}
