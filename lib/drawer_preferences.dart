import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/themes.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesIds {
  static const WIDGET_TRANSLUCENT = "widget_translucent";
  static const THEME_ID = "theme_id";
}

class DrawerPreferences extends StatelessWidget {
  static const ROUTE = "/preferences";

  final widgetTranslucent = StreamController<bool>();

  static Widget buildPreferenceButton(BuildContext context,
      {@required String title,
      @required String description,
      VoidCallback onPressed,
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
      onPressed: onPressed ?? () {},
    );
  }

  void _themeDialog(BuildContext context, SharedPreferences preferences) {
    final dialogItems = List<Widget>();

    for (var mThemeId in ThemeIds.values) {
      dialogItems.add(SimpleDialogOption(
        onPressed: () {
          themeIdBloc.sink.add(mThemeId.index);
          preferences.setInt(PreferencesIds.THEME_ID, mThemeId.index);
          Navigator.pop(context, mThemeId);
        },
        child: Text(ThemeTitles(context).titles[mThemeId.index]),
      ));
    }

    showDialog<ThemeIds>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(AppLocalizations.of(context).themeTitle),
              children: dialogItems);
        }).then((themeId) {});
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
      body: WidgetTemplates.buildFutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          final preferences = snapshot.data;
          return ListView(
            children: <Widget>[
              buildPreferenceButton(context,
                  title: AppLocalizations.of(context).themeTitle,
                  description: AppLocalizations.of(context).themeDescription,
                  onPressed: () => _themeDialog(context, preferences),
                  rightWidget: StreamBuilder<int>(
                    stream: themeIdBloc.stream,
                    initialData:
                        preferences.getInt(PreferencesIds.THEME_ID) ?? 0,
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
              new StreamBuilder<bool>(
                initialData:
                    preferences.getBool(PreferencesIds.WIDGET_TRANSLUCENT) ??
                        false,
                stream: widgetTranslucent.stream,
                builder: (context, snapshot) => buildPreferenceButton(
                      context,
                      title:
                          AppLocalizations.of(context).widgetTranslucentTitle,
                      description: AppLocalizations.of(context)
                          .widgetTranslucentDescription,
                      rightWidget: Checkbox(
                        value: snapshot.data,
                        onChanged: (value) {
                          widgetTranslucent.add(value);
                          preferences.setBool(
                              PreferencesIds.WIDGET_TRANSLUCENT, value);
                        },
                      ),
                    ),
              ),
              Divider(
                height: 0,
              ),
            ],
          );
        },
      ),
    );
  }
}
