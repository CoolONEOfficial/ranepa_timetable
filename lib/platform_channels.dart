import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ranepa_timetable/drawer_timetable.dart';
import 'package:ranepa_timetable/timeline_models.dart';

class PlatformChannels {
  static const methodChannel =
      const MethodChannel('ru.coolone.ranepatimetable/methodChannel');

  static Future<void> updateDb([dynamic args]) async {
    final jsons = List<String>();
    for (var mArg in args) jsons.add(json.encode(mArg));

    try {
      debugPrint("Channel req.. args: ${jsons.toString()}");
      await methodChannel.invokeMethod("updateDb", jsons.toString());
    } on PlatformException catch (e) {
      debugPrint("Update db platform exception! (${e.message})");
    }
  }

  static Future<List<List<TimelineModel>>> getDb() async {
    final jsonStr = await methodChannel.invokeMethod("getDb");

    if (jsonStr == "") return null;

    var listDays = List<List<TimelineModel>>.generate(
        DrawerTimetable.dayCount, (_) => List<TimelineModel>());
    List jsonArr = json.decode(jsonStr);
    DateTime mLessonDate = TimelineModel.fromJson(jsonArr.first).date;
    var mTimtetableId = 0;
    for (var mLessonStr in jsonArr) {
      var mLesson = TimelineModel.fromJson(mLessonStr);
      while (mLesson.date != mLessonDate) {
        mTimtetableId++;
        mLessonDate = mLessonDate.add(Duration(days: 1));
      }
      listDays[mTimtetableId].add(mLesson);
    }

    return listDays;
  }

  static void refreshWidget() {
    methodChannel.invokeMethod("refreshWidget");
  }
}
