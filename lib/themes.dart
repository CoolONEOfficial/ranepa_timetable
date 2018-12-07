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

  static Color redAccent = Color(0xffaf120b);

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
            accentColor: redAccent,
            primaryColor: redAccent,
          ),

          // DARK
          ThemeData(
            brightness: Brightness.dark,
          ),

          // DARK_RED
          ThemeData(
            brightness: Brightness.dark,
            accentColor: redAccent,
            primaryColor: redAccent,
          ),
        ];

  final themes;
}

enum ThemeIds { LIGHT, LIGHT_RED, DARK, DARK_RED }
