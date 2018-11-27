import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ranepa_timetable/search.dart';
import 'package:xml/xml.dart' as xml;

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
