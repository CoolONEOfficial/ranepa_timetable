import 'package:flutter/material.dart';
import 'package:ranepa_timetable/localizations.dart';

class ThemeTitles {
  static ThemeTitles _singleton;

  factory ThemeTitles(BuildContext context) {
    if (_singleton == null) _singleton = ThemeTitles._internal(context);
    return _singleton;
  }

  final List<String> titles;

  ThemeTitles._internal(BuildContext context)
      : titles = <String>[
          // LIGHT
          AppLocalizations.of(context).themeLight,

          // LIGHT_RED
          AppLocalizations.of(context).themeLightRed,

          // DARK
          AppLocalizations.of(context).themeDark,

          // DARK_RED
          AppLocalizations.of(context).themeDarkRed,
        ];
}

class Themes {
  static Themes _singleton;

  static MaterialColor redAccent = Colors.red;

  factory Themes() {
    if (_singleton == null) _singleton = Themes._internal();
    return _singleton;
  }

  Themes._internal()
      : themes = <ThemeData>[
          // LIGHT
          ThemeData(
            brightness: Brightness.light,
          ),

          // LIGHT_RED
          ThemeData(
            brightness: Brightness.light,
            primarySwatch: redAccent,
          ),

          // DARK
          ThemeData(
            brightness: Brightness.dark,
          ),

          // DARK_RED
          ThemeData(
            brightness: Brightness.dark,
            primaryColor: redAccent,
            primaryColorDark: redAccent.shade700,
            toggleableActiveColor: redAccent.shade600,
            accentColor: redAccent.shade500,
          ),
        ];

  final List<ThemeData> themes;
}

enum ThemeIds { LIGHT, LIGHT_RED, DARK, DARK_RED }
