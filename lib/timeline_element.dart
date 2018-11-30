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
  final Animation<double> controller;
  final Color headingColor;
  final Color descriptionColor;

  TimelineElement(
      {@required this.lineColor,
      @required this.backgroundColor,
      @required this.model,
      this.firstElement = false,
      this.lastElement = false,
      this.controller,
      this.headingColor,
      this.descriptionColor});

  Widget _buildLine(BuildContext context, Widget child) {
    return new Container(
      width: 40.0,
      child: new CustomPaint(
        painter: new TimelinePainter(
            iconCodePoint: model.classType.icon.codePoint,
            lineColor: lineColor,
            backgroundColor: backgroundColor,
            firstElement: firstElement,
            lastElement: lastElement,
            controller: controller),
      ),
    );
  }

  Widget _buildContentColumn(BuildContext context) {
    return new Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
          padding: const EdgeInsets.only(bottom: 8.0, top: 24.0, left: 8.0),
          child: new Text(
            model.classType.title.length > 47
                ? model.classType.title.substring(0, 47) + "..."
                : model.classType.title,
            style: headingColor != null
                ? new TextStyle(
                    fontWeight: FontWeight.bold, color: headingColor)
                : Theme.of(context).textTheme.title,
          ),
        ),
        new Expanded(
          child: new Text(
            model.room != null
                ? (model.room.length > 50
                    ? model.room.substring(0, 50) + "..."
                    : model.room)
                : "",
            // To prevent overflowing of text to the next element, the text is truncated if greater than 75 characters
            style: descriptionColor != null
                ? new TextStyle(
                    color: descriptionColor,
                  )
                : Theme.of(context).textTheme.caption,
          ),
        )
      ],
    );
  }

  Widget _buildRow(BuildContext context) {
    return new Container(
      height: 80.0,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new AnimatedBuilder(
            builder: _buildLine,
            animation: controller,
          ),
          new Expanded(
            child: _buildContentColumn(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildRow(context);
  }
}
