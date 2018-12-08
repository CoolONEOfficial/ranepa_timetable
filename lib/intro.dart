import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:ranepa_timetable/drawer_prefs.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Intro extends StatelessWidget {
  final Widget base;
  final SharedPreferences prefs;

  const Intro({Key key, @required this.base, @required this.prefs})
      : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        stream: themeIdBloc.stream,
        initialData:
            prefs.getInt(PrefsIds.THEME_ID) ?? Themes.DEFAULT_THEME_ID.index,
        builder: (context, snapshot) {
          final theme = Themes().themes[snapshot.data];
          final localizations = AppLocalizations.of(context);
          return IntroViewsFlutter(
            [
              PageViewModel(
                pageColor: theme.brightness == Brightness.light ? theme.primaryColor : theme.canvasColor,
                bubble: Icon(
                  Icons.color_lens,
                  color: theme.brightness == Brightness.light ? theme.primaryColor : theme.canvasColor,
                ),
                body: Text(
                  localizations.introThemeDescription,
                ),
                title: Text(
                  localizations.introThemeTitle,
                ),
                mainImage: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new RawMaterialButton(
                      onPressed: () => showThemeSelect(context, prefs),
                      child: new Icon(
                        Icons.color_lens,
                        size: 100,
                        color: theme.primaryColor,
                      ),
                      shape: new CircleBorder(),
                      fillColor: theme.backgroundColor,
                      padding: const EdgeInsets.all(30),
                    ),
                  ],
                ),
              ),
              PageViewModel(
                pageColor: Colors.blue,
                bubble: Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
                body: Text(
                  localizations.introGroupDescription,
                ),
                title: Text(
                  localizations.introGroupTitle,
                ),
                mainImage: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new RawMaterialButton(
                      onPressed: () => showSearchItemSelect(context, prefs),
                      child: new Icon(
                        Icons.search,
                        color: Colors.blue,
                        size: 100,
                      ),
                      shape: new CircleBorder(),
                      fillColor: Colors.white,
                      padding: const EdgeInsets.all(30),
                    ),
                  ],
                ),
              ),
            ],
            doneText: Container(),
            showSkipButton: false,
            pageButtonTextStyles: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          );
        },
      );
}
