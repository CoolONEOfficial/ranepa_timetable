import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/themes.dart';
import 'package:ranepa_timetable/timeline.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Intro extends StatelessWidget {
  final Widget base;
  final SharedPreferences prefs;

  const Intro({Key key, @required this.base, @required this.prefs})
      : super(key: key);

  PageViewModel _buildTimetable(BuildContext context, ThemeData theme,
          Color backgroundColor, AppLocalizations localizations) =>
      PageViewModel(
        pageColor: backgroundColor,
        bubble: Icon(
          Icons.list,
          color: backgroundColor,
        ),
        body: Text(localizations.introTimetableDescription),
        title: Text(
          localizations.introTimetableTitle,
          textAlign: TextAlign.center,
        ),
        mainImage: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15)
              .add(EdgeInsets.only(top: 30)),
          child: Container(
            height: 100,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment(0.0, 0),
                  end: Alignment(0.0, 1),
                  colors: <Color>[Colors.transparent, Colors.white],
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              child: TimelineComponent(
                <TimelineModel>[
                  TimelineModel(
                    first: true,
                    mergeBottom: true,
                    date: new DateTime(2018, 9),
                    start: TimeOfDay(hour: 8, minute: 0),
                    finish: TimeOfDay(hour: 9, minute: 30),
                    room: RoomModel("24", RoomLocation.Hotel),
                    group: "Иб-021",
                    lesson: Lessons(context)
                        .lessons[LessonIds.physicalCulture.index],
                    teacher: TeacherModel("Дмитрий", "Киселев", "Михайлович"),
                    user: TimelineUser.Student,
                  ),
                  TimelineModel(
                    mergeTop: true,
                    date: new DateTime(2018, 9),
                    start: TimeOfDay(hour: 8, minute: 0),
                    finish: TimeOfDay(hour: 9, minute: 30),
                    room: RoomModel("24", RoomLocation.Hotel),
                    group: "Иб-021",
                    lesson: Lessons(context)
                        .lessons[LessonIds.physicalCulture.index],
                    teacher: TeacherModel("Шамин", "Иван", "Александрович"),
                    user: TimelineUser.Student,
                  ),
                  TimelineModel(
                    date: new DateTime(2018, 9),
                    start: TimeOfDay(hour: 9, minute: 40),
                    finish: TimeOfDay(hour: 11, minute: 10),
                    room: RoomModel("109a", RoomLocation.Academy),
                    group: "Иб-021",
                    lesson: Lessons(context).lessons[LessonIds.ethics.index],
                    teacher: TeacherModel("Вера", "Дряхлова", "Рачиковна"),
                    user: TimelineUser.Student,
                  ),
                  TimelineModel(
                    date: new DateTime(2018, 9),
                    start: TimeOfDay(hour: 11, minute: 20),
                    finish: TimeOfDay(hour: 12, minute: 50),
                    room: RoomModel("109", RoomLocation.Academy),
                    group: "Иб-021",
                    lesson: Lessons(context).lessons[LessonIds.economics.index],
                    teacher: TeacherModel("Александр", "Гришин", "Юрьевич"),
                    user: TimelineUser.Student,
                  ),
                  TimelineModel(
                    date: new DateTime(2018, 9),
                    start: TimeOfDay(hour: 11, minute: 20),
                    finish: TimeOfDay(hour: 12, minute: 50),
                    room: RoomModel("407", RoomLocation.Academy),
                    group: "Иб-021",
                    lesson: Lessons(context).lessons[LessonIds.history.index],
                    teacher: TeacherModel("Егоров", "Вадим", "Валерьевич"),
                    user: TimelineUser.Student,
                  ),
                  TimelineModel(
                    date: new DateTime(2018, 9),
                    start: TimeOfDay(hour: 13, minute: 20),
                    finish: TimeOfDay(hour: 14, minute: 50),
                    room: RoomModel("302", RoomLocation.Academy),
                    group: "Иб-021",
                    lesson:
                        Lessons(context).lessons[LessonIds.lifeSafety.index],
                    teacher: TeacherModel("Обносова", "Нина", "Юрьевна"),
                    user: TimelineUser.Student,
                    last: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  PageViewModel _buildWelcome(ThemeData theme, Color backgroundColor,
          AppLocalizations localizations) =>
      PageViewModel(
        pageColor: backgroundColor,
        bubble: Padding(
          padding: const EdgeInsets.all(4.0),
          child: WidgetTemplates.buildLogo(theme, color: backgroundColor),
        ),
        body: Text(localizations.introWelcomeDescription),
        title: Text(
          localizations.introWelcomeTitle,
          textAlign: TextAlign.center,
        ),
        mainImage: WidgetTemplates.buildLogo(theme),
      );

  PageViewModel _buildTheme(BuildContext context, ThemeData theme,
          Color backgroundColor, int themeId, AppLocalizations localizations) =>
      PageViewModel(
        pageColor: backgroundColor,
        bubble: Icon(
          Icons.color_lens,
          color: backgroundColor,
        ),
        body: Text(localizations.introThemeDescription),
        title: Text(
          localizations.introThemeTitle,
          textAlign: TextAlign.center,
        ),
        mainImage: Align(
          alignment: Alignment.bottomCenter,
          child: RawMaterialButton(
            onPressed: () => showThemeSelect(context, prefs),
            child: Icon(
              Icons.color_lens,
              size: 100,
              color: backgroundColor,
            ),
            shape: CircleBorder(),
            fillColor: theme.brightness == Brightness.light
                ? theme.backgroundColor
                : theme.accentColor,
            padding: const EdgeInsets.all(30),
          ),
        ),
      );

  PageViewModel _buildSearch(BuildContext context, ThemeData theme,
          Color backgroundColor, int themeId, AppLocalizations localizations) =>
      PageViewModel(
        pageColor: backgroundColor,
        bubble: Icon(
          Icons.search,
          color: backgroundColor,
        ),
        body: Text(
          localizations.introGroupDescription,
        ),
        title: Text(
          localizations.introGroupTitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 40),
        ),
        mainImage: Align(
          alignment: Alignment.bottomCenter,
          child: RawMaterialButton(
            onPressed: () => showSearchItemSelect(context, prefs),
            child: Icon(
              Icons.search,
              color: backgroundColor,
              size: 100,
            ),
            shape: CircleBorder(),
            fillColor: theme.brightness == Brightness.light
                ? theme.backgroundColor
                : theme.accentColor,
            padding: const EdgeInsets.all(30),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        stream: themeIdBloc.stream,
        initialData:
            prefs.getInt(PrefsIds.THEME_ID) ?? Themes.DEFAULT_THEME_ID.index,
        builder: (context, snapshot) {
          final theme = Themes().themes[snapshot.data],
              localizations = AppLocalizations.of(context);
          final backgroundColor = theme.brightness == Brightness.light
              ? theme.primaryColor
              : theme.canvasColor;

          return IntroViewsFlutter(
            [
              _buildWelcome(theme, backgroundColor, localizations),
              _buildTheme(context, theme, backgroundColor, snapshot.data,
                  localizations),
              _buildTimetable(context, theme, backgroundColor, localizations),
              _buildSearch(context, theme, backgroundColor, snapshot.data,
                  localizations),
            ],
            doneText: Container(),
            showSkipButton: false,
            pageButtonTextStyles: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          );
        },
      );
}
