import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ranepatimetable/localizations.dart';
import 'package:ranepatimetable/main.dart';
import 'package:ranepatimetable/platform_channels.dart';
import 'package:ranepatimetable/prefs.dart';

ThemeData? _theme = ThemeData();

ThemeData getTheme() {
  if (_theme == null) _theme = buildTheme(brightness, accentColor!);
  return ThemeData();
}

ThemeData buildTheme(
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
      hintColor: accentColor.shade500,
    );

Future<void> onThemeChange() async {
  _theme = null;

  var theme = getTheme();
  themeBloc.sink.add(theme);

  debugPrint("Writing theme to prefs...");

  await prefs.setString(
      PrefsIds.THEME_PRIMARY, _colorToHex(theme.primaryColor));

  await prefs.setString(PrefsIds.THEME_ACCENT, _colorToHex(theme.colorScheme.secondary));

  await prefs.setString(
      PrefsIds.THEME_BACKGROUND, _colorToHex(theme.backgroundColor));

  await prefs.setString(
      PrefsIds.THEME_TEXT_PRIMARY, _colorToHex(theme.textTheme.bodyLarge?.color ?? Colors.white));

  await prefs.setString(PrefsIds.THEME_TEXT_ACCENT,
      _colorToHex(theme.textTheme.bodyLarge?.color ?? Colors.white));

  await prefs.setInt(PrefsIds.THEME_BRIGHTNESS, theme.brightness.index);

  await PlatformChannels.refreshWidget();
}

// Reactive bloc

final themeBloc = StreamController<ThemeData>.broadcast();

ThemeData get defaultTheme =>
    WidgetsBinding.instance.window.platformBrightness == Brightness.light
        ? ThemeData.light()
        : ThemeData.dark();

StreamBuilder<ThemeData> buildThemeStream(
        AsyncWidgetBuilder<ThemeData> builder) =>
    StreamBuilder<ThemeData>(
      stream: themeBloc.stream,
      initialData: getTheme(),
      builder: builder,
    );

// Brightness

Brightness? _brightness;

get brightness {
  if (Platform.isIOS)
    return WidgetsBinding.instance.window.platformBrightness;
  else
    return _brightness != null
        ? _brightness
        : Brightness.values[prefs.getInt(PrefsIds.THEME_BRIGHTNESS) ??
            defaultTheme.brightness.index];
}

set brightness(value) {
  _brightness = value;
  onThemeChange();
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

MaterialColor? _accentColor;

MaterialColor? get accentColor {
  final prefColor = prefs.getString(PrefsIds.THEME_PRIMARY);

  return _accentColor != null
      ? _accentColor
      : prefColor != null
          ? _toMaterialColor(_hexToColor(prefColor))
          : _toMaterialColor(ThemeData.light().primaryColor);
}

set accentColor(value) {
  _accentColor = value;
  onThemeChange();
}

// Theme brightness titles

class ThemeBrightnessTitles {
  static ThemeBrightnessTitles? _singleton;

  factory ThemeBrightnessTitles(BuildContext ctx) {
    return _singleton ?? ThemeBrightnessTitles._internal(ctx);
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
