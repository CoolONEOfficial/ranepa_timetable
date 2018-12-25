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

enum ThemeIds { LIGHT, LIGHT_RED, DARK, DARK_RED }

class Themes {
  static const redAccentValue = 0xFFF44336;//0xFF982825;
  static MaterialColor redAccent =
  MaterialColor(
    redAccentValue,
    <int, Color>{
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(redAccentValue),
      600: Color(0xFFE53935),
      700: Color(0xFFD32F2F),
      800: Color(0xFFC62828),
      900: Color(0xFFB71C1C),
    },
  );
  static const DEFAULT_THEME_ID = ThemeIds.LIGHT_RED;

  static final List<ThemeData> themes = <ThemeData>[
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
      toggleableActiveColor: redAccent.shade600,
      accentColor: redAccent.shade500,
    ),
  ];
}
