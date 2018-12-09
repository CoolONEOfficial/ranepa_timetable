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
import 'package:ranepa_timetable/timeline_models.dart';
import 'package:ranepa_timetable/timeline_painter.dart';

class TimelineElement extends StatelessWidget {
  final TimelineModel model;

  TimelineElement({@required this.model});

  Widget _buildLine(BuildContext context) {
    return SizedBox.expand(
        child: Container(
      child: CustomPaint(
        painter: TimelinePainter(context, model),
      ),
    ));
  }

  Widget _buildContentColumn(BuildContext context) => Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20.0, left: 140.0, right: 15),
            child: Tooltip(
              message: model.lesson.title,
              child: Text(
                model.lesson.title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 45.0, left: 140.0, right: 15),
            child: Tooltip(
              message:
              model.user == TimelineUser.STUDENT
              ? model.teacher.toString()
              : model.group,
              child: Text(
                model.user == TimelineUser.STUDENT
                    ? model.teacher.initials()
                    : model.group,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 55.0, left: 50.0),
            child: Text(
              model.room.number.toString(),
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 15.0, left: 15.0),
            width: 80,
            child: Text(
              model.start.format(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 35.0, left: 15.0),
            width: 80,
            child: Text(
              model.finish.format(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body2,
            ),
          ),
        ],
      );

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
