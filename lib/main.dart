import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ranepa_timetable/about.dart';
import 'package:ranepa_timetable/intro.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/platform_channels.dart';
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/theme.dart';
import 'package:ranepa_timetable/timetable.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info/package_info.dart';

SharedPreferences prefs;
String version;
final random = new Random();

class BaseWidget extends StatelessWidget {
  Widget buildBase(BuildContext ctx) => Timetable(
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
                    image: AssetImage('assets/images/icon-foreground.png'),
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
                onTap: () => Navigator.popAndPushNamed(ctx, Prefs.ROUTE),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(AppLocalizations.of(ctx).about),
                onTap: () => Navigator.popAndPushNamed(ctx, About.ROUTE),
              ),
            ]..addAll(Platform.isAndroid
                ? <Widget>[
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.close),
                      title: Text(AppLocalizations.of(ctx).close),
                      onTap: () => SystemNavigator.pop(),
                    ),
                  ]
                : []),
          ),
        ),
      );

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

              if (prefs.getString(PrefsIds.LAST_UPDATE) != version) {
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
          return MaterialApp(
            builder: (ctx, child) {
              ErrorWidget.builder = _buildError(ctx);
              return MediaQuery(
                  data:
                      MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
                  child: child);
            },
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            supportedLocales: [
              SupportedLocales.en,
              SupportedLocales.ru,
            ],
            onGenerateTitle: (BuildContext ctx) =>
                AppLocalizations.of(ctx).title,
            theme: theme,
            routes: <String, WidgetBuilder>{
              Prefs.ROUTE: (ctx) => Prefs(),
              About.ROUTE: (ctx) => About(),
            },
            home: Builder(
              builder: (ctx) => prefs.getInt(
                          PrefsIds.SEARCH_ITEM_PREFIX +
                              PrefsIds.ITEM_ID) ==
                      null
                  ? Intro(base: buildBase(ctx))
                  : buildBase(ctx),
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
            style: TextStyle(fontSize: 25.0),
            maxLines: 1,
          ),
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              initialValue: err.toString(),
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              enableInteractiveSelection: false,
              focusNode: DisabledFocusNode(),
            ),
          ),
          AutoSizeText(
            AppLocalizations.of(ctx).sendError,
            style: TextStyle(fontSize: 15.0),
            maxLines: 2,
          ),
          IconButton(
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
