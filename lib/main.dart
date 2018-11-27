import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/search.dart';

class TimetableWidget extends StatefulWidget {
  @override
  _TimetableWidgetState createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends State<TimetableWidget> {
  final GroupSearch _delegate = GroupSearch();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _lastStringSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () async {
                final String selected = await showSearch<String>(
                  context: context,
                  delegate: _delegate,
                );
                if (selected != null && selected != _lastStringSelected) {
                  setState(() {
                    _lastStringSelected = selected;
                  });
                }
              },
            ),
          ],
        ));
  }
}

Future main() async {
  return runApp(MaterialApp(
      title: 'Flutter View',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: TimetableWidget()));
}
