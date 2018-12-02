import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ranepa_timetable/localizations.dart';
import 'package:xml/xml.dart' as xml;

class SearchItemType {
  final IconData icon;

  const SearchItemType(this.icon);
}

class SearchItemTypes {
  static const UNKNOWN = const SearchItemType(Icons.insert_drive_file);
  static const TEACHER = const SearchItemType(Icons.person);
  static const GROUP = const SearchItemType(Icons.group);
}

abstract class SearchItemBase {
  const SearchItemBase();
}

class SearchItem extends SearchItemBase {
  const SearchItem(this.type, this.id, this.title);

  final SearchItemType type;
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

class SearchDivider extends SearchItemBase {
  const SearchDivider(this.title);

  final String title;
}

enum SearchResponseIndexes { Type, Id, Title }

class Search extends SearchDelegate<SearchItem> {
  List<SearchItemBase> webSuggestions = [];

  // Check 2018-2019 academic year because all item ids in next year will be refreshed
  final bool predefinedSuggestionsValid =
  DateTime.now().isBefore(DateTime(2019, 9));

  final List<SearchItemBase> predefinedSuggestions;

  Search(BuildContext context)
      : predefinedSuggestions = [
    SearchDivider(AppLocalizations.of(context).groupInformatics),
    SearchItem(SearchItemTypes.GROUP, 15034, "Иб-011"),
    SearchItem(SearchItemTypes.GROUP, 15035, "Иб-012"),
    SearchItem(SearchItemTypes.GROUP, 15016, "Иб-021"),
    SearchItem(SearchItemTypes.GROUP, 15024, "Иб-031"),
    SearchItem(SearchItemTypes.GROUP, 15030, "Иб-041"),
    SearchItem(SearchItemTypes.GROUP, 15031, "Иб-042"),
    SearchDivider(AppLocalizations.of(context).groupEconomics),
    SearchItem(SearchItemTypes.GROUP, 15122, "Эб-011"),
    SearchItem(SearchItemTypes.GROUP, 15123, "Эб-012"),
    SearchItem(SearchItemTypes.GROUP, 15022, "Эб-021"),
    SearchItem(SearchItemTypes.GROUP, 15023, "Эб-022"),
    SearchItem(SearchItemTypes.GROUP, 15113, "Эб-031"),
    SearchItem(SearchItemTypes.GROUP, 15112, "Эб-032"),
    SearchDivider(AppLocalizations.of(context).searchResults),
  ];

  @override
  List<Widget> buildActions(context) {
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
  Widget buildLeading(context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  Widget _buildSuggestions() {
    final queryPredefinedSuggestions = query.isEmpty
        ? predefinedSuggestions
        : predefinedSuggestions.where((mSearchItemBase) {
      switch (mSearchItemBase.runtimeType) {
        case SearchItem:
          final SearchItem mSearchItem = mSearchItemBase;
          return mSearchItem.title
              .startsWith(RegExp("^" + query, caseSensitive: false));
          break;
        case SearchDivider:
          return true;
          break;
      }

      return false;
    }).toList();

    final List<SearchItemBase> suggestions = predefinedSuggestionsValid
        ? (List.from(queryPredefinedSuggestions)..addAll(webSuggestions))
        : webSuggestions;

    for (var mIndex = 0; mIndex < suggestions.length - 1; mIndex++) {
      final mSuggestion = suggestions.elementAt(mIndex);
      final mPreSuggestion = suggestions.elementAt(mIndex + 1);
      if (mSuggestion is SearchDivider && mPreSuggestion is SearchDivider) {
        suggestions.removeAt(mIndex);
        mIndex--; // don't skip
      }
    }

    return ListView.builder(
        itemBuilder: (context, index) {
          final mBaseItem = suggestions[index];

          if (mBaseItem is SearchItem) {
            final SearchItem mSearchItem = mBaseItem;
            final queryIndex =
            mSearchItem.title.indexOf(RegExp(query, caseSensitive: false));

            return ListTile(
                onTap: () {
                  close(context, mSearchItem);
                },
                leading: Icon(mSearchItem.type.icon),
                title: RichText(
                  // Recent suggestion
                    text: queryIndex == 0
                        ? TextSpan(
                      text: mSearchItem.title.substring(
                        0,
                        query.length,
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                            text:
                            mSearchItem.title.substring(query.length),
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal))
                      ],
                    )
                        : TextSpan(
                      text: mSearchItem.title.substring(
                        0,
                        queryIndex,
                      ),
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal),
                      children: [
                        TextSpan(
                            text: mSearchItem.title.substring(
                                queryIndex, queryIndex + query.length),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: mSearchItem.title
                                .substring(queryIndex + query.length),
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal))
                      ],
                    ))
              // Recent suggestion
            );
          } else if (mBaseItem is SearchDivider) {
            final SearchDivider mDivider = mBaseItem;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 15),
                  child: RichText(
                      text: TextSpan(
                          text: mDivider.title,
                          style: TextStyle(color: Colors.grey))),
                ),
                Divider(),
              ],
            );
          }
        },
        itemCount: suggestions.length);
  }

  @override
  Widget buildSuggestions(context) {
    debugPrint("Suggestions build start");
    webSuggestions.clear();
    return query.isEmpty
        ? _buildSuggestions()
        : FutureBuilder<String>(
      future: http.post('http://test.ranhigs-nn.ru/api/WebService.asmx',
          headers: {'Content-Type': 'text/xml; charset=utf-8'}, body: '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetNameUidForRasp xmlns="http://tempuri.org/">
      <str>$query</str>
    </GetNameUidForRasp>
  </soap:Body>
</soap:Envelope>
''').then((response) => response.body),
      builder: (context, snapshot) {
        debugPrint("Search builder started: " +
            snapshot.connectionState.toString());
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
                    height: 15.0,
                    width: 15.0,
                  ),
                ),
                _buildSuggestions()
              ],
            );
            break;
          case ConnectionState.done:
            debugPrint("Search results done");
            if (snapshot.hasError)
              return Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Icon(Icons.error, size: 70),
                      ),
                    ),
                    RichText(
                        text: TextSpan(
                            text: "${snapshot.error}",
                            style: TextStyle(color: Colors.black)))
                  ],
                ),
              );

            debugPrint("Search snapshot data: " + snapshot.data);
            final itemArr = xml
                .parse(snapshot.data)
                .children[1]
                .firstChild
                .firstChild
                .firstChild
                .children;

            for (var mItem in itemArr) {
              SearchItemType mItemType;

              switch (
              mItem.children[SearchResponseIndexes.Type.index].text) {
                case "Prep":
                  mItemType = SearchItemTypes.TEACHER;
                  break;
                case "Group":
                  mItemType = SearchItemTypes.GROUP;
                  break;
                default:
                  mItemType = SearchItemTypes.UNKNOWN;
              }

              webSuggestions.add(SearchItem(
                mItemType,
                int.parse(
                    mItem.children[SearchResponseIndexes.Id.index].text),
                mItem.children[SearchResponseIndexes.Title.index].text,
              ));
            }
            debugPrint(webSuggestions.toString());

            return _buildSuggestions();
        }
        return null; // unreachable
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }
}
