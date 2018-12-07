import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/themes.dart';

class DrawerPreferences extends StatelessWidget {
  static const ROUTE = "/preferences";

  static Widget buildPreferenceButton(BuildContext context,
      {@required String title,
      @required String description,
      @required VoidCallback onPressed,
      Widget rightWidget}) {
    var rowChildren = <Widget>[
      Expanded(
          child: ListBody(
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.subhead,
          ),
          Container(
            height: 2,
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      )),
    ];

    if (rightWidget != null) rowChildren.add(rightWidget);

    return FlatButton(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.0),
          child: Row(children: rowChildren)),
      onPressed: onPressed,
    );
  }

  Future<void> _themeDialog(BuildContext context) async {
    final dialogItems = List<Widget>();

    for (var mThemeIds in ThemeIds.values) {
      dialogItems.add(SimpleDialogOption(
        onPressed: () {
          themeIdBloc.sink.add(mThemeIds.index);
          Navigator.pop(context, mThemeIds);
        },
        child: Text(ThemeTitles(context).titles[mThemeIds.index]),
      ));
    }

    themeIdBloc.sink.add(Themes().themes[await showDialog<ThemeIds>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: const Text('Select theme'), children: dialogItems);
        })]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).preferences),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: <Widget>[
          buildPreferenceButton(context,
              title: AppLocalizations.of(context).themeTitle,
              description: AppLocalizations.of(context).themeDescription,
              onPressed: () => _themeDialog(context),
              rightWidget: StreamBuilder<int>(
                stream: themeIdBloc.stream,
                initialData: 0,
                builder: (context, snapshot) =>
                    Text(ThemeTitles(context).titles[snapshot.data]),
              )),
          Divider(
            height: 0,
          ),
          buildPreferenceButton(
            context,
            title: AppLocalizations.of(context).groupTitle,
            description: AppLocalizations.of(context).groupDescription,
            onPressed: () => () {
                  showSearch<SearchItem>(
                    context: context,
                    delegate: Search(context),
                  ).then((item) => {});
                },
          ),
          Divider(
            height: 0,
          ),
          buildPreferenceButton(
            context,
            title: AppLocalizations.of(context).widgetTranslucentTitle,
            description:
                AppLocalizations.of(context).widgetTranslucentDescription,
            rightWidget: Checkbox(value: false, onChanged: (bool) {}),
            onPressed: () => _themeDialog(context),
          ),
          Divider(
            height: 0,
          ),
        ],
      ),
    );
  }
}
