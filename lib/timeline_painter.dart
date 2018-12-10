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

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/timetable_icons.dart';

class TimelinePainter extends CustomPainter {
  final TimelineModel model;
  final BuildContext context;

  TimelinePainter(this.context, this.model);

  @override
  void paint(Canvas canvas, Size size) {
    _centerElementPaint(canvas, size);
  }

  void _centerElementPaint(Canvas canvas, Size size) {
    const rectMargins = 8.0,
        iconSize = 15.0,
        circleRadius = 23.0,
        rectRound = 5.0,
        circleMargin = 5.0;

    canvas.drawRRect(
        RRect.fromLTRBR(rectMargins, rectMargins, size.width - rectMargins,
            size.height, Radius.circular(rectRound)),
        Paint()
          ..color = Theme.of(context).backgroundColor
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill);

    var circleOffset = Offset(
        rectMargins * 2 + circleRadius + 68, (size.height + rectMargins) / 2);

    var translateIcon = 0.0;

    if (!(model.first && model.last)) {
      final rectPaint = Paint()
        ..color = Theme.of(context).accentColor
        ..strokeCap = StrokeCap.round;

      if (model.first || !model.last) {
        translateIcon = circleMargin;
        circleOffset = circleOffset.translate(0, -circleMargin);
        canvas.drawRect(
            Rect.fromLTRB(circleOffset.dx - circleRadius, circleOffset.dy,
                circleOffset.dx + circleRadius, size.height),
            rectPaint);
      }
      if (model.last || !model.first) {
        translateIcon = -circleMargin;
        circleOffset = circleOffset.translate(0, circleMargin);
        canvas.drawRect(
            Rect.fromLTRB(circleOffset.dx - circleRadius, 0,
                circleOffset.dx + circleRadius, circleOffset.dy),
            rectPaint);
      }

      final arcPaint = Paint()
        ..color = Theme.of(context).accentColor
        ..style = PaintingStyle.fill;

      if (model.first)
        canvas.drawArc(
            Rect.fromCircle(center: circleOffset, radius: circleRadius),
            -pi,
            pi,
            false,
            arcPaint);
      else if (model.last)
        canvas.drawArc(
            Rect.fromCircle(center: circleOffset, radius: circleRadius),
            -pi,
            -pi,
            false,
            arcPaint);
    } else
      canvas.drawCircle(
          circleOffset,
          circleRadius + 3,
          Paint()
            ..color = Theme.of(context).accentColor
            ..style = PaintingStyle.fill);

    final fontFamily = TimetableIcons.databases.fontFamily;

    TextPainter(
      text: TextSpan(
        style: TextStyle(
            fontFamily: fontFamily,
            color: Theme.of(context).accentTextTheme.body1.color,
            fontSize: iconSize * 2),
        text: String.fromCharCode(model.lesson.iconCodePoint),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )
      ..layout(minWidth: iconSize * 2)
      ..paint(
        canvas,
        circleOffset.translate(
            -iconSize, -(circleRadius / 3 * 2) + translateIcon),
      );

    TextPainter(
        text: TextSpan(
          style: TextStyle(
            fontFamily: fontFamily,
            color: Theme.of(context).textTheme.body1.color,
            fontSize: 20.0,
          ),
          text: String.fromCharCode(
              (model.room.location == RoomLocation.StudyHostel
                      ? TimetableIcons.studyHostel
                      : model.room.location == RoomLocation.Hotel
                          ? TimetableIcons.hotel
                          : TimetableIcons.academy)
                  .codePoint),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: iconSize * 2)
      ..paint(
        canvas,
        Offset(20, 52),
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
