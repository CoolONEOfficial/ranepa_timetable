import 'dart:async';
import 'dart:io';

import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:ranepa_timetable/apis.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/timetable.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:tuple/tuple.dart';
import 'package:ranepa_timetable/theme.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class PrefsIds {
  static const LAST_UPDATE = "last_update",
      ROOM_LOCATION_STYLE = "room_location_style",
      WIDGET_TRANSLUCENT = "widget_translucent",
      THEME_PRIMARY = "theme_primary",
      THEME_ACCENT = "theme_accent",
      THEME_TEXT_PRIMARY = "theme_text_primary",
      THEME_TEXT_ACCENT = "theme_text_accent",
      THEME_BACKGROUND = "theme_background",
      THEME_BRIGHTNESS = "theme_brightness",
      BEFORE_ALARM_CLOCK = "before_alarm_clock",
      END_CACHE = "end_cache",
      SEARCH_ITEM_PREFIX = "primary_search_item_",
      ITEM_TYPE = "type",
      ITEM_ID = "id",
      ITEM_TITLE = "title",
      SITE_API = "site_api",
      OPTIMIZED_LESSON_TITLES = "optimized_lesson_titles",
      DAY_STYLE = "day_style";
}

Future<SearchItem> showSearchItemSelect(
  BuildContext ctx, {
  primary = true,
}) =>
    showSearch<SearchItem>(
      context: ctx,
      delegate: Search(ctx),
    ).then(
      (searchItem) async {
        if (searchItem != null) {
          if (primary) {
            searchItem.toPrefs(PrefsIds.SEARCH_ITEM_PREFIX);
            await PlatformChannels.deleteDb();
          } else
            Timetable.selected = searchItem;
          timetableIdBloc.add(Tuple2<bool, SearchItem>(primary, searchItem));
        }
        return searchItem;
      },
    );

Future<Brightness> showThemeBrightnessSelect(BuildContext ctx) =>
    showDialog<Brightness>(
      context: ctx,
      builder: (BuildContext ctx) => SimpleDialog(
            title: Text(AppLocalizations.of(ctx).themeTitle),
            children: Brightness.values
                .map(
                  (mBrightness) => SimpleDialogOption(
                        onPressed: () {
                          brightness = mBrightness;
                          Navigator.pop(ctx, mBrightness);
                        },
                        child: Text(ThemeBrightnessTitles(ctx)
                            .titles[mBrightness.index]),
                      ),
                )
                .toList(),
          ),
    );

