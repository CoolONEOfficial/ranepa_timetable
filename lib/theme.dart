import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/prefs.dart';

ThemeData buildTheme() => _buildTheme(brightness, accentColor);

ThemeData _buildTheme(
  Brightness brightness,
  MaterialColor accentColor,
) =>
    ThemeData(
        brightness: brightness,
        primarySwatch: accentColor,
        primaryColor: accentColor,
        primaryColorLight: accentColor.shade100,
        primaryColorDark: accentColor.shade700,
        toggleableActiveColor: accentColor.shade600,
        accentColor: accentColor.shade500);

void _onThemeChange() async {
  var theme = buildTheme();
  themeBloc.sink.add(theme);

  debugPrint("Writing theme to prefs...");

  await prefs.setString(
      PrefsIds.THEME_PRIMARY, _colorToHex(theme.primaryColor));

  await prefs.setString(PrefsIds.THEME_ACCENT, _colorToHex(theme.accentColor));

  await prefs.setString(
      PrefsIds.THEME_BACKGROUND, _colorToHex(theme.backgroundColor));

  await prefs.setString(
      PrefsIds.THEME_TEXT_PRIMARY, _colorToHex(theme.textTheme.body1.color));

  await prefs.setString(PrefsIds.THEME_TEXT_ACCENT,
      _colorToHex(theme.accentTextTheme.body1.color));

  await prefs.setInt(PrefsIds.THEME_BRIGHTNESS, theme.brightness.index);

  PlatformChannels.refreshWidget();
}

// Reactive bloc

final themeBloc = StreamController<ThemeData>.broadcast();

final defaultTheme = ThemeData.light();

StreamBuilder<ThemeData> buildThemeStream(
        AsyncWidgetBuilder<ThemeData> builder) =>
    StreamBuilder<ThemeData>(
      stream: themeBloc.stream,
      initialData: buildTheme(),
      builder: builder,
    );

// Brightness

Brightness _brightness;

get brightness => _brightness != null
    ? _brightness
    : Brightness.values[prefs.getInt(PrefsIds.THEME_BRIGHTNESS) ?? 0];

set brightness(value) {
  _brightness = value;
  _onThemeChange();
}

// Accent color

String _colorToHex(Color color) => color.value.toRadixString(16);

Color _hexToColor(String hex) => Color(int.parse(hex, radix: 16));

MaterialColor _toMaterialColor(Color color) {
  for (var mColor in List<MaterialColor>.of(Colors.primaries)
    ..add(Colors.grey)) {
    if (mColor.value == color.value) return mColor;
  }
  throw Exception('Material color ${color.toString()} not found!!!');
}

MaterialColor _accentColor;

get accentColor {
  var prefColor = prefs.getString(PrefsIds.THEME_PRIMARY);

  return _accentColor != null
      ? _accentColor
      : prefColor != null
          ? _toMaterialColor(_hexToColor(prefColor))
          : defaultTheme.primaryColor;
}

set accentColor(value) {
  _accentColor = value;
  _onThemeChange();
}

// Theme brightness titles

class ThemeBrightnessTitles {
  static ThemeBrightnessTitles _singleton;

  factory ThemeBrightnessTitles(BuildContext ctx) {
    if (_singleton == null) _singleton = ThemeBrightnessTitles._internal(ctx);
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
