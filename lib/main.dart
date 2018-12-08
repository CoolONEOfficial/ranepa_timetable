import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:ranepa_timetable/drawer_prefs.dart';
import 'package:ranepa_timetable/drawer_timetable.dart';
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
                      image: AssetImage('assets/images/icon-foreground.png'))),
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
          theme: Themes().themes[prefs.getInt(PrefsIds.THEME_ID) ?? 0],
          routes: <String, WidgetBuilder>{
            DrawerPrefs.ROUTE: (BuildContext context) => DrawerPrefs()
          },
          home: Builder(
            builder: (context) => prefs.getInt(PrefsIds.SEARCH_ITEM_PREFIX +
                        SearchItem.PREFERENCES_ID) ==
                    null
                ? IntroViewsFlutter(
                    [
                      PageViewModel(
                          pageColor: const Color(0xFF03A9F4),
                          // iconImageAssetPath: 'assets/air-hostess.png',
                          //bubble: Image.asset('assets/air-hostess.png'),
                          body: Text(
                            'Haselfree  booking  of  flight  tickets  with  full  refund  on  cancelation',
                          ),
                          title: Text(
                            'Flights',
                          ),
                          mainImage: Column(
                            children: <Widget>[
                              IconButton(
                                onPressed: () =>
                                    showSearchItemSelect(context, prefs),
                                icon: Icon(Icons.search),
                              )
                            ],
                          )
//                          mainImage: Image.asset(
//                            'assets/airplane.png',
//                            height: 285.0,
//                            width: 285.0,
//                            alignment: Alignment.center,
//                          ),
                          ),
                    ],
                    onTapDoneButton: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => buildBase(context, prefs),
                        ),
                      );
                    },
                    showSkipButton: false,
                    pageButtonTextStyles: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  )
                : buildBase(context, prefs),
          ),
        );
      },
    );
  }
}

final themeIdBloc = StreamController<int>.broadcast();

Future main() async {
  return runApp(BaseWidget());
}
