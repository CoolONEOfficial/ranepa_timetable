import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

enum Type { Teacher, Group, Unknown }

class _SearchItem {
  const _SearchItem(this.type, this.id, this.title);

  final Type type;
  final int id;
  final String title;

  @override
  String toString() {
    return "Search item: type - " +
        type.toString() +
        ", id - " +
        id.toString() +
        ", title - " +
        title +
        ".\n";
  }
}

class GroupSearch extends SearchDelegate<String> {
  List<_SearchItem> suggestions = [];

  final recentSuggestions = [
    _SearchItem(Type.Group, 15016, "Иб-021"),
    _SearchItem(Type.Teacher, 39, "Гришин Алехандр Юрьевич"),
  ];

  @override
  List<Widget> buildActions(BuildContext) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {

          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  void startLoad() async {
    // Send the POST request, with full SOAP envelope as the request body.
    http.Response response = await http.post(
        'http://test.ranhigs-nn.ru/api/WebService.asmx',
        headers: {'Content-Type': 'text/xml; charset=utf-8'},
        body: '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetNameUidForRasp xmlns="http://tempuri.org/">
      <str>$query</str>
    </GetNameUidForRasp>
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

    suggestions.clear();
    for (var mItem in itemArr) {
      Type mItemType;

      switch (mItem.children[0].text) {
        case "Prep":
          mItemType = Type.Teacher;
          break;
        case "Group":
          mItemType = Type.Group;
          break;
        default:
          mItemType = Type.Unknown;
      }

      suggestions.add(_SearchItem(
        mItemType,
        int.parse(mItem.children[1].text),
        mItem.children[2].text,
      ));
    }
    print(suggestions);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    startLoad();

    final finalSuggestions = query.isEmpty
        ? recentSuggestions
        : suggestions.where((p) => p.title.startsWith(query)).toList();

    return ListView.builder(
        itemBuilder: (context, index) {
          IconData iconData;
          switch (finalSuggestions[index].type) {
            case Type.Unknown:
              iconData = Icons.insert_drive_file;
              break;
            case Type.Teacher:
              iconData = Icons.person;
              break;
            case Type.Group:
              iconData = Icons.group;
              break;
          }

          return ListTile(
            leading: Icon(iconData),
            title: Text(finalSuggestions[index].title),
          );
        },
        itemCount: finalSuggestions.length);
  }
}

class TimetableWidget extends StatefulWidget {
  @override
  _TimetableWidgetState createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends State<TimetableWidget> {
  final GroupSearch _delegate = GroupSearch();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _lastStringSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () async {
                final String selected = await showSearch<String>(
                  context: context,
                  delegate: _delegate,
                );
                if (selected != null && selected != _lastStringSelected) {
                  setState(() {
                    _lastStringSelected = selected;
                  });
                }
              },
            ),
            IconButton(
              tooltip: 'More (not implemented)',
              icon: Icon(
                Theme.of(context).platform == TargetPlatform.iOS
                    ? Icons.more_horiz
                    : Icons.more_vert,
              ),
              onPressed: () {},
            ),
          ],
        ));
  }
}

Future main() async {
  return runApp(MaterialApp(
      title: 'Flutter View',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: TimetableWidget()));
}
