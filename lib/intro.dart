import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:ranepa_timetable/about.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/theme.dart';
import 'package:ranepa_timetable/timeline.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/timetable.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Intro extends StatelessWidget {
  final Widget base;

  Intro({
    Key key,
    @required this.base,
  }) : super(key: key);

  PageViewModel _buildTimetable(BuildContext ctx) => PageViewModel(
        bubbleBackgroundColor: contentColor,
        pageColor: backgroundColor,
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
            Timetable.generateRandomTimetable(ctx, 6),
          ),
        ),
      );

  static Widget buildWelcomeTextList(
    AppLocalizations localizations,
    TextTheme textTheme, {
    Orientation orientation,
  }) =>
      Column(
        mainAxisSize: orientation == Orientation.landscape
            ? MainAxisSize.max
            : MainAxisSize.max,
        mainAxisAlignment: orientation == Orientation.landscape
            ? MainAxisAlignment.center
            : MainAxisAlignment.center,
        crossAxisAlignment: orientation == Orientation.landscape
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.center,
        children: <Widget>[
          orientation == Orientation.landscape
              ? Expanded
              : Flexible(
                  child: SingleChildScrollView(
                    child: AutoSizeText(
                      localizations.introWelcomeDescription,
                      style:
                          textTheme.body1.merge(TextStyle(color: Colors.white)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          Container(height: 8),
          InkWell(
            child: Text(
              localizations.introWelcomeSupportBy,
              textAlign: TextAlign.center,
              style: textTheme.caption.merge(
                TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            ),
            onTap: () => HomeScreen.openUrl('https://vk.com/profcomniu_online'),
          ),
        ],
      );

  PageViewModel _buildWelcome() => PageViewModel(
        pageColor: Colors.black,
        bubble: Icon(
          Icons.school,
          color: Colors.black,
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
        pageColor: backgroundColor,
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
              if (await showThemeBrightnessSelect(ctx) != null)
                showMaterialColorPicker(ctx);
            },
          ),
        ),
      );

  PageViewModel _buildSearch(BuildContext ctx) => PageViewModel(
        bubbleBackgroundColor: contentColor,
        pageColor: backgroundColor,
        bubble: Icon(
          Icons.search,
          color: backgroundColor,
        ),
        body: _buildBodyText(
          localizations.introGroupDescription,
        ),
        title: _buildTitleText(localizations.introGroupTitle),
        mainImage: Align(
          alignment: Alignment.center,
          child: _buildCircleButton(
            Icons.search,
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
          theme = buildTheme();
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
