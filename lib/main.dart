import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/timeline_model.dart';
import 'package:ranepa_timetable/timetable.dart';
import 'package:ranepa_timetable/timetable_lessons.dart';
import 'package:ranepa_timetable/timetable_teacher.dart';
import 'package:xml/xml.dart' as xml;

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class DaysOfWeek {
  static DaysOfWeek _singleton;

  factory DaysOfWeek(BuildContext context) {
    if (_singleton == null) _singleton = DaysOfWeek._internal(context);

    return _singleton;
  }

  DaysOfWeek._internal(this.context)
      : monday = AppLocalizations.of(context).monday,
        tuesday = AppLocalizations.of(context).tuesday,
        wednesday = AppLocalizations.of(context).wednesday,
        thursday = AppLocalizations.of(context).thursday,
        friday = AppLocalizations.of(context).friday,
        saturday = AppLocalizations.of(context).saturday;

  final String monday, tuesday, wednesday, thursday, friday, saturday;

  final BuildContext context;
}

class _MainWidgetState extends State<MainWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const tabCount = 6;

  Search _searchDelegate;
  SearchItem _searchSelected;

  @override
  Widget build(BuildContext context) {
    _searchDelegate = Search(context);
    if (_searchSelected == null)
      _searchSelected = _searchDelegate.predefinedSuggestions[3];

    final now = new DateTime.now();
    final today = new DateTime(now.year, now.month, now.day);
    print("Today: " + today.toIso8601String());

    final weekdayNames = [
      AppLocalizations.of(context).monday,
      AppLocalizations.of(context).tuesday,
      AppLocalizations.of(context).wednesday,
      AppLocalizations.of(context).thursday,
      AppLocalizations.of(context).friday,
      AppLocalizations.of(context).saturday
    ];

    final tabs = List<Tab>();
    var _tabCount = tabCount;
    for (int mTabId = 0; mTabId < _tabCount; mTabId++) {
      print("mTabId: " + mTabId.toString());
      final mDay = today.add(Duration(days: mTabId));
      print("mDay: " + mDay.day.toString());
      print("mWeekday: " + mDay.weekday.toString());
      if (mDay.weekday == DateTime.sunday) {
        print("Skippin sunday");
        // Skip day
        _tabCount++;
        continue;
      }
      tabs.add(Tab(
        text: weekdayNames[mDay.weekday - 1],
      ));
    }

    return FutureBuilder(
      future: http.post('http://test.ranhigs-nn.ru/api/WebService.asmx',
          headers: {'Content-Type': 'text/xml; charset=utf-8'}, body: '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetRaspGroup xmlns="http://tempuri.org/">
      <d1>${today.toIso8601String()}</d1>
      <d2>${today.add(Duration(days: tabCount - 1)).toIso8601String()}</d2>
      <id>${_searchSelected.id}</id>
    </GetRaspGroup>
  </soap:Body>
</soap:Envelope>
''').then((response) => response.body),
      builder: (context, snapshot) {
        print("started builder: " + snapshot.connectionState.toString());
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    child: CircularProgressIndicator(),
                    height: 15.0,
                    width: 15.0,
                  ),
                  RichText(
                      text: TextSpan(
                          text: "${AppLocalizations.of(context).loading}",
                          style: TextStyle(color: Colors.black)))
                ],
              ),
            );
            break;
          case ConnectionState.done:
            if (snapshot.hasError)
              return Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    new Expanded(
                      child: new FittedBox(
                        fit: BoxFit.scaleDown,
                        child: new Icon(Icons.error, size: 140),
                      ),
                    ),
                    RichText(
                        text: TextSpan(
                            text: "${snapshot.error}",
                            style: TextStyle(color: Colors.black)))
                  ],
                ),
              );

            final itemArr = xml
                .parse(snapshot.data)
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
            for (var mItem in itemArr) {
              final mItemTimeStart =
                  mItem.children[TimetableResponseIndexes.TimeStart.index].text;
              final mItemTimeFinish = mItem
                  .children[TimetableResponseIndexes.TimeFinish.index].text;
              final mItemDate = DateTime.parse(
                  mItem.children[TimetableResponseIndexes.Date.index].text);

              if (mItemDate != mDate) {
                mTabId++;
                do {
                  mDate = mDate.add(Duration(days: 1));
                } while (mItemDate != mDate); // skips sundays
              }

              tabsLessonsList[mTabId].add(TimelineModel(
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
                  room:
                      mItem.children[TimetableResponseIndexes.Room.index].text,
                  group:
                      mItem.children[TimetableResponseIndexes.Group.index].text,
                  classType: Lesson.fromString(context,
                      mItem.children[TimetableResponseIndexes.Name.index].text),
                  teacher:
                      Teacher.parse(mItem.children[TimetableResponseIndexes.Name.index].text)));
            }

            final tabViews = List<Widget>();
            for (var mTab in tabsLessonsList) {
              tabViews.add(TimetableWidget(lessons: mTab));
            }

            return DefaultTabController(
                length: tabCount,
                child: Scaffold(
                    key: _scaffoldKey,
                    body: new TabBarView(children: tabViews),
                    appBar: AppBar(
                      title: _searchSelected != null
                          ? Text(_searchSelected.title)
                          : null,
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
                          onPressed: () async {
                            final selected = await showSearch<SearchItem>(
                              context: context,
                              delegate: _searchDelegate,
                            );
                            if (selected != null &&
                                selected != _searchSelected) {
                              setState(() {
                                _searchSelected = selected;
                              });
                            }
                          },
                        ),
                      ],
                      bottom: TabBar(
                        tabs: tabs,
                      ),
                    )));
        }
        return null; // unreachable
      },
    );
  }
}

Future main() async {
  return runApp(MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('ru', 'RU'), // Русский
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).title,
      title: 'Flutter View',
      theme: ThemeData.light(),
      home: MainWidget()));
}
