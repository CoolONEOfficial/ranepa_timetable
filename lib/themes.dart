import 'package:flutter/material.dart';
import 'package:ranepa_timetable/localizations.dart';

class Themes {
  static Themes _singleton;

  static Color redAccent = Color(0xaf120b);

  factory Themes(BuildContext context) {
    if (_singleton == null) _singleton = Themes._internal(context);
    return _singleton;
  }

  Themes._internal(this.context)
      : themes = <ThemeModel>[
    ThemeModel(
      // LIGHT
      AppLocalizations
          .of(context)
          .themeLight,
      ThemeData(
        brightness: Brightness.light,
      ),
    ),
    ThemeModel(
      // LIGHT_RED
      AppLocalizations
          .of(context)
          .themeLight,
      ThemeData(
          brightness: Brightness.light,
          accentColor: redAccent,
      ),
    ),
    ThemeModel(
      // DARK
      AppLocalizations
          .of(context)
          .themeLight,
      ThemeData(
        brightness: Brightness.dark,
      ),
    ),
    ThemeModel(
      // DARK_RED
      AppLocalizations
          .of(context)
          .themeLight,
      ThemeData(
        brightness: Brightness.dark,
        accentColor: redAccent,
      ),
    ),
  ];

  final BuildContext context;

  List<ThemeModel> themes;
}

enum ThemeIds { LIGHT, LIGHT_RED, DARK, DARK_RED }

class ThemeModel {
  final String title;
  final ThemeData data;

  ThemeModel(this.title, this.data);
}
