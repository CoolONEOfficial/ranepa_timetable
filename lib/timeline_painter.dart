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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ranepa_timetable/timeline_model.dart';
import 'package:ranepa_timetable/timetable_icons.dart';
import 'package:ranepa_timetable/timetable_room.dart';

class TimelinePainter extends CustomPainter {
  final TimelineModel model;
  final BuildContext context;

  TimelinePainter(this.context, this.model);

  @override
  void paint(Canvas canvas, Size size) {
    _centerElementPaint(canvas, size);
  }

  void _centerElementPaint(Canvas canvas, Size size) {
    const rectMargins = 8.0;
    const iconSize = 15.0;
    const circleRadius = 23.0;
    const locationIconSize = 20.0;
    const lineWidth = 2.0;

    Paint lineStroke = Paint()
      ..color = Theme.of(context).accentColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
        RRect.fromLTRBR(rectMargins, rectMargins, size.width - rectMargins,
            size.height, Radius.circular(5)),
        Paint()
          ..color = Theme.of(context).backgroundColor
          ..strokeCap = StrokeCap.round
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.fill);

    final circleOffset = Offset(
        rectMargins * 2 + circleRadius + 70, (size.height + rectMargins) / 2);

    if (!(model.first && model.last)) {
      if (model.first || !model.last) {
        canvas.drawLine(circleOffset.translate(0.0, circleRadius / 2),
            Offset(circleOffset.dx, size.height), lineStroke);
      }
      if (model.last || !model.first) {
        canvas.drawLine(circleOffset.translate(0.0, -circleRadius / 2),
            Offset(circleOffset.dx, 0), lineStroke);
      }
    }

    canvas.drawCircle(
        circleOffset,
        circleRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        circleOffset,
        circleRadius,
        Paint()
          ..color = Theme.of(context).accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineWidth);

    final fontFamily = TimetableIcons.databases.fontFamily;

    TextPainter(
        text: TextSpan(
          style: TextStyle(
            fontFamily: fontFamily,
            color: Colors.black,
            fontSize: iconSize * 2,
          ),
          text: String.fromCharCode(model.lesson.iconCodePoint),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr
    )..layout(minWidth: iconSize * 2)..paint(
        canvas, circleOffset.translate(-iconSize, -(circleRadius / 3 * 2))
    );

    TextPainter(
        text: TextSpan(
          style: TextStyle(
            fontFamily: fontFamily,
            color: Colors.black,
            fontSize: locationIconSize,
          ),
          text: String.fromCharCode((model.room.location == Location.StudyHostel
              ? TimetableIcons.studyHostel
              : model.room.location == Location.Hotel
              ? TimetableIcons.hotel
              : TimetableIcons.academy)
              .codePoint),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr
    )..layout(minWidth: iconSize * 2)..paint(
        canvas, Offset(20, 52)
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
