import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/timetable.dart';

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

  static Future<LinkedHashMap<DateTime, List<TimelineModel>>> getDb() async {
    var jsonStr = await methodChannel.invokeMethod("getDb");

    debugPrint("get db method from java: $jsonStr as ${jsonStr.runtimeType}");

    var dbTimetable = Map<DateTime, List<TimelineModel>>();
    List<TimelineModel> dbLessons = (json.decode(jsonStr) as List)
        .map((f) => TimelineModel.fromJson(f))
        .toList();
    if (dbLessons.isEmpty) return null;

    // Remove invalid lessons
    dbLessons.removeWhere(
      (mLesson) => mLesson.date.isBefore(Timetable.todayMidnight),
    );

    DateTime mLessonDate =
        Timetable.todayMidnight.subtract(Duration(days: 1));
    var mTimetableId = -1;
    for (final mLesson in dbLessons) {
      while (mLesson.date != mLessonDate) {
        mLessonDate = mLessonDate.add(Duration(days: 1));
        if (mLessonDate.weekday != DateTime.sunday) {
          // skip sunday
          dbTimetable.addAll({mLessonDate: List<TimelineModel>()});
          mTimetableId++;
        }
      }
      dbTimetable.values.elementAt(mTimetableId).add(mLesson);
    }

    return dbTimetable;
  }

  static Future<void> deleteDb() async {
    await methodChannel.invokeMethod("deleteDb");
  }

  static Future<void> refreshWidget() async {
    methodChannel.invokeMethod("refreshWidget");
  }
}
