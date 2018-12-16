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
  static Themes _singleton;

  static MaterialColor redAccent =
  MaterialColor(
  0xFF982825,
    <int, Color>{
      50: Color(0xf2cbca),
      100: Color(0xFFe8a3a1),
      200: Color(0xFFde7a78),
      300: Color(0xFFd4524f),
      400: Color(0xFFc1332f),
      500: Color(0xFF982825),
      600: Color(0xFF8a2422),
      700: Color(0xFF7d211e),
      800: Color(0xFF6f1d1b),
      900: Color(0xFF611a18),
    },
  );
  static const DEFAULT_THEME_ID = ThemeIds.LIGHT_RED;

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
            toggleableActiveColor: redAccent.shade600,
            accentColor: redAccent.shade500,
          ),
        ];

  final List<ThemeData> themes;
}
