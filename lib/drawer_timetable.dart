import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ranepa_timetable/drawer_prefs.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/timeline.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

enum TimetableResponseIndexes { Date, TimeStart, TimeFinish, Name, Room, Group }

class DrawerTimetable extends StatelessWidget {
  final Drawer drawer;
  final SharedPreferences prefs;

  static final List<List<TimelineModel>> timetable =
      List.generate(dayCount, (_) => List<TimelineModel>());

  const DrawerTimetable({Key key, @required this.drawer, @required this.prefs})
      : super(key: key);

  static DateTime toDateTime(TimeOfDay tod) =>
      DateTime(2018, 1, 1, tod.hour, tod.minute);

  static const dayCount = 6;

  static Future loadTimetable(
    BuildContext context,
    DateTime from,
    DateTime to,
    SearchItem searchItem,
  ) =>
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
''').then(
        (response) {
          debugPrint("http load end. starting parse request..");

          final itemArr = xml
              .parse(response.body)
              .children[1]
              .firstChild
              .firstChild
              .firstChild
              .children;

          var mDate = today;
          var mDayId = 0;
          for (var mItemId = 0; mItemId < itemArr.length; mItemId++) {
            var mItem = itemArr[mItemId];

            final mItemTimeStart =
                mItem.children[TimetableResponseIndexes.TimeStart.index].text;
            final mItemTimeFinish =
                mItem.children[TimetableResponseIndexes.TimeFinish.index].text;
            final mItemDate = DateTime.parse(
                mItem.children[TimetableResponseIndexes.Date.index].text);

            while (mItemDate != mDate) {
              if (mItemDate != mDate) mDate = mDate.add(Duration(days: 1));
              if (mDate.weekday != DateTime.sunday) // skips sundays
                mDayId++;
            }

            timetable[mDayId].add(
              TimelineModel(
                  date: mItemDate,
                  start: TimeOfDay(
                      hour: int.parse(mItemTimeStart.substring(
                          0, mItemTimeStart.length - 3)),
                      minute: int.parse(mItemTimeStart.substring(
                          mItemTimeStart.length - 2, mItemTimeStart.length))),
                  finish: TimeOfDay(
                      hour: int.parse(mItemTimeFinish.substring(
                          0, mItemTimeFinish.length - 3)),
                      minute: int.parse(mItemTimeFinish.substring(
                          mItemTimeFinish.length - 2, mItemTimeFinish.length))),
                  room: RoomModel.fromString(
                      mItem.children[TimetableResponseIndexes.Room.index].text),
                  group:
                      mItem.children[TimetableResponseIndexes.Group.index].text,
                  lesson: LessonModel.fromString(context,
                      mItem.children[TimetableResponseIndexes.Name.index].text),
                  teacher: TeacherModel.fromString(searchItem.typeId ==
                          SearchItemTypeId.GROUP
                      ? mItem.children[TimetableResponseIndexes.Name.index].text
                      : searchItem.title),
                  user: searchItem.typeId == SearchItemTypeId.TEACHER
                      ? TimelineUser.Teacher
                      : TimelineUser.Student),
            );
          }

          for (var mDay in timetable) {
            if (mDay.isEmpty) continue;

            mDay.first.first = true;
            mDay.last.last = true;

            for (var mItemId = 0; mItemId < mDay.length - 1; mItemId++) {
              final mItem = mDay[mItemId],
                  mNextItem = mDay[mItemId + 1],
                  diff = toDateTime(mDay[mItemId].finish)
                      .difference(toDateTime(mDay[mItemId + 1].start));

              if (diff > Duration(minutes: 10)) {
                mItem.last = true;
                mNextItem.first = true;
              }
            }

            // TODO: merging
          }

          debugPrint("parsing http requests end..");
        },
      );

  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month,
        now.weekday == DateTime.sunday ? now.day + 1 : now.day); // skip sunday
  }

  @override
  Widget build(BuildContext context) {
    final today = DrawerTimetable.today;

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
    var mDay = today.subtract(Duration(days: 1));
    for (int mTabId = 0; mTabId < dayCount; mTabId++) {
      debugPrint("mTabId: " + mTabId.toString());
      mDay = mDay.add(Duration(days: 1));
      debugPrint("mDay: " + mDay.day.toString());
      debugPrint("mWeekday: " + mDay.weekday.toString());
      if (mDay.weekday == DateTime.sunday) {
        debugPrint("Skippin sunday");
        // Skip day
        mTabId--;
        continue;
      }
      tabs.add(Tab(
        text: weekdayNames[mDay.weekday - 1],
      ));
    }

    return DefaultTabController(
      length: dayCount,
      child: StreamBuilder<SearchItem>(
        stream: timetableIdBloc.stream,
        initialData: SearchItem.fromPrefs(prefs),
        builder: (context, ssSearchItem) {
          final scaffoldKey = GlobalKey<ScaffoldState>();
          return Scaffold(
            drawer: drawer,
            key: scaffoldKey,
            body: WidgetTemplates.buildFutureBuilder(
              context,
              future: loadTimetable(context, today,
                  today.add(Duration(days: dayCount - 1)), ssSearchItem.data),
              builder: (context, ssResp) {
                final tabViews = List<Widget>();
                for (var mTab in timetable) {
                  tabViews.add(TimelineComponent(timelineList: mTab));
                }
                if (timetable.isNotEmpty) {
                  PlatformChannels.updateDb(timetable.expand((f) => f).toList());
                }
                return TabBarView(children: tabViews);
              },
            ),
            appBar: AppBar(
              elevation:
                  defaultTargetPlatform == TargetPlatform.android ? 5 : 0,
              title: Text(ssSearchItem.data.typeId == SearchItemTypeId.TEACHER
                  ? TeacherModel.fromString(ssSearchItem.data.title).initials()
                  : ssSearchItem.data.title),
              actions: <Widget>[
                IconButton(
                  tooltip: AppLocalizations.of(context).searchTip,
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {},
                ),
                IconButton(
                  tooltip: AppLocalizations.of(context).searchTip,
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

final timetableIdBloc = StreamController<SearchItem>.broadcast();
