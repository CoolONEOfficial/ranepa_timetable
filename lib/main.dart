import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:ranepa_timetable/about.dart';
import 'package:ranepa_timetable/intro.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/theme.dart';
import 'package:ranepa_timetable/timetable.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

SharedPreferences prefs;
String version;
final random = new Random();

class BaseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) =>
      WidgetTemplates.buildFutureBuilder<PackageInfo>(
        ctx,
        loading: Container(),
        future: PackageInfo.fromPlatform(),
        builder: (ctx, snapshot) {
          version = snapshot.data.version;
          debugPrint("App version: " + version);

          return WidgetTemplates.buildFutureBuilder<SharedPreferences>(
            ctx,
            loading: Container(),
            future: SharedPreferences.getInstance(),
            builder: (ctx, snapshot) {
              prefs = snapshot.data;
              if (Platform.isAndroid && prefs.getString(PrefsIds.LAST_UPDATE) != version) {
                return WidgetTemplates.buildFutureBuilder(ctx,
                    loading: Container(),
                    future: Future.wait(
                        <Future>[prefs.clear(), PlatformChannels.deleteDb()]),
                    builder: (ctx, _) {
                  prefs.setString(PrefsIds.LAST_UPDATE, version);
                  return _build(ctx);
                });
              }

              return _build(ctx);
            },
          );
        },
      );

  Widget _build(BuildContext ctx) => buildThemeStream(
        (ctx, snapshot) {
          final theme = snapshot.data;

          debugPrint("prefskeys: ${prefs.getKeys()}");

          return Theme(
            data: theme,
            child: PlatformApp(
              builder: (ctx, child) {
                ScreenUtil.init(ctx);
                ErrorWidget.builder = _buildError(ctx);
                return MediaQuery(
                  data: MediaQuery.of(ctx)
                      .copyWith(alwaysUse24HourFormat: true),
                  child: child,
                );
              },
              localizationsDelegates: [
                AppLocalizationsDelegate(),
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              supportedLocales: [
                SupportedLocales.en,
                SupportedLocales.ru,
              ],
              onGenerateTitle: (BuildContext ctx) =>
                  AppLocalizations.of(ctx).title,
              routes: <String, WidgetBuilder>{
                PrefsScreen.ROUTE: (ctx) => PrefsScreen(),
                AboutScreen.ROUTE: (ctx) => AboutScreen(),
                IntroScreen.ROUTE: (ctx) => IntroScreen(),
                SearchScreen.ROUTE: (ctx) => SearchScreen(),
                TimetableScreen.ROUTE: (ctx) => TimetableScreen(),
              },
              initialRoute: prefs.getInt(
                          PrefsIds.SEARCH_ITEM_PREFIX + PrefsIds.ITEM_ID) ==
                      null
                  ? IntroScreen.ROUTE
                  : TimetableScreen.ROUTE,
            ),
          );
        },
      );
}

class SupportedLocales {
  static const Locale en = const Locale('en', 'US');
  static const Locale ru = const Locale('ru', 'RU');
}

class DisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

Widget Function(FlutterErrorDetails) _buildError(BuildContext ctx) {
  return (FlutterErrorDetails err) => Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AutoSizeText(
            AppLocalizations.of(ctx).errorMessage,
            style: TextStyle(fontSize: ScreenUtil().setSp(25)),
            maxLines: 1,
          ),
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PlatformTextField(
              controller: TextEditingController(text: err.toString()),
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              enableInteractiveSelection: false,
              focusNode: DisabledFocusNode(),
            ),
          ),
          AutoSizeText(
            AppLocalizations.of(ctx).sendError,
            style: TextStyle(fontSize: ScreenUtil().setSp(15)),
            maxLines: 2,
          ),
          PlatformIconButton(
            icon: Icon(
              Icons.send,
            ),
            onPressed: () => FlutterEmailSender.send(Email(
              body: err.toString(),
              subject: "RANEPA Timetable error",
              recipients: ["coolone.official@gmail.com"],
            )),
          ),
        ],
      ));
}

Future main() async => runApp(BaseWidget());
