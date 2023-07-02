import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ranepatimetable/apis.dart';
import 'package:ranepatimetable/localizations.dart';
import 'package:ranepatimetable/prefs.dart';
import 'package:ranepatimetable/theme.dart';
import 'package:ranepatimetable/widget_templates.dart';

class SearchItemType {
  final IconData icon;
  final String oldApiStr;
  final String newApiStr;

  const SearchItemType(this.icon, this.oldApiStr, this.newApiStr);
}

enum SearchItemTypeId {
  Group,
  Teacher,
}

const SearchItemTypeId DEFAULT_ITEM_TYPE_ID = SearchItemTypeId.Group;

final searchItemTypes = List<SearchItemType>.generate(
  SearchItemTypeId.values.length,
  (index) {
    switch (SearchItemTypeId.values[index]) {
      case SearchItemTypeId.Teacher:
        return SearchItemType(Icons.person, "Prep", "teacher");
      case SearchItemTypeId.Group:
        return SearchItemType(Icons.group, "Group", "group");
    }
  },
);

abstract class SearchItemBase {
  const SearchItemBase();
}

class SearchItem extends SearchItemBase {
  const SearchItem(this.typeId, this.id, this.title);

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

  Future<void> toPrefs(String prefix) async {
    prefs.setInt(prefix + PrefsIds.ITEM_TYPE, typeId.index);
    prefs.setInt(prefix + PrefsIds.ITEM_ID, id);
    prefs.setString(prefix + PrefsIds.ITEM_TITLE, title);
    debugPrint("searchitem saved to prefs");
  }

  factory SearchItem.fromPrefs([
    String prefix = PrefsIds.SEARCH_ITEM_PREFIX,
  ]) =>
      SearchItem(
        SearchItemTypeId.values[prefs.getInt(prefix + PrefsIds.ITEM_TYPE) ??
            DEFAULT_ITEM_TYPE_ID.index],
        prefs.getInt(prefix + PrefsIds.ITEM_ID) ?? 0,
        prefs.getString(prefix + PrefsIds.ITEM_TITLE) ?? '',
      );
}

class SearchDivider extends SearchItemBase {
  const SearchDivider(this.title);

  final String title;
}

class SearchScreen extends StatefulWidget {
  static const ROUTE = "/search";

  static Future<dynamic> showSearch(BuildContext ctx) async {
    return await Navigator.pushNamed(ctx, SearchScreen.ROUTE);
  }

  static _capitalizeString(String str) =>
      str[0].toUpperCase() + str.substring(1).toLowerCase();

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  _cancelPressed(BuildContext ctx) => Navigator.pop(ctx);

  _searchPlaceholder(BuildContext ctx) =>
      MaterialLocalizations.of(ctx).searchFieldLabel;

  get predefinedSuggestions => [
        SearchDivider(AppLocalizations.of(context).groupInformatics),
        SearchItem(SearchItemTypeId.Group, 15869, "Иб-011"),
        SearchItem(SearchItemTypeId.Group, 15834, "Иб-021"),
        SearchItem(SearchItemTypeId.Group, 15835, "Иб-022"),
        SearchItem(SearchItemTypeId.Group, 15864, "Иб-031"),
        SearchItem(SearchItemTypeId.Group, 15859, "Иб-041"),
        SearchDivider(AppLocalizations.of(context).groupEconomics),
        SearchItem(SearchItemTypeId.Group, 15856, "Эк-111"),
        SearchItem(SearchItemTypeId.Group, 15844, "Эк-121"),
        SearchItem(SearchItemTypeId.Group, 15882, "Эб-011"),
        SearchItem(SearchItemTypeId.Group, 15827, "Эб-021"),
        SearchItem(SearchItemTypeId.Group, 15828, "Эб-022"),
        SearchItem(SearchItemTypeId.Group, 15845, "Эб-031"),
        SearchItem(SearchItemTypeId.Group, 15847, "Эб-032"),
        SearchDivider(AppLocalizations.of(context).searchResults),
      ];
  List<SearchItemBase> webSuggestions = [];

