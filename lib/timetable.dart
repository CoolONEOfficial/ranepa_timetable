import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/timetable_icons.dart';
import 'package:xml/xml.dart' as xml;

class ClassItemTypes {
  final IconData _icon;
  const ClassItemTypes._internal(this._icon);
  toString() => 'Enum.$_icon';

  static const UNKNOWN =
      const ClassItemTypes._internal(Icons.insert_drive_file);
  static const ECONOMICS =
      const ClassItemTypes._internal(TimetableIcons.economics);
  static const MATH = const ClassItemTypes._internal(TimetableIcons.math);
  static const INFORMATION_THEORY =
      const ClassItemTypes._internal(TimetableIcons.informationTheory);
  static const PHILOSOPHY =
      const ClassItemTypes._internal(TimetableIcons.phylosophy);
  static const SPEECH_CULTURE =
      const ClassItemTypes._internal(TimetableIcons.speechCulture);
  static const PHYSICS = const ClassItemTypes._internal(TimetableIcons.physics);
  static const CHEMISTRY =
      const ClassItemTypes._internal(TimetableIcons.chemistry);
  static const LITERATURE =
      const ClassItemTypes._internal(TimetableIcons.literature);
  static const ENGLISH = const ClassItemTypes._internal(TimetableIcons.english);
  static const INFORMATICS =
      const ClassItemTypes._internal(TimetableIcons.informatics);
  static const GEOGRAPHY =
      const ClassItemTypes._internal(TimetableIcons.geography);
  static const HISTORY = const ClassItemTypes._internal(TimetableIcons.history);
  static const SOCIAL_STUDIES =
      const ClassItemTypes._internal(TimetableIcons.socialStudies);
  static const BIOLOGY = const ClassItemTypes._internal(TimetableIcons.biology);
  static const LIFE_SAFETY =
      const ClassItemTypes._internal(TimetableIcons.lifeSafety);
  static const PHYSICAL_CULTURE =
      const ClassItemTypes._internal(TimetableIcons.physicalCulture);
  static const ETHICS = const ClassItemTypes._internal(TimetableIcons.ethics);
  static const MANAGEMENT =
      const ClassItemTypes._internal(TimetableIcons.management);
  static const SOFTWARE_DEVELOPMENT =
      const ClassItemTypes._internal(TimetableIcons.softwareDevelopment);
  static const COMPUTER_ARCHITECTURE =
      const ClassItemTypes._internal(TimetableIcons.computerArchitecture);
  static const OPERATING_SYSTEMS =
      const ClassItemTypes._internal(TimetableIcons.operatingSystems);
  static const COMPUTER_GRAPHIC =
      const ClassItemTypes._internal(TimetableIcons.computerGraphic);
  static const PROJECT_DEVELOPMENT =
      const ClassItemTypes._internal(TimetableIcons.projectDevelopment);
  static const DATABASES =
      const ClassItemTypes._internal(TimetableIcons.databases);
}

//enum Name {
//  Unknown,
//  Economics,
//  Math,
//  InformationTheory,
//  Philosophy,
//  SpeechCulture,
//  Physics,
//  literature,
//  English,
//  Informatics,
//  Geography,
//  History,
//  SocialStudies,
//  Biology,
//  LifeSafety,
//  PhysicalCulture,
//}

class ClassItem {
  const ClassItem(
      this.start, this.end, this.date, this.name, this.room, this.group);

  final DateTime date;
  final TimeOfDay start, end;
  final String name;
  final String room;
  final String group;
}

class TimetableWidget extends StatelessWidget {
  const TimetableWidget({Key key, this.item}) : super(key: key);

  final SearchItem item;

  Future<void> loadTimetable() async {
    // Send the POST request, with full SOAP envelope as the request body.
    http.Response response = await http.post(
        'http://test.ranhigs-nn.ru/api/WebService.asmx',
        headers: {'Content-Type': 'text/xml; charset=utf-8'},
        body: '''
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
''');

    final itemArr = xml
        .parse(response.body)
        .children[1]
        .firstChild
        .firstChild
        .firstChild
        .children;

    for (var mItem in itemArr) {
      print(mItem.toString());
    }
//    webSuggestions.clear();
//    webSuggestions.add(_SearchDivider("Результаты веб-поиска"));
//
//    for (var mItem in itemArr) {
//      Type mItemType;
//
//      switch (mItem.children[0].text) {
//        case "Prep":
//          mItemType = Type.Teacher;
//          break;
//        case "Group":
//          mItemType = Type.Group;
//          break;
//        default:
//          mItemType = Type.Unknown;
//      }
//
//      webSuggestions.add(_SearchItem(
//        mItemType,
//        int.parse(mItem.children[1].text),
//        mItem.children[2].text,
//      ));
//    }
//    print(webSuggestions);
  }

  @override
  Widget build(BuildContext context) {
    loadTimetable();

    return Container();
  }
}
