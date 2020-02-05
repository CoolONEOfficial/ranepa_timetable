import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:android_intent/android_intent.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ranepa_timetable/about.dart';
import 'package:ranepa_timetable/apis.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/theme.dart';
import 'package:ranepa_timetable/timeline.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/timetable_icons.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class TimetableScreen extends StatefulWidget {
  static const ROUTE = "/timetable";

  static SearchItem selected;

  static final LinkedHashMap<DateTime, List<TimelineModel>> timetable =
      LinkedHashMap<DateTime, List<TimelineModel>>();

  TimetableScreen({
    Key key,
  })  : _deviceCalendarPlugin = DeviceCalendarPlugin(),
        super(key: key);

  static DateTime _toDateTime(TimeOfDay tod, [DateTime dt]) {
    dt ??= DateTime.now();
    return DateTime(dt.year, dt.month, dt.day, tod.hour, tod.minute);
  }

  static TimeOfDay _toTimeOfDay([DateTime dt]) {
    dt ??= DateTime.now();
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  static T _randomElement<T>(List<T> arr) => arr[random.nextInt(arr.length)];

  static List<TimelineModel> generateRandomTimetable(
    BuildContext ctx,
    int length,
  ) =>
      List<TimelineModel>.generate(
        length,
        (index) {
          final startTime = _toTimeOfDay(
            _toDateTime(TimeOfDay(hour: 8, minute: 0))
                .add(Duration(hours: 1, minutes: 40) * index),
          );
          return TimelineModel(
              date: todayMidnight,
              start: startTime,
              finish: _toTimeOfDay(
                _toDateTime(startTime).add(Duration(hours: 1, minutes: 30)),
              ),
              group: "Иб-021",
              room: RoomModel(
                random.nextInt(999).toString(),
                _randomElement(RoomLocation.values),
              ),
              lesson: generateRandomLesson(ctx),
              teacher: TeacherModel(
                _randomElement(["Вася", "Петя", "Никита"]),
                _randomElement(["Картошкин", "Инютин", "Егоров"]),
                _randomElement(["Александрович", "Валерьевич", "Михайлович"]),
              ));
        },
      );

  static const dayCount = 6;

  static DateTime fromDay = todayMidnight;

  static DateTime get endCacheMidnight {
    var mDate = todayMidnight.add(Duration(days: dayCount - 1));

    if (mDate.weekday == DateTime.sunday) mDate = mDate.add(Duration(days: 1));
    return mDate;
  }

  static Future<void> _loadAllTimetable(
    BuildContext ctx,
    SearchItem searchItem, {
    bool updateDb = true,
  }) {
    debugPrint("Loading all timetable.. ${searchItem.title}");

    timetable.clear();
    return loadTimetable(
      ctx,
      fromDay,
      fromDay.add(Duration(days: dayCount - 1)),
      searchItem,
      updateDb,
    );
  }

  static Future<void> _getTimetable(
    BuildContext ctx,
    SearchItem searchItem,
    SharedPreferences prefs,
  ) async {
    debugPrint("started get timetable");

    final dbTimetable = await PlatformChannels.getDb();
    final today = TimetableScreen.todayMidnight;

    if (dbTimetable == null)
      await _loadAllTimetable(ctx, searchItem);
    else {
      timetable.clear();
      timetable.addAll(dbTimetable);

      final endCache = DateTime.parse(prefs.getString(PrefsIds.END_CACHE));
      if (endCache.compareTo(endCacheMidnight) != 0) {
        await loadTimetable(
          ctx,
          endCache,
          today.add(Duration(days: dayCount - 1)),
          searchItem,
        );
      }
    }

    debugPrint("ended get timetable");
  }

  static String formatDateTime(DateTime dt) =>
      "${dt.day}.${dt.month}.${dt.year}";

  static Future<void> loadTimetable(
    BuildContext ctx,
    DateTime from,
    DateTime to,
    SearchItem searchItem, [
    bool updateDb = true,
  ]) async {
    if (!await WidgetTemplates.checkInternetConnection()) return;

    final api = SiteApiIds
        .values[prefs.getInt(PrefsIds.SITE_API) ?? DEFAULT_API_ID.index];

    debugPrint("Started load timetable via API №${api.index}");

    var resp;

    switch (api) {
      case SiteApiIds.APP_NEW:
        resp = await http.get('http://services.niu.ranepa.ru/API/public/'
            '${searchItemTypes[searchItem.typeId.index].newApiStr}/${searchItem.id}'
            '/schedule/${formatDateTime(from)}/${formatDateTime(to.add(Duration(days: 1)))}');
        break;
      case SiteApiIds.APP_OLD:
        resp = await http.post('http://test.ranhigs-nn.ru/api/WebService.asmx',
            headers: {'Content-Type': 'text/xml; charset=utf-8'}, body: '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetRasp${searchItemTypes[searchItem.typeId.index].oldApiStr} xmlns="http://tempuri.org/">
      <d1>${from.toIso8601String()}</d1>
      <d2>${to.toIso8601String()}</d2>
      <id>${searchItem.id}</id>
    </GetRasp${searchItemTypes[searchItem.typeId.index].oldApiStr}>
  </soap:Body>
</soap:Envelope>
''');
        break;
      case SiteApiIds.SITE:
        resp = await http.get('http://services.niu.ranepa.ru/'
            'wp-content/plugins/rasp/rasp_json_data.php'
            '?user=${searchItem.title}'
            '&dstart=${formatDateTime(from)}'
            '&dfinish=${formatDateTime(to)}');
        break;
    }

    debugPrint("http load end. starting parse request..");

    var itemArr = parseResp(api, resp.body);

    var mDate = from.subtract(Duration(days: 1));
    final _startDayId = timetable.keys.length;
    for (var mItem in itemArr) {
      DateTime mItemDate;
      var mItemTimeStart;
      var mItemTimeFinish;
      String mItemTeacher;
      String mItemName;
      String mItemRoomStr;
      String mItemGroup;

      switch (api) {
        case SiteApiIds.APP_NEW:
          mItemDate = DateTime.parse(mItem["xdt"]);
          mItemTimeStart = mItem["nf"];
          mItemTimeFinish = mItem["kf"];
          mItemTeacher = searchItem.typeId == SearchItemTypeId.Group
              ? mItem["teacher"]
              : searchItem.title;
          mItemRoomStr = mItem["number"];
          mItemGroup = searchItem.typeId == SearchItemTypeId.Teacher
              ? mItem["group"]
              : searchItem.title;
          break;
        case SiteApiIds.APP_OLD:
          mItemDate = DateTime.parse(
              mItem.children[OldAppApiTimetableIndexes.Date.index].text);
          mItemTimeStart =
              mItem.children[OldAppApiTimetableIndexes.TimeStart.index].text;
          mItemTimeFinish =
              mItem.children[OldAppApiTimetableIndexes.TimeFinish.index].text;
          mItemName = mItem.children[OldAppApiTimetableIndexes.Name.index].text;
          mItemRoomStr =
              mItem.children[OldAppApiTimetableIndexes.Room.index].text;
          mItemGroup =
              mItem.children[OldAppApiTimetableIndexes.Group.index].text;

          break;
        case SiteApiIds.SITE:
          String mItemDateStr = mItem["date"];
          mItemDate = DateTime(
            int.parse(mItemDateStr.substring(6)),
            int.parse(mItemDateStr.substring(3, 5)),
            int.parse(mItemDateStr.substring(0, 2)),
          );
          mItemTimeStart = mItem["timestart"];
          mItemTimeFinish = mItem["timefinish"];
          mItemName = mItem["name"];
          mItemRoomStr = mItem["aydit"];
          mItemGroup = mItem["namegroup"];
          break;
      }

      String mItemSubject;
      String mItemType;

      switch (api) {
        case SiteApiIds.APP_NEW:
          mItemSubject = mItem["subject"];
          mItemType = mItem["type"];
          break;
        case SiteApiIds.SITE:
        case SiteApiIds.APP_OLD:
          mItemSubject = mItemName.substring(0, mItemName.indexOf('('));
          mItemType = RegExp(r"\(([^)]*)\)[^(]*$").stringMatch(mItemName);
          mItemType = mItemType.substring(1, mItemType.lastIndexOf(')'));
          mItemTeacher = mItemName.substring(mItemName.indexOf('>') + 1);
          break;
      }

      while (mDate != mItemDate) {
        mDate = mDate.add(Duration(days: 1));
        // skip sunday
        if (mDate.weekday != DateTime.sunday) {
          timetable[mDate] = List<TimelineModel>();
        }
      }

      final mLesson = TimelineModel(
        date: mItemDate,
        start: TimeOfDay(
            hour: int.parse(
                mItemTimeStart.substring(0, mItemTimeStart.length - 3)),
            minute: int.parse(mItemTimeStart.substring(
                mItemTimeStart.length - 2, mItemTimeStart.length))),
        finish: TimeOfDay(
            hour: int.parse(
                mItemTimeFinish.substring(0, mItemTimeFinish.length - 3)),
            minute: int.parse(mItemTimeFinish.substring(
                mItemTimeFinish.length - 2, mItemTimeFinish.length))),
        room: RoomModel.fromString(mItemRoomStr),
        group: mItemGroup,
        lesson: LessonModel.build(
          ctx,
          mItemSubject,
          mItemType,
          api,
        ),
        teacher: TeacherModel.fromString(
            searchItem.typeId == SearchItemTypeId.Group
                ? mItemTeacher
                : searchItem.title),
      );

      timetable[mItemDate].add(mLesson);
    }

    for (var mDay in timetable.values) {
      if (mDay.isEmpty) continue;

      mDay.first.first = true;
      mDay.last.last = true;

      for (var mItemId = 0; mItemId < mDay.length - 1; mItemId++) {
        final mItem = mDay[mItemId], mNextItem = mDay[mItemId + 1];

        if (mItem.start == mNextItem.start) {
          mItem.mergeBottom = true;
          mNextItem.mergeTop = true;
        } else {
          final diff = _toDateTime(mNextItem.start)
              .difference(_toDateTime(mItem.finish));

          debugPrint("mDiff: $diff");
          if (diff.inMinutes > 10) {
            mItem.last = true;
            mNextItem.first = true;
          }
        }
      }
    }

    debugPrint("parsing http requests end..");

    // Update db
    if (updateDb)
      await PlatformChannels.updateDb(
        timetable.values
            .toList()
            .sublist(
              _startDayId,
            )
            .expand(
              (f) => f,
            ),
      );

    // Save cache end
    prefs.setString(PrefsIds.END_CACHE, to.toIso8601String());

    // Refresh widget
    PlatformChannels.refreshWidget();
  }

  static DateTime _todayMidnight;

  static DateTime get todayMidnight {
    if (_todayMidnight == null) {
      // lazy
      var now = DateTime.now();
      _todayMidnight = DateTime(
          now.year,
          now.month,
          now.weekday == DateTime.sunday
              ? now.day + 1
              : now.day); // skip sunday
    }
    return _todayMidnight;
  }

  static DateTime get nextDayDate {
    final todayLastLesson = timetable[todayMidnight]?.last?.finish;
    if (todayLastLesson == null) return null;

    return _toDateTime(todayLastLesson).isBefore(DateTime.now())
        ? todayMidnight.add(Duration(days: 1))
        : todayMidnight;
  }

  static void _createAlarm(
    BuildContext ctx,
    SharedPreferences prefs,
  ) async {
    var beforeAlarmClockStr = prefs.getInt(PrefsIds.BEFORE_ALARM_CLOCK);
    if (beforeAlarmClockStr == null) {
      beforeAlarmClockStr =
          (await PrefsScreen.showBeforeAlarmClockSelect(ctx)).inMinutes;
    }
    final beforeAlarmClock = Duration(minutes: beforeAlarmClockStr);

    String snackBarText;
    IconData snackBarIcon = Icons.error_outline;

    final alarmLessonDate = nextDayDate;
    final alarmDay = timetable[alarmLessonDate];

    if (alarmDay?.isNotEmpty ?? false) {
      final alarmLesson = alarmDay.first;
      final alarmClock =
          _toDateTime(alarmLesson.start).subtract(beforeAlarmClock);

      await AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: <String, dynamic>{
          'android.intent.extra.alarm.HOUR': alarmClock.hour,
          'android.intent.extra.alarm.MINUTES': alarmClock.minute,
          'android.intent.extra.alarm.SKIP_UI': true,
          'android.intent.extra.alarm.MESSAGE': alarmLesson.lesson.title,
        },
      ).launch();

      snackBarIcon = Icons.done;
      snackBarText = AppLocalizations.of(ctx).alarmAddSuccess +
          TimeOfDay.fromDateTime(alarmClock).format(ctx);
    } else {
      snackBarText = AppLocalizations.of(ctx).noLessonsFound;
    }

    WidgetTemplates.buildFlushbar(
      ctx,
      snackBarText,
      iconData: snackBarIcon,
    )..show(ctx);
  }

  DeviceCalendarPlugin _deviceCalendarPlugin;

  static void _createCalendarEvents(
    BuildContext ctx,
    DeviceCalendarPlugin calPlugin,
  ) async {
    String snackBarText = AppLocalizations.of(ctx).calendarEventsAddFailed;
    IconData snackBarIcon = Icons.error_outline;

    // Get calendar permissions if required
    var permissionsGrantedResult = await calPlugin.hasPermissions();
    var permissionsGranted = permissionsGrantedResult.data ?? false;
    if (permissionsGrantedResult.isSuccess && !permissionsGranted) {
      permissionsGrantedResult = await calPlugin.requestPermissions();
      if (permissionsGrantedResult.isSuccess && permissionsGrantedResult.data)
        permissionsGranted = true;
    }

    if (permissionsGranted) {
      // Add calendar event
      final calendarArr = (await calPlugin.retrieveCalendars())?.data;
      if (calendarArr?.isNotEmpty ?? false) {
        final calendar = calendarArr.lastWhere((mCal) => !mCal.isReadOnly);

        final eventsDay = timetable[nextDayDate];

        if (eventsDay?.isNotEmpty ?? false) {
          for (var mLesson in eventsDay) {
            calPlugin.createOrUpdateEvent(
              Event(
                calendar.id,
                title: mLesson.lesson.title,
                description: mLesson.lesson.fullTitle,
                start: _toDateTime(mLesson.start, mLesson.date),
                end: _toDateTime(mLesson.finish, mLesson.date),
              ),
            );
          }
          snackBarIcon = Icons.done;
          snackBarText = AppLocalizations.of(ctx).calendarEventsAddSuccess;
        } else
          snackBarText = AppLocalizations.of(ctx).noLessonsFound;
      } else
        snackBarText = AppLocalizations.of(ctx).calendarGetFailed;
    }

    WidgetTemplates.buildFlushbar(
      ctx,
      snackBarText,
      iconData: snackBarIcon,
    )..show(ctx);

//    scaffoldKey.currentState.showSnackBar(
//      SnackBar(
//        content: Text(snackBarText),
//      ),
//    );
  }

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class CupertinoCustomNavigationBar extends StatelessWidget
    with ObstructingPreferredSizeWidget {
  const CupertinoCustomNavigationBar({
    Key key,
    this.backgroundColor,
    this.bottom,
    this.title,
    this.leading,
    this.trailing,
  });

  final Color backgroundColor;

  final Widget bottom;
  final Widget title;
  final Widget leading;
  final Widget trailing;

  @override
  Size get preferredSize => Size.fromHeight(44.0 + 80.0);

  @override
  Widget build(BuildContext ctx) {
    SystemUiOverlayStyle overlayStyle;
    switch (WidgetsBinding.instance.window.platformBrightness) {
      case Brightness.dark:
        overlayStyle = SystemUiOverlayStyle.light;
        break;
      case Brightness.light:
      default:
        overlayStyle = SystemUiOverlayStyle.dark;
        break;
    }
    return Column(
      children: <Widget>[
        CupertinoNavigationBar(
          middle: title,
          border: null,
          trailing: trailing,
          leading: leading,
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(ctx).barBackgroundColor,
              ),
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                sized: true,
                child: SizedBox(
                  width: double.infinity,
                  child: bottom,
                ),
              ),
            ),
          ),
        ),
        WidgetTemplates.buildDivider(),
      ],
    );
  }

  @override
  bool shouldFullyObstruct(BuildContext context) {
    final Color backgroundColor =
        CupertinoDynamicColor.resolve(this.backgroundColor, context) ??
            CupertinoTheme.of(context).barBackgroundColor;
    return backgroundColor.alpha == 0xFF;
  }
}

class CupertinoTabBar extends StatefulWidget {
  final TabController controller;

  final List titles;

  const CupertinoTabBar({
    Key key,
    this.controller,
    this.titles,
  }) : super(key: key);

  @override
  _CupertinoTabBarState createState() => _CupertinoTabBarState();
}

class _CupertinoTabBarState extends State<CupertinoTabBar>
    with TickerProviderStateMixin {
  // this will control the animation when a button changes from an off state to an on state
  AnimationController _animationControllerOn;

  // this will control the animation when a button changes from an on state to an off state
  AnimationController _animationControllerOff;

  // this will give the background color values of a button when it changes to an on state
  Animation _colorTweenBackgroundOn;
  Animation _colorTweenBackgroundOff;

  // this will give the foreground color values of a button when it changes to an on state
  Animation _colorTweenForegroundOn;
  Animation _colorTweenForegroundOff;

  // when swiping, the _controller.index value only changes after the animation, therefore, we need this to trigger the animations and save the current index
  int _currentIndex = 0;

  // saves the previous active tab
  int _prevControllerIndex = 0;

  // saves the value of the tab animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
  double _aniValue = 0.0;

  // saves the previous value of the tab animation. It's used to figure the direction of the animation
  double _prevAniValue = 0.0;

  get _foregroundOn => getTheme().accentIconTheme.color;

  Color get _foregroundOff {
    return getTheme().brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  // active button's background color
  get _backgroundOn => getTheme().accentColor;
  Color _backgroundOff = Colors.transparent;

  List _keys = [];

  // regist if the the button was tapped
  bool _buttonTap = false;

  @override
  void initState() {
    super.initState();

    for (int index = 0; index < widget.titles.length; index++) {
      // create a GlobalKey for each Tab
      _keys.add(GlobalKey());
    }

    // this will execute the function every time there's a swipe animation
    widget.controller.animation.addListener(_handleTabAnimation);
    // this will execute the function every time the _controller.index value changes
    widget.controller.addListener(_handleTabChange);

    _animationControllerOff =
        AnimationController(vsync: this, duration: Duration(milliseconds: 75));
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOff.value = 1.0;
    _colorTweenBackgroundOff =
        ColorTween(begin: _backgroundOn, end: _backgroundOff)
            .animate(_animationControllerOff);
    _colorTweenForegroundOff =
        ColorTween(begin: _foregroundOn, end: _foregroundOff)
            .animate(_animationControllerOff);

    _animationControllerOn =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOn.value = 1.0;
    _colorTweenBackgroundOn =
        ColorTween(begin: _backgroundOff, end: _backgroundOn)
            .animate(_animationControllerOn);
    _colorTweenForegroundOn =
        ColorTween(begin: _foregroundOff, end: _foregroundOn)
            .animate(_animationControllerOn);
  }

  @override
  Widget build(BuildContext ctx) => Container(
        height: 79.0,
        // this generates our tabs buttons
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.titles
                .asMap()
                .map((index, mTitle) {
                  return MapEntry(
                      index,
                      Padding(
                        // each button's key
                        key: _keys[index],
                        // padding for the buttons
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                getWeekdayTitle(ctx, mTitle)[0].toLowerCase(),
                                textScaleFactor: 0.8,
                                style: TextStyle(color: _foregroundOff),
                              ),
                            ),
                            Container(
                              width: 35,
                              height: 35,
                              child: ButtonTheme(
                                  child: AnimatedBuilder(
                                animation: _colorTweenBackgroundOn,
                                builder: (ctx, child) => RawMaterialButton(
                                    highlightElevation: 0,
                                    enableFeedback: false,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    elevation: 0,
                                    shape: CircleBorder(),
                                    // get the color of the button's background (dependent of its state)
                                    fillColor: _getBackgroundColor(index),
                                    onPressed: () {
                                      setState(() {
                                        _buttonTap = true;
                                        // trigger the controller to change between Tab Views
                                        widget.controller.animateTo(index);
                                        // set the current index
                                        _setCurrentIndex(index);
                                        // scroll to the tapped button
                                        _scrollTo(index);
                                      });
                                    },
                                    child: Text(
                                      mTitle.day.toString(),
                                      style: TextStyle(
                                        color: _getForegroundColor(index),
                                      ),
                                      textScaleFactor: 1.3,
                                    )),
                              )),
                            ),
                          ],
                        ),
                      ));
                })
                .values
                .toList()),
      );

  _handleTabAnimation() {
    // gets the value of the animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
    _aniValue = widget.controller.animation.value;

    // if the button wasn't pressed, which means the user is swiping, and the amount swipped is less than 1 (this means that we're swiping through neighbor Tab Views)
    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      // set the current tab index
      _setCurrentIndex(_aniValue.round());
    }

    // save the previous Animation Value
    _prevAniValue = _aniValue;
  }

  // runs when the displayed tab changes
  _handleTabChange() {
    // if a button was tapped, change the current index
    if (_buttonTap) _setCurrentIndex(widget.controller.index);

    // this resets the button tap
    if ((widget.controller.index == _prevControllerIndex) ||
        (widget.controller.index == _aniValue.round())) _buttonTap = false;

    // save the previous controller index
    _prevControllerIndex = widget.controller.index;
  }

  _setCurrentIndex(int index) {
    // if we're actually changing the index
    if (index != _currentIndex) {
      setState(() {
        // change the index
        _currentIndex = index;
      });

      // trigger the button animation
      _triggerAnimation();
      // scroll the TabBar to the correct position (if we have a scrollable bar)
      _scrollTo(index);
    }
  }

  _triggerAnimation() {
    // reset the animations so they're ready to go
    _animationControllerOn.reset();
    _animationControllerOff.reset();

    // run the animations!
    _animationControllerOn.forward();
    _animationControllerOff.forward();
  }

  _scrollTo(int index) {
    // get the screen width. This is used to check if we have an element off screen
    double screenWidth = MediaQuery.of(context).size.width;

    // get the button we want to scroll to
    RenderBox renderBox = _keys[index].currentContext.findRenderObject();
    // get its size
    double size = renderBox.size.width;
    // and position
    double position = renderBox.localToGlobal(Offset.zero).dx;

    // this is how much the button is away from the center of the screen and how much we must scroll to get it into place
    double offset = (position + size / 2) - screenWidth / 2;

    // if the button is to the left of the middle
    if (offset < 0) {
      // get the first button
      renderBox = _keys[0].currentContext.findRenderObject();
      // get the position of the first button of the TabBar
      position = renderBox.localToGlobal(Offset.zero).dx;

      // if the offset pulls the first button away from the left side, we limit that movement so the first button is stuck to the left side
      if (position > offset) offset = position;
    } else {
      // if the button is to the right of the middle

      // get the last button
      renderBox =
          _keys[widget.titles.length - 1].currentContext.findRenderObject();
      // get its position
      position = renderBox.localToGlobal(Offset.zero).dx;
      // and size
      size = renderBox.size.width;

      // if the last button doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
      if (position + size < screenWidth) screenWidth = position + size;

      // if the offset pulls the last button away from the right side limit, we reduce that movement so the last button is stuck to the right side limit
      if (position + size - offset < screenWidth) {
        offset = position + size - screenWidth;
      }
    }
  }

  _getBackgroundColor(int index) {
    if (index == _currentIndex) {
      // if it's active button
      return _colorTweenBackgroundOn.value;
    } else if (index == _prevControllerIndex) {
      // if it's the previous active button
      return _colorTweenBackgroundOff.value;
    } else {
      // if the button is inactive
      return _backgroundOff;
    }
  }

  _getForegroundColor(int index) {
    // the same as the above
    if (index == _currentIndex) {
      return _colorTweenForegroundOn.value;
    } else if (index == _prevControllerIndex) {
      return _colorTweenForegroundOff.value;
    } else {
      return _foregroundOff;
    }
  }
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      vsync: this,
      length: TimetableScreen.dayCount,
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget appBarTitle(searchItem) =>
      Text(searchItem.data.item2.typeId == SearchItemTypeId.Teacher
          ? TeacherModel.fromString(searchItem.data.item2.title).initials()
          : searchItem.data.item2.title);

  List<Widget> buildTrailingActions(BuildContext ctx) => [
        PlatformIconButton(
          padding: EdgeInsets.zero,
          android: (ctx) => MaterialIconButtonData(
            tooltip: AppLocalizations.of(ctx).searchTip,
          ),
          icon: Icon(
            ctx.platformIcons.search,
            color: Platform.isIOS ? getTheme().accentColor : null,
          ),
          onPressed: () => showSearchItemSelect(
            ctx,
            primary: false,
          ),
        )
      ];

  List<Widget> buildIntegratingActions(BuildContext ctx) => [
        PlatformIconButton(
          padding: EdgeInsets.zero,
          android: (ctx) => MaterialIconButtonData(
              tooltip: AppLocalizations.of(ctx).calendarTip),
          icon: PlatformWidget(
            ios: (ctx) => Icon(
              TimetableIcons.calendar,
              color: getTheme().accentColor,
            ),
            android: (ctx) => Icon(Icons.calendar_today),
          ),
          onPressed: () => TimetableScreen._createCalendarEvents(
              ctx, widget._deviceCalendarPlugin),
        ),
      ]..addAll(Platform.isAndroid
          ? [
              PlatformIconButton(
                padding: EdgeInsets.zero,
                android: (ctx) => MaterialIconButtonData(
                    tooltip: AppLocalizations.of(ctx).alarmTip),
                icon: const Icon(Icons.alarm),
                onPressed: () => TimetableScreen._createAlarm(ctx, prefs),
              )
            ]
          : []);

  @override
  Widget build(BuildContext ctx) => StreamBuilder<Tuple2<bool, SearchItem>>(
        stream: timetableIdBloc.stream,
        initialData: Tuple2<bool, SearchItem>(
            true, TimetableScreen.selected ?? SearchItem.fromPrefs()),
        builder: (ctx, ssSearchItem) => PrefsScreen.buildDayStyleStream(
          ctx,
          (ctx, ssDayStyle) {
            // Create tabs
            final tabs = List();
            var mDay = TimetableScreen.fromDay.subtract(Duration(days: 1));
            for (int mTabId = 0; mTabId < TimetableScreen.dayCount; mTabId++) {
              debugPrint("mTabId: " + mTabId.toString());
              mDay = mDay.add(Duration(days: 1));
              debugPrint("mDay: " + mDay.day.toString());
              debugPrint("mWeekday: " + mDay.weekday.toString());
              if (mDay.weekday == DateTime.sunday) {
                debugPrint("Skippin sunday");
                // Skip sunday
                mTabId--;
                continue;
              }

              tabs.add(Platform.isIOS
                  ? mDay
                  : Tab(
                      text: ssDayStyle.data.index == DayStyle.Weekday.index
                          ? getWeekdayTitle(ctx, mDay)
                          : mDay.day.toString(),
                    ));
            }

            return PlatformScaffold(
              android: (ctx) => MaterialScaffoldData(
                  drawer: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        DrawerHeader(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(ctx).primaryColor,
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/icon-foreground.png'),
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.list),
                          title: Text(AppLocalizations.of(ctx).timetable),
                          onTap: () => Navigator.pop(ctx),
                        ),
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text(AppLocalizations.of(ctx).prefs),
                          onTap: () =>
                              Navigator.popAndPushNamed(ctx, PrefsScreen.ROUTE),
                        ),
                        ListTile(
                          leading: Icon(Icons.info),
                          title: Text(AppLocalizations.of(ctx).about),
                          onTap: () =>
                              Navigator.popAndPushNamed(ctx, AboutScreen.ROUTE),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.close),
                          title: Text(AppLocalizations.of(ctx).close),
                          onTap: () => SystemNavigator.pop(),
                        ),
                      ],
                    ),
                  ),
                  appBar: AppBar(
                    title: appBarTitle(ssSearchItem),
                    actions:
                        (Platform.isAndroid ? buildIntegratingActions(ctx) : [])
                          ..addAll(buildTrailingActions(ctx)),
                    bottom: TabBar(
                      tabs: tabs.cast<Widget>(),
                      controller: _tabController,
                    ),
                  )),
              ios: (ctx) => CupertinoPageScaffoldData(
                navigationBar: CupertinoCustomNavigationBar(
                  bottom: buildThemeStream((ctx, _) => CupertinoTabBar(
                        controller: _tabController,
                        titles: tabs,
                      )),
                  title: appBarTitle(ssSearchItem),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlatformIconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          ctx.platformIcons.info,
                          color: getTheme().accentColor,
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(ctx, AboutScreen.ROUTE),
                      ),
                    ]..addAll(buildIntegratingActions(ctx)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: buildTrailingActions(ctx)
                      ..addAll([
                        PlatformIconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            ctx.platformIcons.settings,
                            color: getTheme().accentColor,
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(ctx, PrefsScreen.ROUTE),
                        )
                      ]),
                  ),
                ),
              ),
              body: StreamBuilder<void>(
                stream: timetableFutureBuilderBloc.stream,
                builder: (ctx, _) => WidgetTemplates.buildFutureBuilder(ctx,
                    future: WidgetTemplates.checkInternetConnection(),
                    builder: (ctx, internetConn) {
                  if (!internetConn.data)
                    return WidgetTemplates.buildNetworkErrorNotification(ctx);
                  return WidgetTemplates.buildFutureBuilder(
                    ctx,
                    future: ssSearchItem.data.item1
                        ? TimetableScreen._getTimetable(
                            ctx,
                            ssSearchItem.data.item2,
                            prefs,
                          )
                        : TimetableScreen._loadAllTimetable(
                            ctx,
                            ssSearchItem.data.item2,
                            updateDb: false,
                          ),
                    builder: (ctx, _) {
                      if (TimetableScreen.timetable.values.isEmpty)
                        TimetableScreen.timetable.addEntries(
                          Iterable<
                              MapEntry<DateTime, List<TimelineModel>>>.generate(
                            TimetableScreen.dayCount,
                            (dayIndex) =>
                                MapEntry<DateTime, List<TimelineModel>>(
                              TimetableScreen.fromDay.add(
                                Duration(days: dayIndex),
                              ),
                              List<TimelineModel>(),
                            ),
                          ),
                        );

                      final tabViews = List<Widget>(),
                          endCacheStr = prefs.getString(PrefsIds.END_CACHE),
                          endCache = endCacheStr != null
                              ? DateTime.parse(endCacheStr)
                              : null,
                          optimizeLessonTitles =
                              prefs.getBool(PrefsIds.OPTIMIZED_LESSON_TITLES) ??
                                  true;

                      var timetableIter =
                              TimetableScreen.timetable.entries.iterator,
                          mDate = TimetableScreen.timetable.entries.first.key;

                      while (tabViews.length < TimetableScreen.dayCount) {
                        tabViews.add(
                          endCache != null && mDate.compareTo(endCache) > 0
                              ? WidgetTemplates.buildNoCacheNotification(ctx)
                              : timetableIter.moveNext()
                                  ? timetableIter.current.value.isEmpty
                                      ? WidgetTemplates
                                          .buildFreeDayNotification(
                                          ctx,
                                          ssSearchItem.data.item2,
                                        )
                                      : TimelineComponent(
                                          timetableIter.current.value,
                                          optimizeLessonTitles:
                                              optimizeLessonTitles,
                                          onRefresh: () async {
                                            if (ssSearchItem.data.item1) {
                                              await PlatformChannels.deleteDb();
                                              await TimetableScreen
                                                  ._loadAllTimetable(
                                                ctx,
                                                ssSearchItem.data.item2,
                                                updateDb: true,
                                              );
                                            }

                                            timetableFutureBuilderBloc
                                                .add(null);
                                          },
                                        )
                                  : WidgetTemplates.buildFreeDayNotification(
                                      ctx,
                                      ssSearchItem.data.item2,
                                    ),
                        );

                        mDate.add(Duration(
                            days: mDate.weekday == DateTime.saturday ? 2 : 1));
                      }
                      return TabBarView(
                        children: tabViews,
                        controller: _tabController,
                      );
                    },
                  );
                }),
              ),
//              appBar: PlatformAppBar(
//                android: (ctx) => MaterialAppBarData(
//                  bottom: TabBar(
//                    tabs: tabs,
//                    controller: _tabController,
//                  ),
//                ),
//                title: Text(
//                    ssSearchItem.data.item2.typeId == SearchItemTypeId.Teacher
//                        ? TeacherModel.fromString(ssSearchItem.data.item2.title)
//                            .initials()
//                        : ssSearchItem.data.item2.title),
//                trailingActions: (Platform.isAndroid
//                    ? <Widget>[
//                        PlatformIconButton(
//                          padding: EdgeInsets.zero,
//                          android: (ctx) => MaterialIconButtonData(
//                              tooltip: AppLocalizations.of(ctx).calendarTip),
//                          icon: const Icon(Icons.calendar_today),
//                          onPressed: () => Timetable._createCalendarEvents(
//                              ctx, widget._deviceCalendarPlugin),
//                        ),
//                        PlatformIconButton(
//                          padding: EdgeInsets.zero,
//                          android: (ctx) => MaterialIconButtonData(
//                              tooltip: AppLocalizations.of(ctx).alarmTip),
//                          icon: const Icon(Icons.alarm),
//                          onPressed: () => Timetable._createAlarm(ctx, prefs),
//                        )
//                      ]
//                    : List<Widget>())
//                  ..addAll(<Widget>[
//                    PlatformIconButton(
//                      padding: EdgeInsets.zero,
//                      android: (ctx) => MaterialIconButtonData(
//                        tooltip: AppLocalizations.of(ctx).refreshTip,
//                      ),
//                      icon: Icon(ctx.platformIcons.refresh),
//                      onPressed: () async {
//                        await PlatformChannels.deleteDb();
//                        timetableIdBloc.add(ssSearchItem.data);
//                      },
//                    ),
//                    PlatformIconButton(
//                      padding: EdgeInsets.zero,
//                      android: (ctx) => MaterialIconButtonData(
//                        tooltip: AppLocalizations.of(ctx).searchTip,
//                      ),
//                      icon: Icon(ctx.platformIcons.search),
//                      onPressed: () => showSearchItemSelect(
//                        ctx,
//                        primary: false,
//                      ),
//                    ),
//                  ]),
//              ),
            );
          },
        ),
      );
}

String getWeekdayTitle(BuildContext ctx, DateTime day) {
  return [
    AppLocalizations.of(ctx).monday,
    AppLocalizations.of(ctx).tuesday,
    AppLocalizations.of(ctx).wednesday,
    AppLocalizations.of(ctx).thursday,
    AppLocalizations.of(ctx).friday,
    AppLocalizations.of(ctx).saturday
  ][day.weekday - 1];
}

final beforeAlarmBloc = StreamController<Duration>.broadcast();

final timetableFutureBuilderBloc = StreamController<void>.broadcast();

final timetableIdBloc = StreamController<Tuple2<bool, SearchItem>>.broadcast();
