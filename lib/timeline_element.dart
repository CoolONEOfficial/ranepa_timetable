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
  final Color lineColor;
  final Color backgroundColor;
  final TimelineModel model;
  final bool firstElement;
  final bool lastElement;
  final Color headingColor;
  final Color descriptionColor;

  TimelineElement(
      {@required this.lineColor,
      @required this.backgroundColor,
      @required this.model,
      this.firstElement = false,
      this.lastElement = false,
      this.headingColor,
      this.descriptionColor});

  Widget _buildLine(BuildContext context) {
    return SizedBox.expand(
        child: Container(
      child: CustomPaint(
        painter: TimelinePainter(context,
            iconCodePoint: model.classType.icon.codePoint,
            lineColor: lineColor,
            backgroundColor: backgroundColor,
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
            model.classType.title.length > 47
                ? model.classType.title.substring(0, 47) + "..."
                : model.classType.title,
            style: headingColor != null
                ? TextStyle(fontWeight: FontWeight.bold, color: headingColor)
                : Theme.of(context).textTheme.title,
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 8.0, top: 45.0, left: 45.0),
          child: Text(
            model.room != null
                ? (model.room.length > 50
                    ? model.room.substring(0, 50) + "..."
                    : model.room)
                : "",
            // To prevent overflowing of text to the next element, the text is truncated if greater than 75 characters
            style: descriptionColor != null
                ? TextStyle(
                    color: descriptionColor,
                  )
                : Theme.of(context).textTheme.subtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context) {
    return Container(
      height: 80.0,
      color: backgroundColor,
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
