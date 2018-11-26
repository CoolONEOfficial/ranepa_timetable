import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class GroupSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext) {
    return [IconButton(icon: Icon(Icons.clear))];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          showSearch(context: context, delegate: GroupSearch());
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  String text = '';
  int groupId = 15022;

  void startLoad() async {
    // Send the POST request, with full SOAP envelope as the request body.
    http.Response response = await http.post(
        'http://test.ranhigs-nn.ru/api/WebService.asmx',
        headers: {'Content-Type': 'text/xml; charset=utf-8'},
        body: '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetNameUidForRasp xmlns="http://tempuri.org/">
      <str>$query</str>
    </GetNameUidForRasp>
  </soap:Body>
</soap:Envelope>
''');



    // Use the xml package's 'parse' method to parse the response.
    xml.XmlDocument parsedXml = xml.parse(response.body);

    log(parsedXml.firstChild.firstChild.toString());

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    startLoad();
    // TODO: implement buildSuggestions
    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              leading: Icon(Icons.flash_on),
            ));
  }
}

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
          leading: IconButton(
            tooltip: 'Navigation menu',
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_arrow,
              color: Colors.white,
              progress: _delegate.transitionAnimation,
            ),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
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
            IconButton(
              tooltip: 'More (not implemented)',
              icon: Icon(
                Theme.of(context).platform == TargetPlatform.iOS
                    ? Icons.more_horiz
                    : Icons.more_vert,
              ),
              onPressed: () {},
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
