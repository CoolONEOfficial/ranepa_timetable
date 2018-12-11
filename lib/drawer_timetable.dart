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

  const DrawerTimetable({Key key, @required this.drawer, @required this.prefs})
      : super(key: key);

  DateTime toDateTime(TimeOfDay tod) =>
      DateTime(2018, 1, 1, tod.hour, tod.minute);

  static const tabCount = 6;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month,
        now.weekday == DateTime.sunday ? now.day + 1 : now.day); // skip sunday

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
    for (int mTabId = 0; mTabId < tabCount; mTabId++) {
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
      length: tabCount,
      child: StreamBuilder<SearchItem>(
        stream: timetableIdBloc.stream,
        initialData: SearchItem.fromPrefs(prefs),
        builder: (context, ssSearchItem) {
          final scaffoldKey = GlobalKey<ScaffoldState>();
          final getType = ssSearchItem.data.typeId == SearchItemTypeId.GROUP
              ? "Group"
              : "Prep";
          return Scaffold(
            drawer: drawer,
            key: scaffoldKey,
            body: WidgetTemplates.buildFutureBuilder(
              context,
              future: http.post('http://test.ranhigs-nn.ru/api/WebService.asmx',
                  headers: {'Content-Type': 'text/xml; charset=utf-8'},
                  body: '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetRasp$getType xmlns="http://tempuri.org/">
      <d1>${today.toIso8601String()}</d1>
      <d2>${today.add(Duration(days: tabCount - 1)).toIso8601String()}</d2>
      <id>${ssSearchItem.data.id}</id>
    </GetRasp$getType>
  </soap:Body>
</soap:Envelope>
''').then((response) => response.body),
              builder: (context, ssResp) {
                final itemArr = xml
                    .parse(ssResp.data)
                    .children[1]
                    .firstChild
                    .firstChild
                    .firstChild
                    .children;

                final List<List<TimelineModel>> tabsLessonsList = [];
                for (int mTabId = 0; mTabId < tabCount; mTabId++) {
                  tabsLessonsList.add(List<TimelineModel>());
                }

                var mDate = today;
                var mTabId = 0;
                for (var mItemId = 0; mItemId < itemArr.length; mItemId++) {
                  var mItem = itemArr[mItemId];

                  final mItemTimeStart = mItem
                      .children[TimetableResponseIndexes.TimeStart.index].text;
                  final mItemTimeFinish = mItem
                      .children[TimetableResponseIndexes.TimeFinish.index].text;
                  final mItemDate = DateTime.parse(
                      mItem.children[TimetableResponseIndexes.Date.index].text);

                  while (mItemDate != mDate) {
                    mDate = mDate.add(Duration(days: 1));
                    if (mDate.weekday != DateTime.sunday) // skips sundays
                      mTabId++;
                  }

                  tabsLessonsList[mTabId].add(
                    TimelineModel(
                        date: mItemDate,
                        start: TimeOfDay(
                            hour: int.parse(mItemTimeStart.substring(
                                0, mItemTimeStart.length - 3)),
                            minute: int.parse(mItemTimeStart.substring(
                                mItemTimeStart.length - 2,
                                mItemTimeStart.length))),
                        finish: TimeOfDay(
                            hour: int.parse(mItemTimeFinish.substring(
                                0, mItemTimeFinish.length - 3)),
                            minute: int.parse(mItemTimeFinish.substring(
                                mItemTimeFinish.length - 2,
                                mItemTimeFinish.length))),
                        room: RoomModel.fromString(mItem
                            .children[TimetableResponseIndexes.Room.index]
                            .text),
                        group: mItem
                            .children[TimetableResponseIndexes.Group.index]
                            .text,
                        lesson: LessonModel.fromString(
                            context,
                            mItem.children[TimetableResponseIndexes.Name.index]
                                .text),
                        teacher: TeacherModel.fromString(ssSearchItem
                                    .data.typeId ==
                                SearchItemTypeId.GROUP
                            ? mItem
                                .children[TimetableResponseIndexes.Name.index]
                                .text
                            : ssSearchItem.data.title),
                        user:
                            ssSearchItem.data.typeId == SearchItemTypeId.TEACHER
                                ? TimelineUser.Teacher
                                : TimelineUser.Student),
                  );
                }

                for (var mTab in tabsLessonsList) {
                  if (mTab.isEmpty) continue;

                  mTab.first.first = true;
                  mTab.last.last = true;

                  for (var mItemId = 0; mItemId < mTab.length - 1; mItemId++) {
                    final mItem = mTab[mItemId],
                        mNextItem = mTab[mItemId + 1],
                        diff = toDateTime(mTab[mItemId].finish)
                            .difference(toDateTime(mTab[mItemId + 1].start));
                    if (diff > Duration(minutes: 10)) {
                      mItem.last = true;
                      mNextItem.first = true;
                    }
                  }

                  // TODO: merging
                }

                if (tabsLessonsList.isNotEmpty)
                  PlatformChannels.updateDb(
                      tabsLessonsList.expand((f) => f).toList());

                final tabViews = List<Widget>();
                for (var mTab in tabsLessonsList) {
                  tabViews.add(TimelineComponent(timelineList: mTab));
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
