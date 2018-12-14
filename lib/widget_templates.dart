import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/localizations.dart';

class WidgetTemplates {
  static Widget buildPreferenceButton(BuildContext context,
      {@required String title,
      @required String description,
      VoidCallback onPressed,
      Widget rightWidget,
      Widget bottomWidget}) {
    var expandedChildren = <Widget>[
      Text(
        title,
        style: Theme.of(context).textTheme.subhead,
      ),
      Container(
        height: 2,
      ),
      Text(
        description,
        style: Theme.of(context).textTheme.caption,
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

  static Widget _buildNotification(BuildContext context, String text,
      [IconData icon]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon == null
              ? CircularProgressIndicator()
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(icon, size: 140),
                ),
          Container(height: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.subtitle,
          )
        ],
      ),
    );
  }

  static Widget buildLoadingNotification(BuildContext context) =>
      _buildNotification(context, AppLocalizations.of(context).loading);

  static Widget buildErrorNotification(BuildContext context, String error) =>
      _buildNotification(context, error, Icons.error);

  static Widget buildInternetErrorNotification(BuildContext context) =>
      buildErrorNotification(context, AppLocalizations.of(context).noInternetConnection);

  static Widget buildFutureBuilder<T>(BuildContext context,
      {@required Future future,
      @required AsyncWidgetBuilder<T> builder,
      Widget loading,
      Widget error}) {
    return FutureBuilder<T>(
        future: future,
        builder: (BuildContext _, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return loading ?? WidgetTemplates.buildLoadingNotification(context);
              break;
            case ConnectionState.done:
              if (snapshot.hasError)
                return error ??
                    WidgetTemplates.buildErrorNotification(context, snapshot.error);
              return builder(context, snapshot);
          }
        });
  }
}
