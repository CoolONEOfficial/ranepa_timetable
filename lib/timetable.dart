import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/timeline.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class Timetable extends StatelessWidget {
  final Drawer drawer;
  final SharedPreferences prefs;

  static SearchItem selected;

  static final LinkedHashMap<DateTime, List<TimelineModel>> timetable =
      LinkedHashMap<DateTime, List<TimelineModel>>();

  Timetable({Key key, @required this.drawer, @required this.prefs})
      : _deviceCalendarPlugin = DeviceCalendarPlugin(),
        super(key: key);

  static DateTime _toDateTime(TimeOfDay tod, [DateTime dt]) {
    dt ??= DateTime.now();
    return DateTime(dt.year, dt.month, dt.day, tod.hour, tod.minute);
  }

  static TimeOfDay _toTimeOfDay([DateTime dt]) {
    dt ??= DateTime.now();
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  static T _randomElement<T>(List<T> arr) => arr[random.nextInt(arr.length)];

  static List<TimelineModel> generateRandomTimetable(
    BuildContext ctx,
    int length,
  ) =>
      List<TimelineModel>.generate(
        length,
        (index) {
          final startTime = _toTimeOfDay(
            _toDateTime(TimeOfDay(hour: 8, minute: 0))
                .add(Duration(hours: 1, minutes: 40) * index),
          );
          return TimelineModel(
              date: todayMidnight,
              start: startTime,
              finish: _toTimeOfDay(
                _toDateTime(startTime).add(Duration(hours: 1, minutes: 30)),
              ),
              group: "Иб-021",
              room: RoomModel(
                random.nextInt(999).toString(),
                _randomElement(RoomLocation.values),
              ),
              lesson: generateRandomLesson(ctx),
              teacher: TeacherModel(
                _randomElement(["Вася", "Петя", "Никита"]),
                _randomElement(["Картошкин", "Инютин", "Егоров"]),
                _randomElement(["Александрович", "Валерьевич", "Михайлович"]),
              ));
        },
      );

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
    BuildContext ctx,
    SearchItem searchItem,
    SharedPreferences prefs, {
    bool updateDb = true,
  }) {
    timetable.clear();
    return loadTimetable(
      ctx,
      Timetable.todayMidnight,
      Timetable.todayMidnight.add(Duration(days: dayCount - 1)),
      searchItem,
      prefs,
      updateDb,
    );
  }

  static Future<void> _getTimetable(
    BuildContext ctx,
    SearchItem searchItem,
    SharedPreferences prefs,
  ) async {
    debugPrint("started get timetable");

    final dbTimetable = await PlatformChannels.getDb();
    final today = Timetable.todayMidnight;

    if (dbTimetable == null)
      await _loadAllTimetable(ctx, searchItem, prefs);
    else {
      timetable.clear();
      timetable.addAll(dbTimetable);

      final endCache = DateTime.parse(prefs.getString(PrefsIds.END_CACHE));
      if (endCache.compareTo(endCacheMidnight) != 0) {
        await loadTimetable(
          ctx,
          endCache,
          today.add(Duration(days: dayCount - 1)),
          searchItem,
          prefs,
        );
      }
    }

    debugPrint("ended get timetable");
  }

  static String formatDateTime(DateTime dt) =>
      "${dt.day}.${dt.month}.${dt.year}";

  static Future<void> loadTimetable(
    BuildContext ctx,
    DateTime from,
    DateTime to,
    SearchItem searchItem,
    SharedPreferences prefs, [
    bool updateDb = true,
  ]) async {
    if (!await _checkInternetConnection()) return;

    final response = await http.get('http://services.niu.ranepa.ru/'
        'wp-content/plugins/rasp/rasp_json_data.php'
        '?user=${searchItem.title}'
        '&dstart=${formatDateTime(from)}'
        '&dfinish=${formatDateTime(to)}');

    debugPrint("http load end. starting parse request..");

    final itemArr =
        json.decode(response.body).entries.first.value.entries.first.value;

    var mDate = from.subtract(Duration(days: 1));
    final _startDayId = timetable.keys.length;
    for (var mItem in itemArr != null && itemArr is! Iterable
        ? <dynamic>[itemArr]
        : itemArr) {
      final String mItemDateStr = mItem["date"];
      final mItemDate = DateTime(
        int.parse(mItemDateStr.substring(6)),
        int.parse(mItemDateStr.substring(3, 5)),
        int.parse(mItemDateStr.substring(0, 2)),
      );
      while (mDate != mItemDate) {
        mDate = mDate.add(Duration(days: 1));
        // skip sunday
        if (mDate.weekday != DateTime.sunday) {
          timetable[mDate] = List<TimelineModel>();
        }
      }

      final mItemTimeStart = mItem["timestart"];
      final mItemTimeFinish = mItem["timefinish"];
      final String mItemName = mItem["name"];
      String bracketsInner =
          RegExp(r"\(([^)]*)\)[^(]*$").stringMatch(mItemName).substring(1);
      bracketsInner =
          bracketsInner.substring(0, bracketsInner.lastIndexOf(')'));

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
        room: RoomModel.fromString(mItem["aydit"]),
        group: mItem["namegroup"],
        lesson: LessonModel.build(
          ctx,
          mItemName.substring(0, mItemName.indexOf('(')),
          bracketsInner,
        ),
        teacher: TeacherModel.fromString(
            searchItem.typeId == SearchItemTypeId.Group
                ? mItemName.substring(mItemName.indexOf('>') + 1)
                : searchItem.title),
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
    BuildContext ctx,
    SharedPreferences prefs,
  ) async {
    var beforeAlarmClockStr = prefs.getInt(PrefsIds.BEFORE_ALARM_CLOCK);
    if (beforeAlarmClockStr == null) {
      beforeAlarmClockStr =
          (await Prefs.showBeforeAlarmClockSelect(ctx)).inMinutes;
    }
    final beforeAlarmClock = Duration(minutes: beforeAlarmClockStr);

    String snackBarText;

    final alarmLessonDate = nextDayDate;
    final alarmDay = timetable[alarmLessonDate];

    if (alarmDay.isNotEmpty) {
      final alarmLesson = alarmDay.first;
      final alarmClock =
          _toDateTime(alarmLesson.start).subtract(beforeAlarmClock);

      await AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: <String, dynamic>{
          'android.intent.extra.alarm.HOUR': alarmClock.hour,
          'android.intent.extra.alarm.MINUTES': alarmClock.minute,
          'android.intent.extra.alarm.SKIP_UI': true,
          'android.intent.extra.alarm.MESSAGE': alarmLesson.lesson.title,
        },
      ).launch();

      snackBarText = AppLocalizations.of(ctx).alarmAddSuccess +
          TimeOfDay.fromDateTime(alarmClock).format(ctx);
    } else
      snackBarText = AppLocalizations.of(ctx).noLessonsFound;
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: new Text(snackBarText),
      ),
    );
  }

  DeviceCalendarPlugin _deviceCalendarPlugin;

  static void _createCalendarEvents(
    BuildContext ctx,
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
        snackBarText = AppLocalizations.of(ctx).calendarEventsAddFailed;
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
          snackBarText = AppLocalizations.of(ctx).calendarEventsAddSuccess;
        } else
          snackBarText = AppLocalizations.of(ctx).noLessonsFound;
      } else
        snackBarText = AppLocalizations.of(ctx).calendarGetFailed;
    }

    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: new Text(snackBarText),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    // Create tabs
    final weekdayNames = [
      AppLocalizations.of(ctx).monday,
      AppLocalizations.of(ctx).tuesday,
      AppLocalizations.of(ctx).wednesday,
      AppLocalizations.of(ctx).thursday,
      AppLocalizations.of(ctx).friday,
      AppLocalizations.of(ctx).saturday
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
        initialData: Tuple2<bool, SearchItem>(
            true,
            Timetable.selected ??
                SearchItem.fromPrefs(
                    prefs, PrefsIds.PRIMARY_SEARCH_ITEM_PREFIX)),
        builder: (ctx, ssSearchItem) => Scaffold(
              drawer: drawer,
              key: scaffoldKey,
              body: StreamBuilder<void>(
                stream: timetableFutureBuilderBloc.stream,
                builder: (ctx, _) => WidgetTemplates.buildFutureBuilder(ctx,
                        future: _checkInternetConnection(),
                        builder: (ctx, internetConn) {
                      if (!internetConn.data &&
                          (!Platform.isAndroid || !ssSearchItem.data.item1))
                        return WidgetTemplates.buildNetworkErrorNotification(
                            ctx);
                      return WidgetTemplates.buildFutureBuilder(
                        ctx,
                        future: Platform.isAndroid && ssSearchItem.data.item1
                            ? _getTimetable(ctx, ssSearchItem.data.item2, prefs)
                            : _loadAllTimetable(
                                ctx,
                                ssSearchItem.data.item2,
                                prefs,
                                updateDb: false,
                              ),
                        builder: (ctx, _) {
                          if (timetable.values.isEmpty)
                            timetable.addEntries(
                              Iterable<
                                  MapEntry<DateTime,
                                      List<TimelineModel>>>.generate(
                                dayCount,
                                (dayIndex) =>
                                    MapEntry<DateTime, List<TimelineModel>>(
                                      todayMidnight.add(
                                        Duration(days: dayIndex),
                                      ),
                                      List<TimelineModel>(),
                                    ),
                              ),
                            );

                          final tabViews = List<Widget>();
                          final endCache = DateTime.parse(
                              prefs.getString(PrefsIds.END_CACHE));

                          var timetableIter = timetable.entries.iterator;
                          var mDate = timetable.entries.first.key;
                          while (tabViews.length < dayCount) {
                            Widget mWidget;
                            if (mDate.compareTo(endCache) > 0)
                              mWidget =
                                  WidgetTemplates.buildNoCacheNotification(ctx);
                            else if (timetableIter.moveNext()) {
                              if (timetableIter.current.value.isEmpty)
                                mWidget =
                                    WidgetTemplates.buildFreeDayNotification(
                                        ctx, ssSearchItem.data.item2);
                              else
                                mWidget = TimelineComponent(
                                  timetableIter.current.value,
                                );
                            } else
                              mWidget =
                                  WidgetTemplates.buildFreeDayNotification(
                                      ctx, ssSearchItem.data.item2);

                            tabViews.add(mWidget);

                            mDate.add(Duration(
                                days: mDate.weekday == DateTime.saturday
                                    ? 2
                                    : 1));
                          }
                          return TabBarView(children: tabViews);
                        },
                      );
                    }),
              ),
              appBar: AppBar(
                elevation: Platform.isAndroid ? 5 : 0,
                title: Text(
                    ssSearchItem.data.item2.typeId == SearchItemTypeId.Teacher
                        ? TeacherModel.fromString(ssSearchItem.data.item2.title)
                            .initials()
                        : ssSearchItem.data.item2.title),
                actions: (Platform.isAndroid
                    ? <Widget>[
                        IconButton(
                          tooltip: AppLocalizations.of(ctx).calendarTip,
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () =>
                              _createCalendarEvents(ctx, _deviceCalendarPlugin),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(ctx).alarmTip,
                          icon: const Icon(Icons.alarm),
                          onPressed: () => _createAlarm(ctx, prefs),
                        )
                      ]
                    : List<Widget>())
                  ..addAll(<Widget>[
                    IconButton(
                      tooltip: AppLocalizations.of(ctx).refreshTip,
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        await PlatformChannels.deleteDb();
                        timetableIdBloc.add(ssSearchItem.data);
                      },
                    ),
                    IconButton(
                      tooltip: AppLocalizations.of(ctx).searchTip,
                      icon: const Icon(Icons.search),
                      onPressed: () => showSearchItemSelect(
                            ctx,
                            primary: false,
                          ),
                    ),
                  ]),
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
