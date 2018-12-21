import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:device_calendar/device_calendar.dart';
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

enum TimetableResponseIndexes {
  Date,
  TimeStart,
  TimeFinish,
  Name,
  Room,
  Group,
}

class Timetable extends StatelessWidget {
  final Drawer drawer;
  final SharedPreferences prefs;

  static final LinkedHashMap<DateTime, List<TimelineModel>> timetable =
      LinkedHashMap<DateTime, List<TimelineModel>>();

  Timetable({Key key, @required this.drawer, @required this.prefs})
      : _deviceCalendarPlugin = DeviceCalendarPlugin(),
        super(key: key);

  static DateTime _toDateTime(TimeOfDay tod, [DateTime date]) {
    date ??= DateTime.now();
    return DateTime(date.year, date.month, date.day, tod.hour, tod.minute);
  }

  static const dayCount = 6;

  static DateTime get endCacheMidnight {
    var mDate = todayMidnight;
    for (int mDayId = 0; mDayId < dayCount - 1; mDayId++) {
      do {
        mDate = mDate.add(Duration(days: 1));
      } while (mDate.weekday == DateTime.sunday);
    }
    return mDate;
  }

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
    SearchItem searchItem,
    SharedPreferences prefs, {
    bool updateDb = true,
  }) {
    timetable.clear();
    return loadTimetable(
      context,
      Timetable.todayMidnight,
      Timetable.todayMidnight.add(Duration(days: dayCount - 1)),
      searchItem,
      prefs,
      updateDb,
    );
  }

  static Future<void> _getTimetable(
    BuildContext context,
    SearchItem searchItem,
    SharedPreferences prefs,
  ) async {
    debugPrint("started get timetable");

    final dbTimetable = await PlatformChannels.getDb();
    final today = Timetable.todayMidnight;

    if (dbTimetable == null)
      await _loadAllTimetable(context, searchItem, prefs);
    else {
      timetable.clear();
      timetable.addAll(dbTimetable);

      final endCache = DateTime.parse(prefs.getString(PrefsIds.END_CACHE));
      if (endCache.compareTo(endCacheMidnight) != 0) {
        await loadTimetable(
          context,
          endCache,
          today.add(Duration(days: dayCount - 1)),
          searchItem,
          prefs,
        );
      }
    }

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
    SearchItem searchItem,
    SharedPreferences prefs, [
    bool updateDb = true,
  ]) async {
    if (!await _checkInternetConnection()) return;

    final response = await _buildHttpRequest(searchItem, from, to);

    debugPrint("http load end. starting parse request..");

    final itemArr = xml
        .parse(response.body)
        .children[1]
        .firstChild
        .firstChild
        .firstChild
        .children;

    var mDate = from.subtract(Duration(days: 1));
    final _startDayId = timetable.keys.length;
    for (final mItem in itemArr) {
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
        }
      }

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

      timetable[mItemDate].add(mLesson);
    }

    for (var mDay in timetable.values) {
      if (mDay.isEmpty) continue;

      mDay.first.first = true;
      mDay.last.last = true;

      for (var mItemId = 0; mItemId < mDay.length - 1; mItemId++) {
        final mItem = mDay[mItemId], mNextItem = mDay[mItemId + 1];

        if (mItem.start == mNextItem.start) {
          mItem.mergeBottom = true;
          mNextItem.mergeTop = true;
        } else {
          final diff = _toDateTime(mNextItem.start)
              .difference(_toDateTime(mItem.finish));

          debugPrint("mDiff: $diff");
          if (diff.inMinutes > 10) {
            mItem.last = true;
            mNextItem.first = true;
          }
        }
      }
    }

    debugPrint("parsing http requests end..");

    // Update db
    if (updateDb)
      await PlatformChannels.updateDb(
        timetable.values
            .toList()
            .sublist(
              _startDayId,
            )
            .expand(
              (f) => f,
            ),
      );

    // Save cache end
    prefs.setString(PrefsIds.END_CACHE, to.toIso8601String());

    // Refresh widget
    PlatformChannels.refreshWidget();
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

  static DateTime get nextDayDate {
    final todayLastLesson = timetable[todayMidnight]?.last?.finish;
    if (todayLastLesson == null) return null;

    return _toDateTime(todayLastLesson).isBefore(DateTime.now())
        ? todayMidnight.add(Duration(days: 1))
        : todayMidnight;
  }

  static void _createAlarm(
    BuildContext context,
    SharedPreferences prefs,
  ) async {
    var beforeAlarmClockStr = prefs.getInt(PrefsIds.BEFORE_ALARM_CLOCK);
    if (beforeAlarmClockStr == null) {
      beforeAlarmClockStr =
          (await Prefs.showBeforeAlarmClockSelect(context, prefs)).inMinutes;
    }
    final beforeAlarmClock = Duration(minutes: beforeAlarmClockStr);

    String snackBarText;

    final alarmLessonDate = nextDayDate;
    final alarmDay = timetable[alarmLessonDate];

    if (alarmDay.isNotEmpty) {
      final alarmLesson = alarmDay.first;
      final alarmClock =
          _toDateTime(alarmLesson.start).subtract(beforeAlarmClock);

      // TODO: ios support
      if (Platform.isAndroid)
        await AndroidIntent(
          action: 'android.intent.action.SET_ALARM',
          arguments: <String, dynamic>{
            'android.intent.extra.alarm.HOUR': alarmClock.hour,
            'android.intent.extra.alarm.MINUTES': alarmClock.minute,
            'android.intent.extra.alarm.SKIP_UI': true,
            'android.intent.extra.alarm.MESSAGE': alarmLesson.lesson.title,
          },
        ).launch();

      snackBarText = AppLocalizations.of(context).alarmAddSuccess +
          TimeOfDay.fromDateTime(alarmClock).format(context);
    } else
      snackBarText = AppLocalizations.of(context).noLessonsFound;
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: new Text(snackBarText),
      ),
    );
  }

  DeviceCalendarPlugin _deviceCalendarPlugin;

  static void _createCalendarEvents(
    BuildContext context,
    DeviceCalendarPlugin calPlugin,
  ) async {
    String snackBarText;

    // Get calendar permissions if required
    var permissionsGrantedResult = await calPlugin.hasPermissions();
    var permissionsGranted = permissionsGrantedResult.data ?? false;
    if (permissionsGrantedResult.isSuccess && !permissionsGranted) {
      permissionsGrantedResult = await calPlugin.requestPermissions();
      if (permissionsGrantedResult.isSuccess && permissionsGrantedResult.data)
        permissionsGranted = true;
      else
        snackBarText = AppLocalizations.of(context).calendarEventsAddFailed;
    }

    if (permissionsGranted) {
      // Add calendar event
      final calendarArr = (await calPlugin.retrieveCalendars())?.data;
      if (calendarArr?.isNotEmpty ?? false) {
        final calendar = calendarArr.lastWhere((mCal) => !mCal.isReadOnly);

        final eventsDay = timetable[nextDayDate];

        if (eventsDay.isNotEmpty) {
          for (var mLesson in eventsDay) {
            calPlugin.createOrUpdateEvent(
              Event(
                calendar.id,
                title: mLesson.lesson.title,
                description: mLesson.lesson.fullTitle,
                start: _toDateTime(mLesson.start, mLesson.date),
                end: _toDateTime(mLesson.finish, mLesson.date),
              ),
            );
          }
          snackBarText = AppLocalizations.of(context).calendarEventsAddSuccess;
        } else
          snackBarText = AppLocalizations.of(context).noLessonsFound;
      } else
        snackBarText = AppLocalizations.of(context).calendarGetFailed;
    }

    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: new Text(snackBarText),
      ),
    );
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
        builder: (context, ssSearchItem) => Scaffold(
              drawer: drawer,
              key: scaffoldKey,
              body: StreamBuilder<void>(
                stream: timetableFutureBuilderBloc.stream,
                builder: (context, _) => WidgetTemplates.buildFutureBuilder(
                      context,
                      future: Platform.isAndroid && ssSearchItem.data.item1
                          ? _getTimetable(
                              context, ssSearchItem.data.item2, prefs)
                          : _loadAllTimetable(
                              context,
                              ssSearchItem.data.item2,
                              prefs,
                              updateDb: false,
                            ),
                      builder: (context, _) {
                        if (timetable.values.isEmpty)
                          return WidgetTemplates.buildNetworkErrorNotification(
                              context);

                        final tabViews = List<Widget>();
                        final endCache =
                            DateTime.parse(prefs.getString(PrefsIds.END_CACHE));

                        var timetableIter = timetable.entries.iterator;
                        var mDate = timetable.entries.first.key;
                        while (tabViews.length < dayCount) {
                          Widget mWidget;
                          if (mDate.compareTo(endCache) > 0)
                            mWidget = WidgetTemplates.buildNoCacheNotification(
                                context);
                          else if (timetableIter.moveNext()) {
                            if (timetableIter.current.value.isEmpty)
                              mWidget =
                                  WidgetTemplates.buildFreeDayNotification(
                                      context, ssSearchItem.data.item2);
                            else
                              mWidget = TimelineComponent(
                                  timetableIter.current.value);
                          } else
                            mWidget = WidgetTemplates.buildFreeDayNotification(
                                context, ssSearchItem.data.item2);

                          tabViews.add(mWidget);

                          mDate.add(Duration(
                              days:
                                  mDate.weekday == DateTime.saturday ? 2 : 1));
                        }
                        return TabBarView(children: tabViews);
                      },
                    ),
              ),
              appBar: AppBar(
                elevation: Platform.isAndroid ? 5 : 0,
                title: Text(
                    ssSearchItem.data.item2.typeId == SearchItemTypeId.TEACHER
                        ? TeacherModel.fromString(ssSearchItem.data.item2.title)
                            .initials()
                        : ssSearchItem.data.item2.title),
                actions: <Widget>[
                  IconButton(
                    tooltip: AppLocalizations.of(context).calendarTip,
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () =>
                        _createCalendarEvents(context, _deviceCalendarPlugin),
                  ),
                  IconButton(
                    tooltip: AppLocalizations.of(context).alarmTip,
                    icon: const Icon(Icons.alarm),
                    onPressed: () => _createAlarm(context, prefs),
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
            ),
      ),
    );
  }
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

final beforeAlarmBloc = StreamController<Duration>.broadcast();

final timetableFutureBuilderBloc = StreamController<void>.broadcast();

final timetableIdBloc = StreamController<Tuple2<bool, SearchItem>>.broadcast();
