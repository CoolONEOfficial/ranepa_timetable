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
import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/timetable_lessons.dart';
import 'package:ranepa_timetable/timetable_teacher.dart';

class TimelineModel {
  final Lesson classType;
  final String room;

  final DateTime date;
  final TimeOfDay start, finish;
  final String group;
  final Teacher teacher;

  const TimelineModel({
    @required this.date,
    @required this.start,
    @required this.finish,
    @required this.room,
    @required this.group,
    @required this.classType,
    @required this.teacher,
  });
}
