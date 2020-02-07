import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:ranepa_timetable/about.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/theme.dart';
import 'package:ranepa_timetable/timeline.dart';
import 'package:ranepa_timetable/timetable.dart';
import 'package:ranepa_timetable/widget_templates.dart';

class IntroScreen extends StatelessWidget {
  static const ROUTE = "/intro";

  IntroScreen({Key key}) : super(key: key);

  PageViewModel _buildTimetable(BuildContext ctx) => PageViewModel(
        bubbleBackgroundColor: contentColor,
        pageColor: iosDarkMode ? Colors.black : backgroundColor,
        bubble: Icon(
          Icons.list,
          color: backgroundColor,
        ),
        body: _buildBodyText(localizations.introTimetableDescription),
        title: _buildTitleText(localizations.introTimetableTitle),
        mainImage: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15)
              .add(EdgeInsets.only(top: 30)),
          child: TimelineComponent(
            TimetableScreen.generateRandomTimetable(ctx, 6),
          ),
        ),
      );

  static Widget buildWelcomeTextList(
    AppLocalizations localizations,
    TextTheme textTheme, {
    Orientation orientation,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          orientation == Orientation.landscape
              ? Expanded
              : Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      localizations.introWelcomeDescription,
                      style: textTheme.body1.merge(
                        TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          Container(height: 8),
          GestureDetector(
            child: Text(
              localizations.introWelcomeSupportBy,
              textAlign: TextAlign.center,
              style: textTheme.caption.merge(
                TextStyle(
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
            onTap: () =>
                AboutScreen.openUrl('https://vk.com/profcomniu_online'),
          ),
        ],
      );

  get iosDarkMode => Platform.isIOS && getTheme().brightness == Brightness.dark;

  PageViewModel _buildWelcome() => PageViewModel(
        bubbleBackgroundColor: contentColor,
        pageColor: iosDarkMode ? Colors.black : backgroundColor,
        bubble: Icon(
          Icons.school,
          color: backgroundColor,
        ),
        body: buildWelcomeTextList(
          localizations,
          TextTheme(
            body1: TextStyle(color: Colors.white),
            caption: TextStyle(color: Colors.grey),
          ),
        ),
        title: _buildTitleText(localizations.introWelcomeTitle),
        mainImage: WidgetTemplates.buildLogo(theme),
      );

  PageViewModel _buildTheme(BuildContext ctx) => PageViewModel(
        bubbleBackgroundColor: contentColor,
        pageColor: iosDarkMode ? Colors.black : backgroundColor,
        bubble: Icon(
          Icons.color_lens,
          color: backgroundColor,
        ),
        body: _buildBodyText(localizations.introThemeDescription),
        title: _buildTitleText(localizations.introThemeTitle),
        mainImage: Align(
          alignment: Alignment.center,
          child: _buildCircleButton(
            Icons.color_lens,
            onPressed: () async {
              if ((Platform.isAndroid &&
                      await showThemeBrightnessSelect(ctx) != null) ||
                  Platform.isIOS) showMaterialColorPicker(ctx);
            },
          ),
        ),
      );

  PageViewModel _buildSearch(BuildContext ctx) => PageViewModel(
        bubbleBackgroundColor: contentColor,
        pageColor: iosDarkMode ? Colors.black : backgroundColor,
        bubble: Icon(
          PlatformIcons(ctx).search,
          color: backgroundColor,
        ),
        body: _buildBodyText(
          localizations.introGroupDescription,
        ),
        title: _buildTitleText(localizations.introGroupTitle),
        mainImage: Align(
          alignment: Alignment.center,
          child: _buildCircleButton(
            PlatformIcons(ctx).search,
            onPressed: () => showSearchItemSelect(ctx),
          ),
        ),
      );

  AutoSizeText _buildTitleText(String text) => AutoSizeText(
        text,
        style: TextStyle(color: contentColor),
        maxFontSize: 40,
        textAlign: TextAlign.center,
      );

  AutoSizeText _buildBodyText(String text) => AutoSizeText(
        text,
        style: TextStyle(color: contentColor),
      );

  RawMaterialButton _buildCircleButton(
    IconData icon, {
    double size = 100,
    VoidCallback onPressed,
    bool enabled = true,
  }) =>
      RawMaterialButton(
        onPressed: onPressed,
        child: Icon(
          icon,
          color: backgroundColor,
          size: size,
        ),
        shape: CircleBorder(),
        fillColor: enabled
            ? theme.brightness == Brightness.light ? contentColor : accentColor
            : Colors.grey,
        padding: EdgeInsets.all(size / 3),
      );

  ThemeData theme;
  Color backgroundColor;
  Color contentColor;
  AppLocalizations localizations;

  @override
  Widget build(BuildContext ctx) => buildThemeStream(
        (ctx, snapshot) {
          theme = getTheme();
          localizations = AppLocalizations.of(ctx);
          backgroundColor = theme.brightness == Brightness.light
              ? theme.primaryColor
              : theme.canvasColor;
          contentColor = (theme.brightness == Brightness.light
                  ? theme.accentTextTheme
                  : theme.textTheme)
              .body1
              .color;

          return IntroViewsFlutter(
            [
              _buildWelcome(),
              _buildTheme(ctx),
              _buildTimetable(ctx),
              _buildSearch(ctx),
            ],
            doneText: Container(),
            showSkipButton: false,
            pageButtonTextStyles: TextStyle(
              color: contentColor,
              fontSize: ScreenUtil().setSp(18),
            ),
          );
        },
      );
}
