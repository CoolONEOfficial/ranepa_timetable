import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ranepa_timetable/drawer_timetable.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/drawer_preferences.dart';

class MainWidget extends StatelessWidget {
  static const ROUTE = "timetable";
  BuildContext _context;
  Drawer drawer;
  DrawerTimetable drawerTimetable;

  void _drawerTap(String route) {
    Navigator.popAndPushNamed(_context, route);
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;

    if (drawer == null)
      drawer = Drawer(
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
                  color: Theme.of(_context).accentColor,
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

    if (drawerTimetable == null) drawerTimetable = DrawerTimetable(drawer);

    return Scaffold(
      body: drawerTimetable,
      drawer: drawer,
    );
  }
}

Future main() async {
  return runApp(MaterialApp(
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
    theme: ThemeData.light(),
    home: MainWidget(),
    routes: <String, WidgetBuilder>{
      DrawerPreferences.ROUTE: (BuildContext context) => DrawerPreferences()
    },
  ));
}
