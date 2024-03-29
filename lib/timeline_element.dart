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

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ranepatimetable/main.dart';
import 'package:ranepatimetable/prefs.dart';
import 'package:ranepatimetable/search.dart';
import 'package:ranepatimetable/timeline_models.dart';
import 'package:ranepatimetable/timeline_painter.dart';
import 'package:ranepatimetable/timetable.dart';

class TimelineElement extends StatelessWidget {
  final TimelineModel model;
  final bool optimizeLessonTitles;

  TimelineElement(this.model, {required this.optimizeLessonTitles});

  Widget _buildLine(BuildContext ctx) => SizedBox.expand(
        child: Container(
          child: CustomPaint(
            painter: TimelinePainter(ctx, model),
          ),
        ),
      );

  Widget _buildTeacherGroup(BuildContext ctx) {
    final user = User.values[TimetableScreen.selected?.typeId?.index ??
        SearchItem.fromPrefs().typeId.index];
    return Tooltip(
      message: user == User.Student ? model.teacher.toString() : model.group,
      child: Text(
        user == User.Student ? model.teacher.initials() : model.group,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(ctx).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildStart(BuildContext ctx) => AutoSizeText(
        model.start.format(ctx),
        textAlign: TextAlign.center,
        style: Theme.of(ctx).textTheme.titleLarge,
        maxFontSize: 20,
        maxLines: 1,
      );

  Widget _buildFinish(BuildContext ctx) => AutoSizeText(
        model.finish.format(ctx),
        textAlign: TextAlign.center,
        style: Theme.of(ctx).textTheme.bodyMedium,
        maxFontSize: 14,
        maxLines: 1,
      );

  Widget _buildLessonType(BuildContext ctx) => Tooltip(
        message: model.lesson.action?.title ?? model.lesson.fullTitle,
        child: AutoSizeText(
          model.lesson.action?.title ?? '',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(ctx).textTheme.bodyMedium,
          maxLines: 1,
        ),
      );
  Widget _buildLessonTitle(BuildContext ctx, {required bool optimizeTitles}) =>
      Tooltip(
        message: model.lesson.fullTitle ?? model.lesson.title,
        child: Container(
          height: 40,
          child: AutoSizeText(
            optimizeTitles ? model.lesson.title ?? '' : model.lesson.fullTitle ?? '',
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Theme.of(ctx).textTheme.titleLarge,
            maxFontSize: 20,
          ),
        ),
      );

  Widget _buildRoomLocation(BuildContext ctx) {
    String prefix = "";
    if (RoomLocationStyle
            .values[prefs.getInt(PrefsIds.ROOM_LOCATION_STYLE) ?? 0] ==
        RoomLocationStyle.Text)
      switch (model.room.location) {
        case RoomLocation.StudyHostel:
          prefix = "СО-";
          break;
        case RoomLocation.Hotel:
          prefix = "П8-";
          break;
        default:
      }

    return AutoSizeText(
      prefix + model.room.number,
      style: Theme.of(ctx).textTheme.titleMedium,
      maxLines: 1,
      textAlign: RoomLocationStyle
                  .values[prefs.getInt(PrefsIds.ROOM_LOCATION_STYLE) ?? 0] ==
              RoomLocationStyle.Text
          ? TextAlign.center
          : TextAlign.start,
    );
  }

  static const innerPadding = 4.0;

  Widget _buildLeftContent(BuildContext ctx) => Container(
        width: 68 - innerPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildStart(ctx),
            _buildFinish(ctx),
            Padding(
              padding: EdgeInsets.only(
                left: RoomLocationStyle.values[
                            prefs.getInt(PrefsIds.ROOM_LOCATION_STYLE) ?? 0] ==
                        RoomLocationStyle.Icon
                    ? 22
                    : 2,
                bottom: 2,
                top: 1,

              ),
              child: _buildRoomLocation(ctx),
            ),
          ],
        ),
      );

  Widget _buildRightContent(
    BuildContext ctx, {
    required bool optimizeTitles,
  }) =>
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(child: _buildLessonType(ctx)),
                Flexible(child: _buildTeacherGroup(ctx)),
              ],
            ),
            _buildLessonTitle(ctx, optimizeTitles: optimizeTitles),
          ],
        ),
      );

  Widget _buildContentColumn(BuildContext ctx) => Padding(
        padding: EdgeInsets.only(
          top: TimelinePainter.rectMargins * 2,
          left: TimelinePainter.rectMargins * 2,
          right: TimelinePainter.rectMargins * 2,
          bottom: TimelinePainter.rectMargins,
        ),
        child: Row(
          children: <Widget>[
            _buildLeftContent(ctx),
            Container(
              width: 50 + innerPadding + TimelinePainter.circleRadiusAdd,
            ),
            _buildRightContent(ctx, optimizeTitles: optimizeLessonTitles),
          ],
        ),
      );

  Widget _buildRow(BuildContext ctx) => Container(
        height: 85,
        child: Stack(
          children: <Widget>[
            _buildLine(ctx),
            _buildContentColumn(ctx),
          ],
        ),
      );

  @override
  Widget build(BuildContext ctx) => _buildRow(ctx);
}
