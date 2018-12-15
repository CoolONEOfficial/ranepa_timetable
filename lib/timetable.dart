import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/timeline.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart' as xml;

enum TimetableResponseIndexes { Date, TimeStart, TimeFinish, Name, Room, Group }

class Timetable extends StatelessWidget {
  final Drawer drawer;
  final SharedPreferences prefs;

  static final LinkedHashMap<DateTime, List<TimelineModel>> timetable =
      LinkedHashMap<DateTime, List<TimelineModel>>();

  const Timetable({Key key, @required this.drawer, @required this.prefs})
      : super(key: key);

  static DateTime _toDateTime(TimeOfDay tod) =>
      DateTime(2018, 1, 1, tod.hour, tod.minute);

  static const dayCount = 6;

  static Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<void> _loadAllTimetable(
    BuildContext context,
    SearchItem searchItem, [
    bool updateDb = true,
  ]) =>
      loadTimetable(
        context,
        Timetable.todayMidnight,
        Timetable.todayMidnight.add(Duration(days: dayCount - 1)),
        searchItem,
        updateDb,
      );

  static Future<void> _getTimetable(
      BuildContext context, SearchItem searchItem) async {
    debugPrint("started get timetable");

    final dbTimetable = await PlatformChannels.getDb();
    final today = Timetable.todayMidnight;

    if (dbTimetable != null) {
      timetable.clear();
      timetable.addAll(dbTimetable);

      final endCache = timetable.keys.last;
      final endCacheWeekDiff = endCache.difference(
        today.add(Duration(days: dayCount)),
      );
      if (endCacheWeekDiff.inMilliseconds != 0) {
        await loadTimetable(context, endCache,
            today.add(Duration(days: dayCount - 1)), searchItem);
      }
    } else
      await _loadAllTimetable(context, searchItem);

    debugPrint("ended get timetable");
  }

