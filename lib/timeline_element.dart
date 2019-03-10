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
import 'package:ranepa_timetable/prefs.dart';
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/timeline_painter.dart';
import 'package:ranepa_timetable/timetable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimelineElement extends StatelessWidget {
  final TimelineModel model;
  final SharedPreferences prefs;

  TimelineElement([this.model, this.prefs]);

  Widget _buildLine(BuildContext context) => SizedBox.expand(
        child: Container(
          child: CustomPaint(
            painter: TimelinePainter(context, model),
          ),
        ),
      );

  Widget _buildTeacherGroup(BuildContext context) {
    final user = User.values[prefs.getInt((Timetable.showSelected
                ? PrefsIds.SELECTED_SEARCH_ITEM_PREFIX
                : PrefsIds.PRIMARY_SEARCH_ITEM_PREFIX) +
            PrefsIds.ITEM_TYPE) ??
        0];
    return Tooltip(
      message: user == User.Student ? model.teacher.toString() : model.group,
      child: Text(
        user == User.Student ? model.teacher.initials() : model.group,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Widget _buildStart(BuildContext context) => Text(
        model.start.format(context),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.title,
      );

  Widget _buildFinish(BuildContext context) => Text(
        model.finish.format(context),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.body2,
      );

  Widget _buildLessonType(BuildContext context) => Tooltip(
        message: model.lesson.action?.title ?? model.lesson.fullTitle,
        child: Text(
          model.lesson.action.title,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.body2,
        ),
      );

  Widget _buildLessonTitle(BuildContext context) => Tooltip(
        message: model.lesson.fullTitle ?? model.lesson.title,
        child: Text(
          model.lesson.title,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: Theme.of(context).textTheme.title,
        ),
      );

  Widget _buildRoomLocation(BuildContext context) => Text(
        model.room.number,
        style: Theme.of(context).textTheme.subtitle,
      );

  static const innerPadding = 4.0;

  Widget _buildLeftContent(BuildContext context) => Container(
        width: 68 - innerPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildStart(context),
                _buildFinish(context),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 22, bottom: 2, top: 8),
              child: _buildRoomLocation(context),
            ),
          ],
        ),
      );

  Widget _buildRightContent(BuildContext context) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (model.lesson.action != null
              ? <Widget>[_buildLessonType(context)]
              : <Widget>[])
            ..addAll(<Widget>[
              _buildLessonTitle(context),
              _buildTeacherGroup(context),
            ]),
        ),
      );

  Widget _buildContentColumn(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: TimelinePainter.rectMargins + innerPadding,
        left: TimelinePainter.rectMargins * 2,
        right: TimelinePainter.rectMargins * 2,
        bottom: innerPadding,
      ),
      child: Row(
        children: <Widget>[
          _buildLeftContent(context),
          Container(
            width: 50 + innerPadding + TimelinePainter.circleRadiusAdd,
          ),
          _buildRightContent(context),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context) => Container(
        height: 85,
        child: Stack(
          children: <Widget>[
            _buildLine(context),
            _buildContentColumn(context),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _buildRow(context);
  }
}
