import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/drawer_settings.dart';

class MainWidget extends StatelessWidget {
  static const ROUTE = "timetable";
  BuildContext _context;

  void _drawerTap(Widget w) {
    Navigator.of(_context).pop();
    Navigator.push(
        _context,
        new PageRouteBuilder(pageBuilder: (BuildContext context, _, __) {
          return w;
        }, transitionsBuilder:
            (_, Animation<double> animation, __, Widget child) {
          return new FadeTransition(opacity: animation, child: child);
        }));
  }

  Widget buildDrawer() {
    return Drawer(
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
            title: Text('Timetable'),
            onTap: () => _drawerTap(new MainWidget()),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => _drawerTap(new DrawerSettings()),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.close),
            title: Text('Close'),
            onTap: () {
              Navigator.pop(_context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;
    return Scaffold(
      drawer: buildDrawer(),
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
  ));
}