  initState() {
    super.initState();
  }

  TextEditingController searchController = TextEditingController();

  get query => searchController.text;

  static http.Response? _newApiCachedResults;

  Future<http.Response> _buildHttpRequest(SiteApiIds api) {
    switch (api) {
      case SiteApiIds.APP_NEW:
        return _newApiCachedResults == null
            ? http.get(Uri.parse('http://services.niu.ranepa.ru/'
            'API/public/teacher/teachersAndGroupsList'))
            : Future<http.Response>.value(_newApiCachedResults);
      case SiteApiIds.APP_OLD:
        return http.post(Uri.parse('http://test.ranhigs-nn.ru/api/WebService.asmx'),
            headers: {'Content-Type': 'text/xml; charset=utf-8'}, body: '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetNameUidForRasp xmlns="http://tempuri.org/">
      <str>$query</str>
    </GetNameUidForRasp>
  </soap:Body>
</soap:Envelope>
''');
      case SiteApiIds.SITE:
        return http.get(Uri.parse('http://services.niu.ranepa.ru/'
            'wp-content/plugins/rasp/rasp_json_data.php?name=$query'));
      default:
        throw Exception("api is fucked up");
    }
  }

  Widget buildSuggestions(BuildContext ctx) {
    debugPrint("Suggestions build start");
    webSuggestions.clear();
    var api = SiteApiIds
        .values[prefs.getInt(PrefsIds.SITE_API) ?? DEFAULT_API_ID.index];
    return searchController.text.isEmpty
        ? _buildSuggestions()
        : RegExp(r"^[(А-я)\d\s\-]+$").hasMatch(searchController.text)
            ? WidgetTemplates.buildFutureBuilder(
                ctx,
                future: _buildHttpRequest(api).then((response) => response),
                builder: (ctx, snapshot) {
                  if (_newApiCachedResults == null)
                    _newApiCachedResults = snapshot.data as http.Response;
                  final body = (snapshot.data as http.Response).body;

                  debugPrint("Search snapshot data body: " + body);

                  final resultArr = parseResp(api, body);

                  for (var mItem in resultArr) {
                    var mItemType;
                    String mItemTitle;
                    int mItemId;

                    switch (api) {
                      case SiteApiIds.APP_NEW:
                        mItemType = mItem["type"];
                        mItemTitle = mItem["value"];
                        if (!mItemTitle
                            .toLowerCase()
                            .contains(query.toLowerCase())) continue;
                        mItemId = int.parse(mItem["oid"]);
                        break;
                      case SiteApiIds.APP_OLD:
                        mItemType = mItem
                            .children[OldAppApiSearchIndexes.Type.index].text;
                        mItemTitle = mItem
                            .children[OldAppApiSearchIndexes.Title.index].text;
                        mItemId = int.parse(mItem
                            .children[OldAppApiSearchIndexes.Id.index].text);
                        break;
                      case SiteApiIds.SITE:
                        mItemType = mItem["Type"];
                        mItemTitle = mItem["Title"];
                        mItemId = mItem["id"];
                        break;
                    }

                    SearchItemTypeId? mItemTypeId;

                    switch (api) {
                      case SiteApiIds.APP_NEW:
                        mItemTypeId =
                            SearchItemTypeId.values[int.parse(mItemType)];
                        break;
                      case SiteApiIds.APP_OLD:
                      case SiteApiIds.SITE:
                        switch (mItemType) {
                          case "Prep":
                            mItemTypeId = SearchItemTypeId.Teacher;
                            break;
                          case "Group":
                            mItemTypeId = SearchItemTypeId.Group;
                            break;
                        }
                        break;
                    }

                    webSuggestions.add(SearchItem(
                      mItemTypeId!,
                      mItemId,
                      mItemTitle,
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
                        child: PlatformCircularProgressIndicator(),
                        height: 15.0,
                        width: 15.0,
                      ),
                    ),
                    _buildSuggestions()
                  ],
                ),
              )
            : Container();
  }

  Widget _buildSuggestions() {
    final query = searchController.text;

    final queryPredefinedSuggestions = query.isEmpty
        ? predefinedSuggestions
        : predefinedSuggestions.where((mSearchItemBase) {
            switch (mSearchItemBase.runtimeType) {
              case SearchItem:
                final SearchItem mSearchItem = mSearchItemBase;
                return mSearchItem.title
                    .startsWith(RegExp("^" + query, caseSensitive: false));
              case SearchDivider:
                return true;
            }

            return false;
          }).toList();

    final List<SearchItemBase> suggestions =
        List.from(queryPredefinedSuggestions)..addAll(webSuggestions);

    for (var mIndex = 0; mIndex < suggestions.length - 1; mIndex++) {
      final mSuggestion = suggestions.elementAt(mIndex);
      final mPreSuggestion = suggestions.elementAt(mIndex + 1);
      if (mSuggestion is SearchDivider && mPreSuggestion is SearchDivider) {
        suggestions.removeAt(mIndex);
        mIndex--; // don't skip
      }
    }

    return Container(
      color: Platform.isIOS
          ? getTheme().brightness == Brightness.dark
              ? Colors.black
              : Colors.white
          : Colors.transparent,
      child: ListView.separated(
          separatorBuilder: (ctx, _) => Divider(
                color: getTheme().dividerColor,
                height: 1,
              ),
          itemBuilder: (ctx, index) {
            final mItem = suggestions[index];

            final ThemeData theme = Theme.of(ctx);
            if (mItem is SearchItem) {
              final queryIndex =
                      mItem.title.indexOf(RegExp(query, caseSensitive: false)),
                  selectColor = Colors.blue,
                  normalColor = theme.textTheme.titleLarge?.color;

              return WidgetTemplates.buildListTile(
                ctx,
                onTap: () {
                  Navigator.pop(ctx, mItem);
                },
                leading: Icon(
                  searchItemTypes[mItem.typeId.index].icon,
                  color: Platform.isIOS ? theme.primaryColor : null,
                ),
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
                ),
              );
            } else if (mItem is SearchDivider) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                    child: Text(mItem.title, style: theme.textTheme.caption),
                  ),
                ],
              );
            }
            return null;
          },
          itemCount: suggestions.length ?? 0),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        cupertino: (ctx, _) => CupertinoNavigationBarData(
          padding: const EdgeInsetsDirectional.only(end: 15),
        ),
        leading: !Platform.isIOS
            ? PlatformIconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  ctx.platformIcons.back,
                ),
                onPressed: () => _cancelPressed(ctx),
              )
            : SizedBox(
                width: 0,
              ),
        trailingActions: Platform.isIOS
            ? <Widget>[
                CupertinoButton(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    SearchScreen._capitalizeString(
                        MaterialLocalizations.of(ctx).cancelButtonLabel),
                    style: getTheme().textTheme.bodyLarge,
                  ),
                  onPressed: () => _cancelPressed(ctx),
                ),
              ]
            : [],
        title: PlatformTextField(
          controller: searchController,
          maxLines: 1,
          autocorrect: true,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.text,
          onSubmitted: (_) {
            setState(() {});
          },
          onChanged: (_) {
            setState(() {});
          },
          cupertino: (ctx, _) => CupertinoTextFieldData(
              prefix: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Icon(
                  CupertinoIcons.search,
                  size: 20,
                  color: getTheme().primaryColor,
                ),
              ),
              placeholder: _searchPlaceholder(ctx),
              clearButtonMode: OverlayVisibilityMode.editing,
              cursorColor: getTheme().primaryColor),
          material: (ctx, _) => MaterialTextFieldData(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: _searchPlaceholder(ctx),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: getTheme().textTheme.bodyLarge?.color,
                      ),
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      })
                  : null,
            ),
          ),
        ),
      ),
      body: buildSuggestions(ctx),
    );
  }
}
