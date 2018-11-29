import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/timeline_model.dart';
import 'package:ranepa_timetable/timetable_icons.dart';
import 'package:ranepa_timetable/timetable_lessons.dart';
import 'package:xml/xml.dart' as xml;

import 'timeline.dart';

class LessonItemTypes {
  final IconData _icon;

  const LessonItemTypes._internal(this._icon);

  toString() => 'Enum.$_icon';

  static const UNKNOWN =
      const LessonItemTypes._internal(Icons.insert_drive_file);
  static const ECONOMICS =
      const LessonItemTypes._internal(TimetableIcons.economics);
  static const MATH = const LessonItemTypes._internal(TimetableIcons.math);
  static const INFORMATION_THEORY =
      const LessonItemTypes._internal(TimetableIcons.informationTheory);
  static const PHILOSOPHY =
      const LessonItemTypes._internal(TimetableIcons.philosophy);
  static const SPEECH_CULTURE =
      const LessonItemTypes._internal(TimetableIcons.speechCulture);
  static const PHYSICS =
      const LessonItemTypes._internal(TimetableIcons.physics);
  static const CHEMISTRY =
      const LessonItemTypes._internal(TimetableIcons.chemistry);
  static const LITERATURE =
      const LessonItemTypes._internal(TimetableIcons.literature);
  static const ENGLISH =
      const LessonItemTypes._internal(TimetableIcons.english);
  static const INFORMATICS =
      const LessonItemTypes._internal(TimetableIcons.informatics);
  static const GEOGRAPHY =
      const LessonItemTypes._internal(TimetableIcons.geography);
  static const HISTORY =
      const LessonItemTypes._internal(TimetableIcons.history);
  static const SOCIAL_STUDIES =
      const LessonItemTypes._internal(TimetableIcons.socialStudies);
  static const BIOLOGY =
      const LessonItemTypes._internal(TimetableIcons.biology);
  static const LIFE_SAFETY =
      const LessonItemTypes._internal(TimetableIcons.lifeSafety);
  static const PHYSICAL_CULTURE =
      const LessonItemTypes._internal(TimetableIcons.physicalCulture);
  static const ETHICS = const LessonItemTypes._internal(TimetableIcons.ethics);
  static const MANAGEMENT =
      const LessonItemTypes._internal(TimetableIcons.management);
  static const SOFTWARE_DEVELOPMENT =
      const LessonItemTypes._internal(TimetableIcons.softwareDevelopment);
  static const COMPUTER_ARCHITECTURE =
      const LessonItemTypes._internal(TimetableIcons.computerArchitecture);
  static const OPERATING_SYSTEMS =
      const LessonItemTypes._internal(TimetableIcons.operatingSystems);
  static const COMPUTER_GRAPHIC =
      const LessonItemTypes._internal(TimetableIcons.computerGraphic);
  static const PROJECT_DEVELOPMENT =
      const LessonItemTypes._internal(TimetableIcons.projectDevelopment);
  static const DATABASES =
      const LessonItemTypes._internal(TimetableIcons.databases);
}

enum TimetableResponseIndexes { Date, TimeStart, TimeFinish, Name, Room, Group }

class TimetableWidget extends StatelessWidget {
  const TimetableWidget({Key key, this.item}) : super(key: key);

  final SearchItem item;

  Widget buildTimetable(List<TimelineModel> list) {
    return TimelineComponent(
      timelineList: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("started build");
    return FutureBuilder(
      future: http.post('http://test.ranhigs-nn.ru/api/WebService.asmx',
          headers: {'Content-Type': 'text/xml; charset=utf-8'}, body: '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetRaspGroup xmlns="http://tempuri.org/">
      <d1>${DateTime.now().toIso8601String()}</d1>
      <d2>${DateTime.now().add(Duration(days: 7)).toIso8601String()}</d2>
      <id>${item.id}</id>
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

            List<TimelineModel> classesList = [];

            for (var mItem in itemArr) {
              final mItemTimeStart =
                  mItem.children[TimetableResponseIndexes.TimeStart.index].text;
              final mItemTimeFinish = mItem
                  .children[TimetableResponseIndexes.TimeFinish.index].text;

              classesList.add(TimelineModel(
                  date: DateTime.parse(
                      mItem.children[TimetableResponseIndexes.Date.index].text),
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
                  classType: Lesson.fromString(
                      context, mItem.children[TimetableResponseIndexes.Name.index].text)));
            }

            return buildTimetable(classesList);
        }
        return null; // unreachable
      },
    );
  }
}
