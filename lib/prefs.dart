import 'dart:async';

import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/themes.dart';
import 'package:ranepa_timetable/timetable.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class PrefsIds {
  static const WIDGET_TRANSLUCENT = "widget_translucent",
      THEME_ID = "theme_id",
      BEFORE_ALARM_CLOCK = "before_alarm_clock",
      END_CACHE = "end_cache",
      SELECTED_SEARCH_ITEM_PREFIX = "selected_search_item_",
      PRIMARY_SEARCH_ITEM_PREFIX = "primary_search_item_",
      ITEM_TYPE = "type",
      ITEM_ID = "id",
      ITEM_TITLE = "title";
}

Future<SearchItem> showSearchItemSelect(
        BuildContext context, SharedPreferences prefs,
        {toPrefs = true}) =>
    showSearch<SearchItem>(
      context: context,
      delegate: Search(context),
    ).then(
      (searchItem) async {
        if (searchItem != null) {
          searchItem.toPrefs(prefs, PrefsIds.SELECTED_SEARCH_ITEM_PREFIX);
          if (toPrefs) {
            searchItem.toPrefs(prefs, PrefsIds.PRIMARY_SEARCH_ITEM_PREFIX);
            await PlatformChannels.deleteDb();
          }
          timetableIdBloc.add(Tuple2<bool, SearchItem>(toPrefs, searchItem));
        }
        return searchItem;
      },
    );

void showThemeSelect(BuildContext context, SharedPreferences prefs) {
  final dialogItems = List<Widget>();

  for (var mThemeId in ThemeIds.values) {
    dialogItems.add(
      SimpleDialogOption(
        onPressed: () {
          themeIdBloc.sink.add(mThemeId.index);
          prefs.setInt(PrefsIds.THEME_ID, mThemeId.index).then(
            (_) {
              PlatformChannels.refreshWidget();
            },
          );
          Navigator.pop(context, mThemeId);
        },
        child: Text(ThemeTitles(context).titles[mThemeId.index]),
      ),
    );
  }

  showDialog<ThemeIds>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
          title: Text(AppLocalizations.of(context).themeTitle),
          children: dialogItems,
        ),
  );
}

class Prefs extends StatelessWidget {
  static const ROUTE = "/prefs";

  final widgetTranslucent = StreamController<bool>();

  Widget _buildThemePreferenceButton(
          BuildContext context, SharedPreferences prefs) =>
      WidgetTemplates.buildPreferenceButton(
        context,
        title: AppLocalizations.of(context).themeTitle,
        description: AppLocalizations.of(context).themeDescription,
        onPressed: () => showThemeSelect(context, prefs),
        rightWidget: StreamBuilder<int>(
          stream: themeIdBloc.stream,
          initialData:
              prefs.getInt(PrefsIds.THEME_ID) ?? Themes.DEFAULT_THEME_ID.index,
          builder: (context, snapshot) =>
              Text(ThemeTitles(context).titles[snapshot.data]),
        ),
      );

  Widget _buildWidgetTranslucentPreferenceButton(
          BuildContext context, SharedPreferences prefs) =>
      StreamBuilder<bool>(
        initialData: prefs.getBool(PrefsIds.WIDGET_TRANSLUCENT) ?? true,
        stream: widgetTranslucent.stream,
        builder: (context, snapshot) => WidgetTemplates.buildPreferenceButton(
              context,
              title: AppLocalizations.of(context).widgetTranslucentTitle,
              description:
                  AppLocalizations.of(context).widgetTranslucentDescription,
              rightWidget: Checkbox(
                value: snapshot.data,
                onChanged: (value) {
                  widgetTranslucent.add(value);
                  prefs.setBool(PrefsIds.WIDGET_TRANSLUCENT, value).then(
                        (_) => PlatformChannels.refreshWidget(),
                      );
                },
              ),
            ),
      );

  static Future<Duration> showBeforeAlarmClockSelect(
          BuildContext context, SharedPreferences prefs) =>
      showDurationPicker(
        context: context,
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

  Widget _buildBeforeAlarmClockPreferenceButton(
          BuildContext context, SharedPreferences prefs) =>
      WidgetTemplates.buildPreferenceButton(
        context,
        title: AppLocalizations.of(context).beforeAlarmClockTitle,
        description: AppLocalizations.of(context).beforeAlarmClockDescription,
        onPressed: () => showBeforeAlarmClockSelect(context, prefs),
        rightWidget: StreamBuilder<Duration>(
          stream: beforeAlarmBloc.stream,
          initialData:
              Duration(minutes: prefs.getInt(PrefsIds.BEFORE_ALARM_CLOCK) ?? 0),
          builder: (context, snapshot) => snapshot.data.inMicroseconds != 0
              ? Text(
                  printDuration(
                    snapshot.data,
                    delimiter: "\n",
                    locale:
                        Localizations.localeOf(context) == SupportedLocales.ru
                            ? russianLocale
                            : englishLocale,
                  ),
                )
              : Container(),
        ),
      );

  Widget _buildSearchItemPreferenceButton(
          BuildContext context, SharedPreferences prefs) =>
      WidgetTemplates.buildPreferenceButton(
        context,
        title: AppLocalizations.of(context).groupTitle,
        description: AppLocalizations.of(context).groupDescription,
        onPressed: () => showSearchItemSelect(context, prefs),
        rightWidget: StreamBuilder<Tuple2<bool, SearchItem>>(
          stream: timetableIdBloc.stream,
          initialData: Tuple2<bool, SearchItem>(null,
              SearchItem.fromPrefs(prefs, PrefsIds.PRIMARY_SEARCH_ITEM_PREFIX)),
          builder: (context, snapshot) => Text(
                snapshot.data.item2.typeId == SearchItemTypeId.Group
                    ? snapshot.data.item2.title
                    : snapshot.data.item2.title.replaceAll(' ', '\n'),
              ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).prefs),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: WidgetTemplates.buildFutureBuilder<SharedPreferences>(
          context,
          loading: Container(),
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            final prefs = snapshot.data;
            return ListView(
              children: <Widget>[
                _buildThemePreferenceButton(context, prefs),
                Divider(
                  height: 0,
                ),
                _buildSearchItemPreferenceButton(context, prefs),
                Divider(
                  height: 0,
                ),
                _buildBeforeAlarmClockPreferenceButton(context, prefs),
                Divider(
                  height: 0,
                ),
                _buildWidgetTranslucentPreferenceButton(context, prefs),
                Divider(
                  height: 0,
                ),
              ],
            );
          },
        ),
      );
}
