import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ranepa_timetable/drawer_prefs.dart';
import 'package:ranepa_timetable/drawer_timetable.dart';
import 'package:ranepa_timetable/intro.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/themes.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseWidget extends StatelessWidget {
  Widget buildBase(BuildContext context, SharedPreferences prefs) {
    return DrawerTimetable(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                image: DecorationImage(
                  image: AssetImage('assets/images/icon-foreground.png'),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.line_style),
              title: Text(AppLocalizations.of(context).timetable),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(AppLocalizations.of(context).prefs),
              onTap: () =>
                  Navigator.popAndPushNamed(context, DrawerPrefs.ROUTE),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.close),
              title: Text(AppLocalizations.of(context).close),
              onTap: () => SystemNavigator.pop(),
            ),
          ],
        ),
      ),
      prefs: prefs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WidgetTemplates.buildFutureBuilder<SharedPreferences>(
      context,
      loading: Container(),
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        return StreamBuilder<int>(
          stream: themeIdBloc.stream,
          initialData:
              prefs.getInt(PrefsIds.THEME_ID) ?? Themes.DEFAULT_THEME_ID.index,
          builder: (context, snapshot) {
            final themeId = snapshot.data;
            return MaterialApp(
              localizationsDelegates: [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              supportedLocales: [
                const Locale('en', 'US'), // English
                const Locale('ru', 'RU'), // Русский
              ],
              onGenerateTitle: (BuildContext context) =>
                  AppLocalizations.of(context).title,
              theme: Themes().themes[themeId],
              routes: <String, WidgetBuilder>{
                DrawerPrefs.ROUTE: (BuildContext context) => DrawerPrefs()
              },
              home: Builder(
                builder: (context) => prefs.getInt(PrefsIds.SEARCH_ITEM_PREFIX +
                            SearchItem.PREFERENCES_ID) ==
                        null
                    ? Intro(base: buildBase(context, prefs), prefs: prefs)
                    : buildBase(context, prefs),
              ),
            );
          },
        );
      },
    );
  }
}

final themeIdBloc = StreamController<int>.broadcast();

Future main() async {
  return runApp(BaseWidget());
}
