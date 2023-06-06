import 'dart:async';
import 'dart:io';

import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:ranepatimetable/apis.dart';
import 'package:ranepatimetable/localizations.dart';
import 'package:ranepatimetable/main.dart';
import 'package:ranepatimetable/platform_channels.dart';
import 'package:ranepatimetable/search.dart';
import 'package:ranepatimetable/timeline_models.dart';
import 'package:ranepatimetable/timetable.dart';
import 'package:ranepatimetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:ranepatimetable/theme.dart';
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

late SharedPreferences prefs;

Future<SearchItem> showSearchItemSelect(
  BuildContext ctx, {
  primary = true,
}) async {
  final searchItem = await SearchScreen.showSearch(ctx);
  if (searchItem != null) {
    if (primary) {
      TimetableScreen.fromDay = TimetableScreen.todayMidnight;
      await searchItem.toPrefs(PrefsIds.SEARCH_ITEM_PREFIX);
      await PlatformChannels.deleteDb();
    } else {
      if (Platform.isIOS) {
        TimetableScreen.fromDay = (await showDatePicker(
            context: ctx,
            locale: Localizations.localeOf(ctx) == SupportedLocales.ru
                ? Locale('ru')
                : Locale('en'),
            initialDate: TimetableScreen.todayMidnight,
            firstDate: TimetableScreen.todayMidnight,
            lastDate: TimetableScreen.todayMidnight.add(Duration(days: 365))
        ))!;
      } else {
        TimetableScreen.fromDay = (await showDatePicker(
          context: ctx,
          initialDate: TimetableScreen.fromDay ?? TimetableScreen.todayMidnight,
          firstDate: TimetableScreen.todayMidnight,
          lastDate: TimetableScreen.todayMidnight.add(Duration(days: 365)),
        ))!;
      }
      TimetableScreen.fromDay ??= TimetableScreen.todayMidnight;
      TimetableScreen.selected = searchItem;
    }
    Navigator.of(ctx).popAndPushNamed(TimetableScreen.ROUTE);
  }

  return searchItem;
}

Future<Brightness?> showThemeBrightnessSelect(BuildContext ctx) =>
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
                child:
                    Text(ThemeBrightnessTitles(ctx).titles[mBrightness.index]),
              ),
            )
            .toList(),
      ),
    );

