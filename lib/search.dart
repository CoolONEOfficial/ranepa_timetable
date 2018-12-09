import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ranepa_timetable/drawer_prefs.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

class SearchItemType {
  final IconData icon;

  const SearchItemType(this.icon);
}

enum SearchItemTypeId { TEACHER, GROUP }

const SEARCH_ITEM_TYPES = const <SearchItemType>[
  const SearchItemType(Icons.person), // TEACHER
  const SearchItemType(Icons.group) // GROUP
];

abstract class SearchItemBase {
  const SearchItemBase();
}

class SearchItem extends SearchItemBase {
  const SearchItem(this.typeId, this.id, this.title);

  static const PREFERENCES_TYPE_ID = "type";
  static const PREFERENCES_ID = "id";
  static const PREFERENCES_TITLE = "title";

  final SearchItemTypeId typeId;
  final int id;
  final String title;

  @override
  String toString() =>
      "Search item: type - " +
      typeId.toString() +
      ", id - " +
      id.toString() +
      ", title - " +
      title +
      ".\n";

  void toPrefs(SharedPreferences prefs) {
    prefs.setInt(
        PrefsIds.SEARCH_ITEM_PREFIX + PREFERENCES_TYPE_ID, typeId.index);
    prefs.setInt(PrefsIds.SEARCH_ITEM_PREFIX + PREFERENCES_ID, id);
    prefs.setString(PrefsIds.SEARCH_ITEM_PREFIX + PREFERENCES_TITLE, title);
  }

  factory SearchItem.fromPrefs(SharedPreferences prefs) => SearchItem(
        SearchItemTypeId.values[
            prefs.getInt(PrefsIds.SEARCH_ITEM_PREFIX + PREFERENCES_TYPE_ID)],
        prefs.getInt(PrefsIds.SEARCH_ITEM_PREFIX + PREFERENCES_ID),
        prefs.getString(PrefsIds.SEARCH_ITEM_PREFIX + PREFERENCES_TITLE),
      );
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
          SearchItem(SearchItemTypeId.GROUP, 15034, "Иб-011"),
          SearchItem(SearchItemTypeId.GROUP, 15035, "Иб-012"),
          SearchItem(SearchItemTypeId.GROUP, 15016, "Иб-021"),
          SearchItem(SearchItemTypeId.GROUP, 15024, "Иб-031"),
          SearchItem(SearchItemTypeId.GROUP, 15030, "Иб-041"),
          SearchItem(SearchItemTypeId.GROUP, 15031, "Иб-042"),
          SearchDivider(AppLocalizations.of(context).groupEconomics),
          SearchItem(SearchItemTypeId.GROUP, 15122, "Эб-011"),
          SearchItem(SearchItemTypeId.GROUP, 15123, "Эб-012"),
          SearchItem(SearchItemTypeId.GROUP, 15022, "Эб-021"),
          SearchItem(SearchItemTypeId.GROUP, 15023, "Эб-022"),
          SearchItem(SearchItemTypeId.GROUP, 15113, "Эб-031"),
          SearchItem(SearchItemTypeId.GROUP, 15112, "Эб-032"),
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
          final mItem = suggestions[index];

          final ThemeData theme = Theme.of(context);
          if (mItem is SearchItem) {
            final queryIndex =
                    mItem.title.indexOf(RegExp(query, caseSensitive: false)),
                selectColor = theme.textSelectionColor,
                normalColor = theme.textTheme.title.color;

            return ListTile(
                onTap: () {
                  close(context, mItem);
                },
                leading: Icon(SEARCH_ITEM_TYPES[mItem.typeId.index].icon),
                title: RichText(
                  // Recent suggestion
                  text: queryIndex == 0
                      ? TextSpan(
                          text: mItem.title.substring(
                            0,
                            query.length,
                          ),
                          style: TextStyle(
                            color: selectColor,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: mItem.title.substring(query.length),
                              style: TextStyle(
                                  color: normalColor,
                                  fontWeight: FontWeight.normal),
                            )
                          ],
                        )
                      : TextSpan(
                          text: mItem.title.substring(
                            0,
                            queryIndex,
                          ),
                          style: TextStyle(
                              color: normalColor,
                              fontWeight: FontWeight.normal),
                          children: [
                            TextSpan(
                              text: mItem.title.substring(
                                  queryIndex, queryIndex + query.length),
                              style: TextStyle(
                                  color: selectColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: mItem.title
                                  .substring(queryIndex + query.length),
                              style: TextStyle(
                                  color: normalColor,
                                  fontWeight: FontWeight.normal),
                            )
                          ],
                        ),
                ));
          } else if (mItem is SearchDivider) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 15),
                  child: Text(mItem.title, style: theme.textTheme.caption),
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
        : WidgetTemplates.buildFutureBuilder(
            context,
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
              debugPrint("Search snapshot data: " + snapshot.data);
              final itemArr = xml
                  .parse(snapshot.data)
                  .children[1]
                  .firstChild
                  .firstChild
                  .firstChild
                  .children;

              for (var mItem in itemArr) {
                SearchItemTypeId mItemTypeId;

                switch (mItem.children[SearchResponseIndexes.Type.index].text) {
                  case "Prep":
                    mItemTypeId = SearchItemTypeId.TEACHER;
                    break;
                  case "Group":
                    mItemTypeId = SearchItemTypeId.GROUP;
                    break;
                  default:
                    mItemTypeId = null;
                }

                webSuggestions.add(SearchItem(
                  mItemTypeId,
                  int.parse(
                      mItem.children[SearchResponseIndexes.Id.index].text),
                  mItem.children[SearchResponseIndexes.Title.index].text,
                ));
              }
              debugPrint(webSuggestions.toString());

              return _buildSuggestions();
            },
            loading: Stack(
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
            ),
          );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return theme.brightness == Brightness.light
        ? super.appBarTheme(context)
        : theme.copyWith(
            primaryColor: theme.primaryColor,
            primaryIconTheme: theme.primaryIconTheme,
            primaryColorBrightness: theme.primaryColorBrightness,
            primaryTextTheme: theme.primaryTextTheme,
          );
  }
}
