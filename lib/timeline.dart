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

library timeline;

import 'package:flutter/material.dart';
import 'package:ranepa_timetable/timeline_element.dart';
import 'package:ranepa_timetable/timeline_models.dart';

class TimelineComponent extends StatelessWidget {
  final List<TimelineModel> timelineList;

  const TimelineComponent({Key key, @required this.timelineList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: timelineList.length,
        itemBuilder: (_, index) {
          return TimelineElement(
              model: timelineList[index]
          );
        },
      ),
    );
  }
}