void showMaterialColorPicker(BuildContext ctx) => showPlatformDialog(
      context: ctx,
      builder: (ctx) {
        ColorSwatch? pickedColor = accentColor;
        return PlatformAlertDialog(
          title: Text(AppLocalizations.of(ctx).themeAccentTitle),
          content: Container(
            height: Platform.isIOS ? 300 : null,
            width: Platform.isIOS ? 300 : null,
            child: MaterialColorPicker(
              selectedColor: pickedColor,
              allowShades: false,
              onMainColorChange: (color) => pickedColor = color,
            ),
          ),
          actions: [
            TextButton(
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
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

class PrefsScreen extends StatelessWidget {
  static const ROUTE = "/prefs";

  static Widget _buildThemePreference(BuildContext ctx) =>
      WidgetTemplates.buildListTile(
        ctx,
        title: Text(AppLocalizations.of(ctx).themeTitle),
        subtitle: Text(AppLocalizations.of(ctx).themeDescription),
        trailing: buildThemeStream(
          (ctx, snapshot) => PlatformSwitch(
            value: brightness == Brightness.dark,
            onChanged: (value) {
              brightness = value ? Brightness.dark : Brightness.light;
            },
          ),
        ),
      );

  static Widget _buildThemeAccentPreference(BuildContext ctx) =>
      WidgetTemplates.buildListTile(
        ctx,
        title: Text(AppLocalizations.of(ctx).themeAccentTitle),
        subtitle: Text(AppLocalizations.of(ctx).themeAccentDescription),
        onTap: () => showMaterialColorPicker(ctx),
        trailing: buildThemeStream(
          (ctx, snapshot) => Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: snapshot.data?.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
  static Widget _buildWidgetTranslucentPreference(BuildContext ctx) =>
      StreamBuilder<bool>(
        initialData: prefs.getBool(PrefsIds.WIDGET_TRANSLUCENT) ?? true,
        stream: widgetTranslucentBloc.stream,
        builder: (ctx, snapshot) => WidgetTemplates.buildListTile(
          ctx,
          title: Text(AppLocalizations.of(ctx).widgetTranslucentTitle),
          subtitle: Text(AppLocalizations.of(ctx).widgetTranslucentDescription),
          trailing: PlatformSwitch(
            value: snapshot.data!,
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
          duration?.inMinutes ?? 0,
        );
        beforeAlarmBloc.add(duration ?? Duration());

        return duration ?? Duration();
      });

  static Widget _buildBeforeAlarmClockPreference(BuildContext ctx) =>
      WidgetTemplates.buildListTile(
        ctx,
        title: Text(AppLocalizations.of(ctx).beforeAlarmClockTitle),
        subtitle: Text(AppLocalizations.of(ctx).beforeAlarmClockDescription),
        onTap: () => showBeforeAlarmClockSelect(ctx),
        trailing: StreamBuilder<Duration>(
          stream: beforeAlarmBloc.stream,
          initialData:
              Duration(minutes: prefs.getInt(PrefsIds.BEFORE_ALARM_CLOCK) ?? 0),
          builder: (ctx, snapshot) => snapshot.data?.inMicroseconds != 0
              ? Text(
                  printDuration(
                    snapshot.data ?? Duration(),
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
      WidgetTemplates.buildListTile(
        ctx,
        title: Text(AppLocalizations.of(ctx).groupTitle),
        subtitle: Text(AppLocalizations.of(ctx).groupDescription),
        onTap: () => showSearchItemSelect(ctx),
        trailing: StreamBuilder<Tuple2<bool, SearchItem>>(
          stream: timetableIdBloc.stream,
          initialData: Tuple2(true, SearchItem.fromPrefs()),
          builder: (ctx, snapshot) => Text(
            snapshot.data?.item2.typeId == SearchItemTypeId.Group
                ? snapshot.data?.item2.title ?? ''
                : snapshot.data?.item2.title.replaceAll(' ', '\n') ?? '',
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
        (ctx, snapshot) => WidgetTemplates.buildListTile(
          ctx,
          title: Text(AppLocalizations.of(ctx).roomLocationStyleText),
          subtitle: Text(snapshot.data == RoomLocationStyle.Icon
              ? AppLocalizations.of(ctx).roomLocationStyleDescriptionIcon
              : AppLocalizations.of(ctx).roomLocationStyleDescriptionText),
          trailing: Row(
            children: <Widget>[
              Icon(Icons.text_format),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: PlatformSwitch(
                  value: snapshot.data == RoomLocationStyle.Icon,
                  onChanged: (value) {
                    var rlStyle =
                        value ? RoomLocationStyle.Icon : RoomLocationStyle.Text;
                    roomLocationStyleBloc.add(rlStyle);
                    prefs
                        .setInt(PrefsIds.ROOM_LOCATION_STYLE, rlStyle.index)
                        .then((_) => PlatformChannels.refreshWidget());
                  },
                ),
              ),
              Icon(Icons.image),
            ],
          ),
        ),
      );

  static Widget _buildOptimizedLessonTitlesPreference(BuildContext ctx) =>
      StreamBuilder<bool>(
        initialData: prefs.getBool(PrefsIds.OPTIMIZED_LESSON_TITLES) ?? true,
        stream: optimizedLessonTitlesBloc.stream,
        builder: (ctx, snapshot) => WidgetTemplates.buildListTile(
          ctx,
          title: Text(AppLocalizations.of(ctx).optimizedLessonTitlesTitle),
          subtitle:
              Text(AppLocalizations.of(ctx).optimizedLessonTitlesDescription),
          trailing: PlatformSwitch(
            value: snapshot.data ?? false,
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
      WidgetTemplates.buildListTile(
        ctx,
        title: Text(AppLocalizations.of(ctx).siteApiTitle),
        subtitle: Text(AppLocalizations.of(ctx).siteApiDescription),
        onTap: () => showSiteApiSelect(ctx),
        trailing: StreamBuilder<SiteApi>(
          builder: (BuildContext ctx, AsyncSnapshot<SiteApi> snapshot) =>
              Text(snapshot.data!.title),
          stream: siteApiBloc.stream,
          initialData: SiteApis(ctx)
              .apis[prefs.getInt(PrefsIds.SITE_API) ?? DEFAULT_API_ID.index],
        ),
      );

  static Future<SiteApi?> showSiteApiSelect(BuildContext ctx) =>
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
                            future: WidgetTemplates.checkHostConnection(
                              mApi.url.host,
                            ),
                            builder:
                                (BuildContext ctx, AsyncSnapshot snapshot) =>
                                    Icon(snapshot.data
                                        ? Icons.done
                                        : ctx.platformIcons.clear),
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
        (ctx, snapshot) => WidgetTemplates.buildListTile(
          ctx,
          title: Text(AppLocalizations.of(ctx).dayStyleTitle),
          subtitle: Text(AppLocalizations.of(ctx).dayStyleDescription),
          trailing: Row(
            children: <Widget>[
              Text(AppLocalizations.of(ctx).dayStyleDate),
              PlatformSwitch(
                value: snapshot.data == DayStyle.Weekday,
                onChanged: (value) async {
                  var dayStyle = value ? DayStyle.Weekday : DayStyle.Date;
                  dayStyleBloc.add(dayStyle);
                  await prefs.setInt(PrefsIds.DAY_STYLE, dayStyle.index);
                  await PlatformChannels.refreshWidget();
                },
              ),
              Text(AppLocalizations.of(ctx).dayStyleWeekday),
            ],
          ),
        ),
      );

  List<Widget> buildPrefsEntries(BuildContext ctx) {
    List<Widget> entries = [];

    if (!Platform.isIOS) {
      entries.add(_buildThemePreference(ctx));
    }

    entries.addAll([
      _buildThemeAccentPreference(ctx),
      _buildSearchItemPreference(ctx),
    ]);

    if (Platform.isAndroid) {
      entries.addAll([
        _buildBeforeAlarmClockPreference(ctx),
        _buildWidgetTranslucentPreference(ctx),
      ]);
    }

    entries.addAll([
      _buildRoomLocationStylePreference(ctx),
      _buildSiteApiPreference(ctx),
      _buildOptimizedLessonTitlesPreference(ctx),
    ]);

    if (!Platform.isIOS) {
      entries.add(_buildDayStylePreference(ctx));
    }

    return entries;
  }

  @override
  Widget build(BuildContext ctx) {
    List<Widget> prefs = buildPrefsEntries(ctx);

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(ctx).prefs),
        leading: PlatformIconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            ctx.platformIcons.back,
            color: Platform.isIOS ? getTheme().colorScheme.secondary : null,
          ),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
      body: ListView.separated(
        itemCount: prefs.length,
        itemBuilder: (ctx, index) => prefs[index],
        separatorBuilder: (ctx, _) =>
            Platform.isIOS ? WidgetTemplates.buildDivider() : Container(),
      ),
    );
  }
}
