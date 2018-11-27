import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

enum Type { Teacher, Group, Unknown }

abstract class _SearchItemBase {
  const _SearchItemBase();
}

class _SearchItem extends _SearchItemBase {
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

class _SearchDivider extends _SearchItemBase {
  const _SearchDivider();
}

class GroupSearch extends SearchDelegate<String> {
  SharedPreferences d;

  List<_SearchItem> suggestions = [];

  final groupSuggestions = [
    _SearchItem(Type.Group, 15034, "Иб-011"),
    _SearchItem(Type.Group, 15035, "Иб-012"),
    _SearchItem(Type.Group, 15016, "Иб-021"),
    _SearchItem(Type.Group, 15024, "Иб-031"),
    _SearchItem(Type.Group, 15030, "Иб-041"),
    _SearchItem(Type.Group, 15031, "Иб-042"),
    _SearchDivider(),
    _SearchItem(Type.Group, 15122, "Эб-011"),
    _SearchItem(Type.Group, 15123, "Эб-012"),
    _SearchItem(Type.Group, 15022, "Эб-021"),
    _SearchItem(Type.Group, 15023, "Эб-022"),
    _SearchItem(Type.Group, 15113, "Эб-031"),
    _SearchItem(Type.Group, 15112, "Эб-032"),
    _SearchDivider(),
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

  Future<void> loadSuggestions() async {
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
    final List<_SearchItemBase> _recentSuggestions = query.isEmpty
        ? groupSuggestions
        : groupSuggestions.where((p) {
            if (p is _SearchItem) {
              final _SearchItem _p = p;
              return _p.title
                  .startsWith(RegExp("^" + query, caseSensitive: false));
            }

            return false;
          }).toList();

    final List<_SearchItemBase> _suggestions =
        DateTime.now().isBefore(DateTime(2019, 9))
            ? (List.from(_recentSuggestions)..addAll(suggestions))
            : suggestions;

    return ListView.builder(
        itemBuilder: (context, index) {
          final mBaseItem = _suggestions[index];

          if (mBaseItem is _SearchItem) {
            final _SearchItem mSearchItem = mBaseItem;

            IconData iconData;
            switch (mSearchItem.type) {
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
                          text: mSearchItem.title,
                          style: TextStyle(color: Colors.grey)))
                  // Recent suggestion
                  : RichText(
                      // Recent suggestion
                      text: TextSpan(
                          text: mSearchItem.title.substring(0, query.length),
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          children: [
                          TextSpan(
                              text: mSearchItem.title.substring(query.length),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal))
                        ])),
            );
          } else if (mBaseItem is _SearchDivider) {
            return Divider();
          }
        },
        itemCount: _suggestions.length);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: loadSuggestions(),
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
                        child: new Icon(Icons.error, size: 70),
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
