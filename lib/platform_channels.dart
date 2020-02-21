import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ios_app_group/ios_app_group.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:sqflite/sqflite.dart';

class PlatformChannels {
  static const methodChannel =
      const MethodChannel('ru.coolone.ranepatimetable/methodChannel');

  static const tableName = 'lessons';
  static const tableFile = 'timetable.db';
  static const iosAppGroup = 'group.coolone.ranepatimetable.data';

  static Database _db;

  static get db async {
    if (_db == null) {
      String path = Platform.isIOS
          ? "${(await IosAppGroup.getAppGroupDirectory(iosAppGroup)).path}/$tableFile"
          : tableFile;

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE `$tableName`"
              "("
              "`_id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "`date` INTEGER,"
              "`group` TEXT,"
              "`first` INTEGER NOT NULL,"
              "`last` INTEGER NOT NULL,"
              "`mergeBottom` INTEGER NOT NULL,"
              "`mergeTop` INTEGER NOT NULL,"
              "`lesson_title` TEXT,"
              "`lesson_fullTitle` TEXT,"
              "`lesson_iconCodePoint` INTEGER,"
              "`lesson_action_title` TEXT,"
              "`room_number` TEXT,"
              "`room_location` INTEGER,"
              "`teacher_name` TEXT,"
              "`teacher_surname` TEXT,"
              "`teacher_patronymic` TEXT,"
              "`start_hour` INTEGER,"
              "`start_minute` INTEGER,"
              "`finish_hour` INTEGER,"
              "`finish_minute` INTEGER"
              ")");
          await db
              .execute("CREATE INDEX index_lessons__id ON $tableName (_id);");
        },
      );
    }

    return _db;
  }

  static jsonToDb(Map<String, dynamic> data) {
    Map<String, Iterable> changeMap = Map();

    for (var mKey in data.keys) {
      var mValue = data[mKey];
      debugPrint("mType: ${mValue.runtimeType}");
      if (mValue is bool) {
        data[mKey] = mValue ? 1 : 0;
      } else if (mValue is int || mValue is String) {
        // its int / str
      } else {
        Map dataMap;
        if (mValue is Map) {
          dataMap = jsonToDb(mValue);
        } else {
          dataMap = jsonToDb(mValue.toJson());
        }

        changeMap[mKey] = dataMap
            .map(
              (
                mDataKey,
                mDataVal,
              ) =>
                  MapEntry(
                "${mKey}_$mDataKey",
                mDataVal,
              ),
            )
            .entries;
      }
    }

    for (var mEntry in changeMap.entries) {
      data.remove(mEntry.key);
      data.addEntries(mEntry.value);
    }

    return data;
  }

  static dbToJson(Map<String, dynamic> data) {
    Map<String, dynamic> resultData = Map.fromEntries(data.entries);

    resultData.removeWhere((key, value) => key.contains('_'));

    var uniqueKeys = data.keys
        .where((mKey) => mKey.contains('_', 1))
        .map((mKey) => mKey.substring(0, mKey.indexOf('_')))
        .toSet();

    for (var mKey in uniqueKeys) {
      var mModel = Map.fromEntries(
        data.entries
            .where(
              (mEntry) => mEntry.key.startsWith(mKey),
            )
            .map(
              (mEntry) => MapEntry(
                mEntry.key.substring(mKey.length + 1),
                mEntry.value,
              ),
            ),
      );

      resultData[mKey] = dbToJson(mModel);
    }

    return resultData;
  }

  static Future<void> updateDb([dynamic args]) async {
    Database database = await db;

    for (var mArg in args) {
      var insertData = jsonToDb(mArg.toJson());
      database.insert(tableName, insertData);
    }
  }

  static Future<LinkedHashMap<DateTime, List<TimelineModel>>> getDb() async {
    Database database = await db;

    var res = await database.query(tableName);

    if (res.isNotEmpty) {
      List<TimelineModel> parsedData = res
          .map((Map<String, dynamic> mData) =>
              TimelineModel.fromJson(dbToJson(mData)))
          .toList();

      var uniqueDays = parsedData.map((mTimeline) => mTimeline.date).toSet();

      LinkedHashMap<DateTime, List<TimelineModel>> resultData = LinkedHashMap();

      for (var mDay in uniqueDays) {
        resultData[mDay] = parsedData
            .where(
              (mTimeline) => mTimeline.date == mDay,
            )
            .toList();
      }

      return resultData;
    } else {
      return null;
    }
  }

  static Future<void> deleteDb() async {
    return await (await db).delete(tableName);
  }

  static Future<void> refreshWidget() async {
    if (Platform.isAndroid) {
      debugPrint("Refreshing widget...");
      methodChannel.invokeMethod("refreshWidget");
    }
  }
}