  static Future<http.Response> _buildHttpRequest(
          SearchItem searchItem, DateTime from, DateTime to) =>
      http.post('http://test.ranhigs-nn.ru/api/WebService.asmx',
          headers: {'Content-Type': 'text/xml; charset=utf-8'}, body: '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetRasp${SEARCH_ITEM_TYPES[searchItem.typeId.index].getStr} xmlns="http://tempuri.org/">
      <d1>${from.toIso8601String()}</d1>
      <d2>${to.toIso8601String()}</d2>
      <id>${searchItem.id}</id>
    </GetRasp${SEARCH_ITEM_TYPES[searchItem.typeId.index].getStr}>
  </soap:Body>
</soap:Envelope>
''');

  static Future<void> loadTimetable(
    BuildContext context,
    DateTime from,
    DateTime to,
    SearchItem searchItem, [
    bool updateDb = true,
  ]) async {
    if (!await _checkInternetConnection()) return;

    final response = await _buildHttpRequest(searchItem, from, to);

    debugPrint("http load end. starting parse request..");

    final addedLessons = List<TimelineModel>();

    final itemArr = xml
        .parse(response.body)
        .children[1]
        .firstChild
        .firstChild
        .firstChild
        .children;

    DateTime mDate = todayMidnight.subtract(Duration(days: 1));
    var mDayId = -1;
    var startDayId = -1;
    for (var mItemId = 0; mItemId < itemArr.length; mItemId++) {
      debugPrint("mItemId: $mItemId");
      var mItem = itemArr[mItemId];

      final mItemTimeStart =
          mItem.children[TimetableResponseIndexes.TimeStart.index].text;
      final mItemTimeFinish =
          mItem.children[TimetableResponseIndexes.TimeFinish.index].text;
      final mItemDate = DateTime.parse(
          mItem.children[TimetableResponseIndexes.Date.index].text);

      while (mItemDate != mDate) {
        mDate = mDate.add(Duration(days: 1));
        // skip sunday
        if (mDate.weekday != DateTime.sunday) {
          timetable[mDate] = List<TimelineModel>();

          mDayId++;
        }
      }
      if (startDayId == -1) startDayId = mDayId;

      final mLesson = TimelineModel(
        date: mItemDate,
        start: TimeOfDay(
            hour: int.parse(
                mItemTimeStart.substring(0, mItemTimeStart.length - 3)),
            minute: int.parse(mItemTimeStart.substring(
                mItemTimeStart.length - 2, mItemTimeStart.length))),
        finish: TimeOfDay(
            hour: int.parse(
                mItemTimeFinish.substring(0, mItemTimeFinish.length - 3)),
            minute: int.parse(mItemTimeFinish.substring(
                mItemTimeFinish.length - 2, mItemTimeFinish.length))),
        room: RoomModel.fromString(
            mItem.children[TimetableResponseIndexes.Room.index].text),
        group: mItem.children[TimetableResponseIndexes.Group.index].text,
        lesson: LessonModel.fromString(
            context, mItem.children[TimetableResponseIndexes.Name.index].text),
        teacher: TeacherModel.fromString(
            searchItem.typeId == SearchItemTypeId.GROUP
                ? mItem.children[TimetableResponseIndexes.Name.index].text
                : searchItem.title),
        user: searchItem.typeId == SearchItemTypeId.TEACHER
            ? TimelineUser.Teacher
            : TimelineUser.Student,
      );

      timetable.values.elementAt(mDayId).add(mLesson);
      addedLessons.add(mLesson);

      debugPrint("mDay: $mDayId");
    }

    for (var mDay in timetable.values) {
      if (mDay.isEmpty) continue;

      mDay.first.first = true;
      mDay.last.last = true;

      for (var mItemId = 0; mItemId < mDay.length - 1; mItemId++) {
        final mItem = mDay[mItemId],
            mNextItem = mDay[mItemId + 1],
            diff = _toDateTime(mDay[mItemId].finish)
                .difference(_toDateTime(mDay[mItemId + 1].start));

        debugPrint("mDiff: $diff");
        if (diff.inMinutes > 10) {
          mItem.last = true;
          mNextItem.first = true;
        }
      }

      // TODO: merging
    }

    debugPrint("parsing http requests end..");

    // Update db
    if (updateDb)
      await PlatformChannels.updateDb(
          timetable.values.toList().sublist(startDayId).expand((f) => f));
  }

  static DateTime _todayMidnight;

  static DateTime get todayMidnight {
    if (_todayMidnight == null) {
      // lazy
      var now = DateTime.now();
      _todayMidnight = DateTime(
          now.year,
          now.month,
          now.weekday == DateTime.sunday
              ? now.day + 1
              : now.day); // skip sunday
    }
    return _todayMidnight;
  }

  @override
  Widget build(BuildContext context) {
    // Create tabs
    final weekdayNames = [
      AppLocalizations.of(context).monday,
      AppLocalizations.of(context).tuesday,
      AppLocalizations.of(context).wednesday,
      AppLocalizations.of(context).thursday,
      AppLocalizations.of(context).friday,
      AppLocalizations.of(context).saturday
    ];

    final tabs = List<Tab>();
    var mDay = todayMidnight.subtract(Duration(days: 1));
    for (int mTabId = 0; mTabId < dayCount; mTabId++) {
      debugPrint("mTabId: " + mTabId.toString());
      mDay = mDay.add(Duration(days: 1));
      debugPrint("mDay: " + mDay.day.toString());
      debugPrint("mWeekday: " + mDay.weekday.toString());
      if (mDay.weekday == DateTime.sunday) {
        debugPrint("Skippin sunday");
        // Skip sunday
        mTabId--;
        continue;
      }
      tabs.add(Tab(
        text: weekdayNames[mDay.weekday - 1],
      ));
    }

    return DefaultTabController(
      length: dayCount,
      child: StreamBuilder<Tuple2<bool, SearchItem>>(
        stream: timetableIdBloc.stream,
        initialData:
            Tuple2<bool, SearchItem>(true, SearchItem.fromPrefs(prefs)),
        builder: (context, ssSearchItem) {
          final scaffoldKey = GlobalKey<ScaffoldState>(); // TODO: optimize
          return Scaffold(
            drawer: drawer,
            key: scaffoldKey,
            body: StreamBuilder<void>(
              stream: timetableFutureBuilderBloc.stream,
              builder: (context, _) => WidgetTemplates.buildFutureBuilder(
                    context,
                    future: ssSearchItem.data.item1
                        ? _getTimetable(context, ssSearchItem.data.item2)
                        : _loadAllTimetable(
                            context, ssSearchItem.data.item2, false),
                    builder: (context, _) {
                      if (timetable.values.isEmpty)
                        return WidgetTemplates.buildInternetErrorNotification(
                            context,
                            () => timetableFutureBuilderBloc.add(null));

                      final tabViews = List<Widget>();
                      for (var mTabDay in timetable.values) {
                        tabViews.add(mTabDay.isEmpty
                            ? WidgetTemplates.buildFreeDayNotification(
                                context, ssSearchItem.data.item2)
                            : TimelineComponent(timelineList: mTabDay));
                      }
                      while (tabViews.length < dayCount) {
                        tabViews.add(WidgetTemplates.buildFreeDayNotification(
                            context, ssSearchItem.data.item2));
                      }
                      return TabBarView(children: tabViews);
                    },
                  ),
            ),
            appBar: AppBar(
              elevation:
                  defaultTargetPlatform == TargetPlatform.android ? 5 : 0,
              title: Text(
                  ssSearchItem.data.item2.typeId == SearchItemTypeId.TEACHER
                      ? TeacherModel.fromString(ssSearchItem.data.item2.title)
                          .initials()
                      : ssSearchItem.data.item2.title),
              actions: <Widget>[
                IconButton(
                  tooltip: AppLocalizations.of(context).calendarTip,
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {},
                ),
                IconButton(
                  tooltip: AppLocalizations.of(context).alarmTip,
                  icon: const Icon(Icons.alarm),
                  onPressed: () {},
                ),
                IconButton(
                  tooltip: AppLocalizations.of(context).searchTip,
                  icon: const Icon(Icons.search),
                  onPressed: () => showSearchItemSelect(
                        context,
                        prefs,
                        toPrefs: false,
                      ),
                ),
              ],
              bottom: TabBar(
                tabs: tabs,
              ),
            ),
          );
        },
      ),
    );
  }
}

final timetableFutureBuilderBloc = StreamController<void>.broadcast();

final timetableIdBloc = StreamController<Tuple2<bool, SearchItem>>.broadcast();