void showMaterialColorPicker(BuildContext ctx) => showDialog(
      context: ctx,
      builder: (ctx) {
        var pickedColor = accentColor;
        return AlertDialog(
          title: Text(AppLocalizations.of(ctx).themeAccentTitle),
          contentPadding: const EdgeInsets.all(6.0),
          content: MaterialColorPicker(
            selectedColor: pickedColor,
            allowShades: false,
            onMainColorChange: (color) => pickedColor = color,
          ),
          actions: [
            FlatButton(
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            FlatButton(
              child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
              onPressed: () {
                Navigator.of(ctx).pop();
                accentColor = pickedColor;
              },
            ),
          ],
        );
      },
    );

final widgetTranslucentBloc = StreamController<bool>.broadcast(),
    dayStyleBloc = StreamController<DayStyle>.broadcast(),
    roomLocationStyleBloc = StreamController<RoomLocationStyle>.broadcast(),
    siteApiBloc = StreamController<SiteApi>.broadcast(),
    optimizedLessonTitlesBloc = StreamController<bool>.broadcast();

class Prefs extends StatelessWidget {
  static const ROUTE = "/prefs";

  static Widget _buildThemePreference(BuildContext ctx) =>
      WidgetTemplates.buildPreferenceButton(
        ctx,
        title: AppLocalizations.of(ctx).themeTitle,
        description: AppLocalizations.of(ctx).themeDescription,
        onPressed: () => showThemeBrightnessSelect(ctx),
        rightWidget: buildThemeStream(
          (ctx, snapshot) => Text(ThemeBrightnessTitles(ctx)
              .titles[snapshot.data.brightness.index]),
        ),
      );

  static Widget _buildThemeAccentPreference(BuildContext ctx) =>
      WidgetTemplates.buildPreferenceButton(
        ctx,
        title: AppLocalizations.of(ctx).themeAccentTitle,
        description: AppLocalizations.of(ctx).themeAccentDescription,
        onPressed: () => showMaterialColorPicker(ctx),
        rightWidget: buildThemeStream(
          (ctx, snapshot) => Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: snapshot.data.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
        ),
      );

  static Widget _buildWidgetTranslucentPreference(BuildContext ctx) =>
      StreamBuilder<bool>(
        initialData: prefs.getBool(PrefsIds.WIDGET_TRANSLUCENT) ?? true,
        stream: widgetTranslucentBloc.stream,
        builder: (ctx, snapshot) => WidgetTemplates.buildPreferenceButton(
              ctx,
              title: AppLocalizations.of(ctx).widgetTranslucentTitle,
              description:
                  AppLocalizations.of(ctx).widgetTranslucentDescription,
              rightWidget: Switch(
                value: snapshot.data,
                onChanged: (value) {
                  widgetTranslucentBloc.add(value);
                  prefs.setBool(PrefsIds.WIDGET_TRANSLUCENT, value).then(
                        (_) => PlatformChannels.refreshWidget(),
                      );
                },
              ),
            ),
      );

  static Future<Duration> showBeforeAlarmClockSelect(BuildContext ctx) =>
      showDurationPicker(
        context: ctx,
        initialTime:
            Duration(minutes: prefs.getInt(PrefsIds.BEFORE_ALARM_CLOCK) ?? 30),
        snapToMins: 5.0,
      ).then((duration) {
        prefs.setInt(
          PrefsIds.BEFORE_ALARM_CLOCK,
          duration.inMinutes,
        );
        beforeAlarmBloc.add(duration);

        return duration;
      });

  static Widget _buildBeforeAlarmClockPreference(BuildContext ctx) =>
      WidgetTemplates.buildPreferenceButton(
        ctx,
        title: AppLocalizations.of(ctx).beforeAlarmClockTitle,
        description: AppLocalizations.of(ctx).beforeAlarmClockDescription,
        onPressed: () => showBeforeAlarmClockSelect(ctx),
        rightWidget: StreamBuilder<Duration>(
          stream: beforeAlarmBloc.stream,
          initialData:
              Duration(minutes: prefs.getInt(PrefsIds.BEFORE_ALARM_CLOCK) ?? 0),
          builder: (ctx, snapshot) => snapshot.data.inMicroseconds != 0
              ? Text(
                  printDuration(
                    snapshot.data,
                    delimiter: "\n",
                    locale: Localizations.localeOf(ctx) == SupportedLocales.ru
                        ? russianLocale
                        : englishLocale,
                  ),
                )
              : Container(),
        ),
      );

  static Widget _buildSearchItemPreference(BuildContext ctx) =>
      WidgetTemplates.buildPreferenceButton(
        ctx,
        title: AppLocalizations.of(ctx).groupTitle,
        description: AppLocalizations.of(ctx).groupDescription,
        onPressed: () => showSearchItemSelect(ctx),
        rightWidget: StreamBuilder<Tuple2<bool, SearchItem>>(
          stream: timetableIdBloc.stream,
          initialData: Tuple2<bool, SearchItem>(null, SearchItem.fromPrefs()),
          builder: (ctx, snapshot) => Text(
                snapshot.data.item2.typeId == SearchItemTypeId.Group
                    ? snapshot.data.item2.title
                    : snapshot.data.item2.title.replaceAll(' ', '\n'),
              ),
        ),
      );

  static StreamBuilder<RoomLocationStyle> buildRoomLocationStyleStream(
    BuildContext ctx,
    AsyncWidgetBuilder<RoomLocationStyle> builder,
  ) =>
      StreamBuilder<RoomLocationStyle>(
        initialData: RoomLocationStyle
            .values[prefs.getInt(PrefsIds.ROOM_LOCATION_STYLE) ?? 0],
        stream: roomLocationStyleBloc.stream,
        builder: builder,
      );

  static StreamBuilder<DayStyle> buildDayStyleStream(
    BuildContext ctx,
    AsyncWidgetBuilder<DayStyle> builder,
  ) =>
      StreamBuilder<DayStyle>(
        initialData: DayStyle.values[prefs.getInt(PrefsIds.DAY_STYLE) ?? 0],
        stream: dayStyleBloc.stream,
        builder: builder,
      );

  static Widget _buildRoomLocationStylePreference(BuildContext ctx) =>
      buildRoomLocationStyleStream(
        ctx,
        (ctx, snapshot) => WidgetTemplates.buildPreferenceButton(
              ctx,
              title: AppLocalizations.of(ctx).roomLocationStyleText,
              description: snapshot.data == RoomLocationStyle.Icon
                  ? AppLocalizations.of(ctx).roomLocationStyleDescriptionIcon
                  : AppLocalizations.of(ctx).roomLocationStyleDescriptionText,
              rightWidget: Row(
                children: <Widget>[
                  Text(AppLocalizations.of(ctx).roomLocationStyleText),
                  Switch(
                    value: snapshot.data == RoomLocationStyle.Icon,
                    onChanged: (value) {
                      var rlStyle = value
                          ? RoomLocationStyle.Icon
                          : RoomLocationStyle.Text;
                      roomLocationStyleBloc.add(rlStyle);
                      prefs
                          .setInt(PrefsIds.ROOM_LOCATION_STYLE, rlStyle.index)
                          .then((_) => PlatformChannels.refreshWidget());
                    },
                  ),
                  Text(AppLocalizations.of(ctx).roomLocationStyleIcon),
                ],
              ),
            ),
      );

  static Widget _buildOptimizedLessonTitlesPreference(BuildContext ctx) =>
      StreamBuilder<bool>(
        initialData: prefs.getBool(PrefsIds.OPTIMIZED_LESSON_TITLES) ?? true,
        stream: optimizedLessonTitlesBloc.stream,
        builder: (ctx, snapshot) => WidgetTemplates.buildPreferenceButton(
              ctx,
              title: AppLocalizations.of(ctx).optimizedLessonTitlesTitle,
              description:
                  AppLocalizations.of(ctx).optimizedLessonTitlesDescription,
              rightWidget: Switch(
                value: snapshot.data,
                onChanged: (value) async {
                  optimizedLessonTitlesBloc.add(value);
                  await prefs.setBool(PrefsIds.OPTIMIZED_LESSON_TITLES, value);
                  await PlatformChannels.deleteDb();
                  PlatformChannels.refreshWidget();
                },
              ),
            ),
      );

  static Widget _buildSiteApiPreference(BuildContext ctx) =>
      WidgetTemplates.buildPreferenceButton(
        ctx,
        title: AppLocalizations.of(ctx).siteApiTitle,
        description: AppLocalizations.of(ctx).siteApiDescription,
        onPressed: () => showSiteApiSelect(ctx),
        rightWidget: StreamBuilder<SiteApi>(
          builder: (BuildContext ctx, AsyncSnapshot<SiteApi> snapshot) =>
              Text(snapshot.data.title),
          stream: siteApiBloc.stream,
          initialData: SiteApis(ctx)
              .apis[prefs.getInt(PrefsIds.SITE_API) ?? DEFAULT_API_ID.index],
        ),
      );

  static Future<SiteApi> showSiteApiSelect(BuildContext ctx) =>
      showDialog<SiteApi>(
        context: ctx,
        builder: (BuildContext ctx) => SimpleDialog(
              title: Text(AppLocalizations.of(ctx).siteApiTitle),
              children: SiteApis(ctx)
                  .apis
                  .asMap()
                  .map(
                    (index, mApi) => MapEntry(
                        index,
                        SimpleDialogOption(
                          onPressed: () async {
                            await prefs.setInt(PrefsIds.SITE_API, index);
                            await PlatformChannels.deleteDb();
                            siteApiBloc.add(mApi);
                            Navigator.pop(ctx, mApi);
                          },
                          child: Row(
                            children: <Widget>[
                              Expanded(child: Text(mApi.title)),
                              WidgetTemplates.buildFutureBuilder(
                                ctx,
                                loading: Container(),
                                future: WidgetTemplates.checkInternetConnection(
                                  mApi.url.host,
                                ),
                                builder: (BuildContext ctx,
                                        AsyncSnapshot snapshot) =>
                                    Icon(snapshot.data
                                        ? Icons.done
                                        : Icons.clear),
                              ),
                            ],
                          ),
                        )),
                  )
                  .values
                  .toList(),
            ),
      );

  static Widget _buildDayStylePreference(BuildContext ctx) =>
      buildDayStyleStream(
        ctx,
        (ctx, snapshot) => WidgetTemplates.buildPreferenceButton(
              ctx,
              title: AppLocalizations.of(ctx).dayStyleTitle,
              description: AppLocalizations.of(ctx).dayStyleDescription,
              rightWidget: Row(
                children: <Widget>[
                  Text(AppLocalizations.of(ctx).dayStyleDate),
                  Switch(
                    value: snapshot.data == DayStyle.Weekday,
                    onChanged: (value) {
                      var dayStyle = value ? DayStyle.Weekday : DayStyle.Date;
                      dayStyleBloc.add(dayStyle);
                      prefs
                          .setInt(PrefsIds.DAY_STYLE, dayStyle.index)
                          .then((_) => PlatformChannels.refreshWidget());
                    },
                  ),
                  Text(AppLocalizations.of(ctx).dayStyleWeekday),
                ],
              ),
            ),
      );

  @override
  Widget build(BuildContext ctx) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(ctx).prefs),
          leading: IconButton(
            icon:
                Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
            onPressed: () => Navigator.pop(ctx),
          ),
        ),
        body: ListView(
          children: <Widget>[
            _buildThemePreference(ctx),
            Divider(height: 0),
            _buildThemeAccentPreference(ctx),
            Divider(height: 0),
            _buildSearchItemPreference(ctx),
            Divider(height: 0),
            _buildBeforeAlarmClockPreference(ctx),
            Divider(height: 0),
            _buildWidgetTranslucentPreference(ctx),
            Divider(height: 0),
            _buildRoomLocationStylePreference(ctx),
            Divider(height: 0),
            _buildSiteApiPreference(ctx),
            Divider(height: 0),
            _buildOptimizedLessonTitlesPreference(ctx),
            Divider(height: 0),
            _buildDayStylePreference(ctx),
            Divider(height: 0),
          ],
        ),
      );
}
