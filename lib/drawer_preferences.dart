import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/localizations.dart';

class DrawerPreferences extends StatelessWidget {
  static const ROUTE = "/preferences";

  Widget buildPreferenceButton(BuildContext context,
      {@required String title,
      @required String description,
      @required VoidCallback onPressed,
      Widget rightWidget}) {
    var rowChildren = <Widget>[
      Expanded(
          child: ListBody(
        children: <Widget>[
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
        ],
      )),
    ];

    if (rightWidget != null) rowChildren.add(rightWidget);

    return FlatButton(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.0),
          child: Row(children: rowChildren)),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).preferences),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: <Widget>[
          buildPreferenceButton(
            context,
            title: "Title",
            description: "Description",
            onPressed: () {},
          ),
          Divider(
            height: 0,
          ),
        ],
      ),
    );
  }
}
