import 'dart:async';

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
import 'package:shared_preferences/shared_preferences.dart';
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
      PRIMARY_SEARCH_ITEM_PREFIX = "primary_search_item_",
      ITEM_TYPE = "type",
      ITEM_ID = "id",
      ITEM_TITLE = "title",
      SITE_API = "site_api";
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
            searchItem.toPrefs(prefs, PrefsIds.PRIMARY_SEARCH_ITEM_PREFIX);
            await PlatformChannels.deleteDb();
          } else
            Timetable.selected = searchItem;
          timetableIdBloc.add(Tuple2<bool, SearchItem>(primary, searchItem));
        }
        return searchItem;
      },
    );

Future<Brightness> showThemeBrightnessSelect(BuildContext ctx) {
  final dialogItems = List<Widget>();

  for (var mBrightness in Brightness.values) {
    dialogItems.add(
      SimpleDialogOption(
        onPressed: () {
          brightness = mBrightness;
          Navigator.pop(ctx, mBrightness);
        },
        child: Text(ThemeBrightnessTitles(ctx).titles[mBrightness.index]),
      ),
    );
  }

  return showDialog<Brightness>(
    context: ctx,
    builder: (BuildContext ctx) => SimpleDialog(
          title: Text(AppLocalizations.of(ctx).themeTitle),
          children: dialogItems,
        ),
  );
}

void showMaterialColorPicker(BuildContext ctx) => showDialog(
      context: ctx,
      builder: (ctx) {
        var pickedColor = accentColor;
        return AlertDialog(
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

final widgetTranslucentBloc = StreamController<bool>();
final roomLocationStyleBloc = StreamController<RoomLocationStyle>();

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
              rightWidget: Checkbox(
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
          initialData: Tuple2<bool, SearchItem>(null,
              SearchItem.fromPrefs(prefs, PrefsIds.PRIMARY_SEARCH_ITEM_PREFIX)),
          builder: (ctx, snapshot) => Text(
                snapshot.data.item2.typeId == SearchItemTypeId.Group
                    ? snapshot.data.item2.title
                    : snapshot.data.item2.title.replaceAll(' ', '\n'),
              ),
        ),
      );

  static Widget _buildRoomLocationStylePreference(BuildContext ctx) =>
      StreamBuilder<RoomLocationStyle>(
        initialData: RoomLocationStyle
            .values[prefs.getInt(PrefsIds.ROOM_LOCATION_STYLE) ?? 0],
        stream: roomLocationStyleBloc.stream,
        builder: (ctx, snapshot) => WidgetTemplates.buildPreferenceButton(
              ctx,
              title: AppLocalizations.of(ctx).widgetTranslucentTitle,
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

  static Widget _buildSiteApiPreference(BuildContext ctx) =>
      WidgetTemplates.buildPreferenceButton(
        ctx,
        title: AppLocalizations.of(ctx).siteApiTitle,
        description: AppLocalizations.of(ctx).siteApiDescription,
        onPressed: () => showSiteApiSelect(ctx),
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

  static Future<SiteApi> showSiteApiSelect(BuildContext ctx) =>
      showDialog<SiteApi>(
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

  @override
  Widget build(BuildContext ctx) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(ctx).prefs),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
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
          ],
        ),
      );
}
