/* Copyright 2018 Rejish Radhakrishnan

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import 'package:flutter/material.dart';
import 'package:ranepa_timetable/timeline_model.dart';
import 'package:ranepa_timetable/timeline_painter.dart';

class TimelineElement extends StatelessWidget {
  final TimelineModel model;
  final bool firstElement;
  final bool lastElement;

  TimelineElement(
      {@required this.model,
        this.firstElement = false,
        this.lastElement = false});

  Widget _buildLine(BuildContext context) {
    return SizedBox.expand(
        child: Container(
          child: CustomPaint(
            painter: TimelinePainter(context,
                iconCodePoint: model.lesson.iconCodePoint,
                firstElement: firstElement,
                lastElement: lastElement),
          ),
        ));
  }

  Widget _buildContentColumn(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 8.0, top: 16.0, left: 140.0),
          child: Text(
            model.lesson.title,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 8.0, top: 45.0, left: 45.0),
          child: Text(
            model.room.toString(),
            style: Theme.of(context).textTheme.subtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context) {
    return Container(
      height: 80.0,
      child: Stack(
        children: <Widget>[
          _buildLine(context),
          _buildContentColumn(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildRow(context);
  }
}
