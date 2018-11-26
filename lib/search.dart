import 'dart:math';

import 'package:flutter/material.dart';

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

  Future<void> startLoad(BuildContext context) async {
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

  Widget _buildSuggestions() {
    final List<_SearchItem> _recentSuggestions = query.isEmpty
        ? recentSuggestions
        : recentSuggestions
            .where((p) =>
                p.title.startsWith(RegExp("^" + query, caseSensitive: false)))
            .toList();

    final List<_SearchItem> finalSuggestions = List.from(_recentSuggestions)
      ..addAll(suggestions);

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
            onTap: () {
              showResults(context);
            },
            leading: Icon(iconData),
            title: index > _recentSuggestions.length - 1
                // Not recent suggestion
                ? RichText(
                    text: TextSpan(
                        text: finalSuggestions[index].title,
                        style: TextStyle(color: Colors.grey)))
                // Recent suggestion
                : RichText(
                    // Recent suggestion
                    text: TextSpan(
                        text: finalSuggestions[index]
                            .title
                            .substring(0, query.length),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                        TextSpan(
                            text: finalSuggestions[index]
                                .title
                                .substring(query.length),
                            style: TextStyle(color: Colors.grey))
                      ])),
          );
        },
        itemCount: finalSuggestions.length);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: startLoad(context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(right: 10, top: 10),
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 20.0,
                    width: 20.0,
                  ),
                ),
                _buildSuggestions()
              ],
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
                        child: new Icon(Icons.error,
                        size: 70),
                      ),
                    ),
                    RichText(
                        text: TextSpan(
                            text: "${snapshot.error}",
                            style: TextStyle(color: Colors.black)))
                  ],
                ),
              );
            return _buildSuggestions();
        }
        return null; // unreachable
      },
    );
  }
}
