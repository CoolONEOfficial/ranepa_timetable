import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:ranepatimetable/localizations.dart';
import 'package:ranepatimetable/search.dart';
import 'package:ranepatimetable/theme.dart';
import 'package:ranepatimetable/timetable.dart';
import 'package:ranepatimetable/timetable_icons.dart';

class WidgetTemplates {
  static Widget buildDivider() => Divider(
        height: Platform.isIOS ? 0 : 1,
        color: Platform.isIOS
            ? Color(0x4D000000)
            : getTheme().textTheme.bodySmall!.color,
      );

  static Widget buildListTile(
    BuildContext ctx, {
    required Widget title,
    Widget? subtitle,
    VoidCallback? onTap,
    Widget? leading,
    Widget? trailing,
    Widget? bottom,
    EdgeInsets? padding,
  }) {
    var expandedChildren = <Widget>[
      DefaultTextStyle(
        style: Theme.of(ctx).textTheme.titleMedium!.copyWith(
          color: MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness == Brightness.dark ? Colors.white : Colors.black
        ),
        child: title,
      )
    ];

    if (subtitle != null)
      expandedChildren.addAll([
        SizedBox(
          height: 2,
        ),
        DefaultTextStyle(
          style: Theme.of(ctx).textTheme.bodySmall!,
          child: subtitle,
        ),
      ]);

    if (bottom != null) expandedChildren.add(bottom);

    List<Widget> rowChildren = [];

    if (leading != null)
      rowChildren.add(
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: leading,
        ),
      );

    rowChildren.add(Expanded(
      child: ListBody(
        children: expandedChildren,
      ),
    ));

    if (trailing != null)
      rowChildren.add(
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: trailing,
        ),
      );

    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Platform.isIOS ? CupertinoTheme.of(ctx).barBackgroundColor : null,
      ),
      child: Padding(
        padding: padding ??
            EdgeInsets.symmetric(
              vertical: Platform.isIOS ? 12.0 : 16.0,
            ),
        child: Row(
          children: rowChildren,
        ),
      ),
      onPressed: onTap ?? () {},
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
              style: Theme.of(ctx).textTheme.titleLarge!,
            )
          ],
        ),
      );

  static Widget _buildIconNotification(
    BuildContext ctx,
    String text, [
    IconData? icon,
  ]) =>
      _buildNotification(
        ctx,
        text,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Icon(
            icon,
            size: 140,
            color: Platform.isIOS ? getTheme().colorScheme.secondary : null,
          ),
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
    Color? color,
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

  static buildFlushbar(
    BuildContext ctx,
    String msg, {
    String? title,
    IconData? iconData,
  }) => ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
          content: Text(msg)
      )
  );
      // __DEPRECATED
      // Flushbar(
      //   title: title,
      //   messageText: Text(
      //     msg,
      //     style: (Platform.isIOS
      //             ? getTheme().textTheme
      //             : getTheme().accentTextTheme)
      //         .body1,
      //   ),
      //   icon: Icon(iconData,
      //       color: Platform.isIOS
      //           ? getTheme().primaryColor
      //           : getTheme().accentIconTheme.color),
      //   duration: Duration(seconds: 3),
      //   flushbarStyle: FlushbarStyle.GROUNDED,
      //   backgroundColor: Platform.isIOS
      //       ? CupertinoTheme.of(ctx).barBackgroundColor
      //       : getTheme().accentColor,
      // );

  static Widget buildFutureBuilder<T>(
    BuildContext ctx, {
    required Future future,
    required AsyncWidgetBuilder builder,
    Widget? loading,
    Widget? error,
  }) =>
      FutureBuilder(
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
