import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/search.dart';
import 'package:ranepa_timetable/theme.dart';
import 'package:ranepa_timetable/timetable.dart';
import 'package:ranepa_timetable/timetable_icons.dart';

class WidgetTemplates {
  static Widget buildPreferenceButton(BuildContext ctx,
      {@required String title,
      @required String description,
      VoidCallback onPressed,
      Widget rightWidget,
      Widget bottomWidget}) {
    var expandedChildren = <Widget>[
      Text(
        title,
        style: Theme.of(ctx).textTheme.subhead,
      ),
      Container(
        height: 2,
      ),
      Text(
        description,
        style: Theme.of(ctx).textTheme.caption,
      ),
    ];

    if (bottomWidget != null) expandedChildren.add(bottomWidget);

    var rowChildren = <Widget>[
      Expanded(child: ListBody(children: expandedChildren)),
    ];

    if (rightWidget != null) rowChildren.add(rightWidget);

    return FlatButton(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.0),
          child: Row(children: rowChildren)),
      onPressed: onPressed ?? () {},
    );
  }

  static Widget _buildNotification(
          BuildContext ctx, String text, Widget widget) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            widget,
            Container(height: 20),
            Text(
              text,
              style: Theme.of(ctx).textTheme.title,
            )
          ],
        ),
      );

  static Widget _buildIconNotification(
    BuildContext ctx,
    String text, [
    IconData icon,
  ]) =>
      _buildNotification(
        ctx,
        text,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Icon(icon, size: 140),
        ),
      );

  static Widget buildLoadingNotification(BuildContext ctx) =>
      _buildNotification(
        ctx,
        AppLocalizations.of(ctx).loading,
        PlatformCircularProgressIndicator(),
      );

  static Widget buildErrorNotification(BuildContext ctx, String error) =>
      _buildIconNotification(ctx, error, Icons.error);

  static Widget buildNetworkErrorNotification(BuildContext ctx) =>
      _buildNotification(
        ctx,
        AppLocalizations.of(ctx).noNetworkConnection,
        RawMaterialButton(
          onPressed: () => timetableFutureBuilderBloc.add(null),
          child: Icon(
            PlatformIcons(ctx).refresh,
            size: 100,
          ),
          shape: CircleBorder(),
          padding: const EdgeInsets.all(30),
        ),
      );

  static Widget buildNoCacheNotification(BuildContext ctx) =>
      _buildNotification(
        ctx,
        AppLocalizations.of(ctx).noCache,
        RawMaterialButton(
          onPressed: () => timetableFutureBuilderBloc.add(null),
          child: Icon(
            Icons.cached,
            size: 100,
          ),
          shape: CircleBorder(),
          padding: const EdgeInsets.all(30),
        ),
      );

  static Image buildLogo(
    ThemeData theme, {
    Color color,
  }) =>
      Image(
        image: AssetImage(
          'assets/images/icon-full.png',
        ),
        width: 150,
        height: 150,
      );

  static Widget buildFreeDayNotification(
      BuildContext ctx, SearchItem searchItem) {
    IconData icon;
    switch (searchItem.typeId) {
      case SearchItemTypeId.Teacher:
        icon = TimetableIcons.confetti;
        break;
      case SearchItemTypeId.Group:
        icon = TimetableIcons.beer;
        break;
    }

    return _buildIconNotification(ctx, AppLocalizations.of(ctx).freeDay, icon);
  }

  static Flushbar buildFlushbar(
    BuildContext ctx,
    String msg, {
    String title,
    IconData iconData,
  }) =>
      Flushbar(
        title: title,
        messageText: Text(
          msg,
          style: (Platform.isIOS
                  ? getTheme().textTheme
                  : getTheme().accentTextTheme)
              .bodyText2,
        ),
        icon: Icon(iconData,
            color: Platform.isIOS
                ? getTheme().primaryColor
                : getTheme().accentIconTheme.color),
        duration: Duration(seconds: 3),
        flushbarStyle: FlushbarStyle.GROUNDED,
        backgroundColor: Platform.isIOS
            ? CupertinoTheme.of(ctx).barBackgroundColor
            : getTheme().accentColor,
      );

  static Widget buildFutureBuilder<T>(
    BuildContext ctx, {
    @required Future future,
    @required AsyncWidgetBuilder<T> builder,
    Widget loading,
    Widget error,
  }) =>
      FutureBuilder<T>(
        future: future,
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return loading ?? WidgetTemplates.buildLoadingNotification(ctx);
              break;
            case ConnectionState.done:
              if (snapshot.hasError)
                return error ??
                    WidgetTemplates.buildErrorNotification(
                        ctx, "${snapshot.error}" ?? "Unknown");
              return builder(ctx, snapshot);
          }
          return null;
        },
      );

  static Future<bool> checkHostConnection([
    String host = 'google.com',
  ]) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<bool> checkInternetConnection() async {
    var conn = await Connectivity().checkConnectivity();
    print("conn status: $conn");
    return conn != ConnectivityResult.none;
  }
}
