import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData buildTheme() => _buildTheme(_brightness, _accentColor);

ThemeData _buildTheme(
  Brightness brightness,
  MaterialColor accentColor,
) =>
    ThemeData(
        brightness: brightness,
        primarySwatch: accentColor,
        toggleableActiveColor: accentColor.shade600,
        accentColor: accentColor.shade500);

void _onThemeChange() async {
  var theme = buildTheme();
  themeBloc.sink.add(theme);

  var prefs = await SharedPreferences.getInstance();

  await prefs.setString(PrefsIds.THEME_ACCENT, theme.accentColor.toString());

  await prefs.setString(PrefsIds.THEME_PRIMARY, theme.primaryColor.toString());

  await prefs.setString(
      PrefsIds.THEME_BACKGROUND, theme.backgroundColor.toString());

  await prefs.setString(
      PrefsIds.THEME_TEXT_ACCENT, theme.accentTextTheme.title.color.toString());

  await prefs.setString(PrefsIds.THEME_TEXT_PRIMARY,
      theme.primaryTextTheme.title.color.toString());

  PlatformChannels.refreshWidget();
}

// Reactive bloc

final themeBloc = StreamController<ThemeData>.broadcast();

StreamBuilder<ThemeData> buildThemeStream(
    AsyncWidgetBuilder<ThemeData> builder) =>
    StreamBuilder<ThemeData>(
      stream: themeBloc.stream,
      initialData: buildTheme(),
      builder: builder,
    );

// Brightness

Brightness _brightness = Brightness.light;

get brightness => _brightness;

set brightness(value) {
  _brightness = value;
  _onThemeChange();
}

// Accent color

MaterialColor _accentColor = Colors.blue;

get accentColor => _accentColor;

set accentColor(value) {
  _accentColor = value;
  _onThemeChange();
}

// Theme brightness titles

class ThemeBrightnessTitles {
  static ThemeBrightnessTitles _singleton;

  factory ThemeBrightnessTitles(BuildContext ctx) {
    if (_singleton == null)
      _singleton = ThemeBrightnessTitles._internal(ctx);
    return _singleton;
  }

  final List<String> titles;

  ThemeBrightnessTitles._internal(BuildContext ctx)
      : titles = <String>[
          // DARK
          AppLocalizations.of(ctx).themeDark,

          // LIGHT
          AppLocalizations.of(ctx).themeLight,
        ];
}
