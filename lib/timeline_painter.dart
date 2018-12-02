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
import 'package:ranepa_timetable/timetable_icons.dart';

class TimelinePainter extends CustomPainter {
  final bool firstElement;
  final bool lastElement;
  final int iconCodePoint;
  final BuildContext context;

  TimelinePainter(this.context,
      {@required this.iconCodePoint,
        this.firstElement = false,
        this.lastElement = false});

  @override
  void paint(Canvas canvas, Size size) {
    _centerElementPaint(canvas, size);
  }

  static const rectMargins = 8.0;

  void _centerElementPaint(Canvas canvas, Size size) {
    Paint lineStroke = Paint()
      ..color = Theme.of(context).accentColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
        RRect.fromLTRBR(rectMargins, rectMargins, size.width - rectMargins,
            size.height - rectMargins, Radius.circular(5)),
        Paint()
          ..color = Theme.of(context).backgroundColor
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.0
          ..style = PaintingStyle.fill);

    final iconSize = 15.0;
    final circleSize = 23.0;
    final circleOffset = Offset(rectMargins * 2 + circleSize + 70, size.height / 2);

    if (firstElement && lastElement) {
      // Do nothing
    } else if (firstElement) {
      final offsetCenter = circleOffset.translate(0.0, circleSize / 2);
      final offsetBottom = Offset(circleOffset.dx, size.height);
      canvas.drawLine(offsetCenter, offsetBottom, lineStroke);
    } else if (lastElement) {
      final offsetCenter = circleOffset.translate(0.0, -circleSize / 2);
      final offsetTop = Offset(circleOffset.dx, 0);
      canvas.drawLine(offsetCenter, offsetTop, lineStroke);
    } else {
      final offsetTop = Offset(circleOffset.dx, 0);
      final offsetBottom = Offset(circleOffset.dx, size.height);
      canvas.drawLine(offsetTop, offsetBottom, lineStroke);
    }

    canvas.drawCircle(
        circleOffset,
        circleSize,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        circleOffset,
        circleSize,
        Paint()
          ..color = Theme.of(context).accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineStroke.strokeWidth);

    final span = TextSpan(
        style: TextStyle(
            fontFamily: TimetableIcons.databases.fontFamily, color: Colors.black, fontSize: iconSize*2),
        text: String.fromCharCode(iconCodePoint));
    final textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: iconSize * 2);
    textPainter.paint(canvas, circleOffset.translate(-iconSize, -(circleSize / 3 * 2)));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return null;
  }
}
