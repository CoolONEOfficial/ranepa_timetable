import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/theme.dart';
import 'package:ranepa_timetable/timeline.dart';
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
          child: Container(
            height: 100,
            child: ShaderMask(
              shaderCallback: (Rect bounds) => LinearGradient(
                    begin: Alignment(0.0, 0),
                    end: Alignment(0.0, 1),
                    colors: <Color>[Colors.transparent, Colors.white],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds),
              child:
                  TimelineComponent(Timetable.generateRandomTimetable(ctx, 6)),
            ),
          ),
        ),
      );

  PageViewModel _buildWelcome() => PageViewModel(
        pageColor: Colors.black,
        bubble: Icon(
          Icons.school,
          color: Colors.black,
        ),
        body: AutoSizeText(localizations.introWelcomeDescription),
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
          child: _buildCircleButton(Icons.color_lens, onPressed: () async {
            if (await showThemeBrightnessSelect(ctx) != null)
              showMaterialColorPicker(ctx);
          }),
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

  RawMaterialButton _buildCircleButton(IconData icon,
          {VoidCallback onPressed}) =>
      RawMaterialButton(
        onPressed: onPressed,
        child: Icon(
          icon,
          color: backgroundColor,
          size: 100,
        ),
        shape: CircleBorder(),
        fillColor:
            theme.brightness == Brightness.light ? contentColor : accentColor,
        padding: const EdgeInsets.all(30),
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
              fontSize: 18.0,
            ),
          );
        },
      );
}
