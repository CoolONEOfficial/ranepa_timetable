import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ranepa_timetable/drawer_preferences.dart';
import 'package:ranepa_timetable/drawer_timetable.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/themes.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainWidget extends StatelessWidget {
  static const ROUTE = "timetable";
  BuildContext _context;

  final int darkThemeEnabled;

  MainWidget({Key key, this.darkThemeEnabled}) : super(key: key);

  void _drawerTap(String route) {
    Navigator.popAndPushNamed(_context, route);
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;

    final drawer = Drawer(
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
                color: Theme.of(_context).primaryColor,
                image: DecorationImage(
                    image: AssetImage('assets/images/icon-foreground.png'))),
          ),
          ListTile(
            leading: Icon(Icons.line_style),
            title: Text(AppLocalizations.of(context).timetable),
            onTap: () => Navigator.pop(_context),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).preferences),
            onTap: () => _drawerTap(DrawerPreferences.ROUTE),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.close),
            title: Text(AppLocalizations.of(context).close),
            onTap: () => SystemNavigator.pop(),
          ),
        ],
      ),
    );

    return Scaffold(
      body: DrawerTimetable(drawer: drawer),
      drawer: drawer,
    );
  }
}

class BaseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WidgetTemplates.buildFutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) => StreamBuilder(
            stream: themeIdBloc.stream,
            initialData: snapshot.data.getInt(PreferencesIds.THEME_ID) ?? 1,
            builder: (context, snapshot) => MaterialApp(
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
                  title: 'Flutter View',
                  theme: Themes().themes[snapshot.data],
                  home: MainWidget(
                    darkThemeEnabled: snapshot.data,
                  ),
                  routes: <String, WidgetBuilder>{
                    DrawerPreferences.ROUTE: (BuildContext context) =>
                        DrawerPreferences()
                  },
                ),
          ),
    );
  }
}

final themeIdBloc = StreamController<int>.broadcast();

Future main() async {
  return runApp(BaseWidget());
}
