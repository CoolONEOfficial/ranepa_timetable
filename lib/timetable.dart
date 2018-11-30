import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/timeline_model.dart';
import 'package:ranepa_timetable/timetable_icons.dart';

import 'timeline.dart';

class LessonItemTypes {
  final IconData _icon;

  const LessonItemTypes._internal(this._icon);

  toString() => 'Enum.$_icon';

  static const UNKNOWN =
      const LessonItemTypes._internal(Icons.insert_drive_file);
  static const ECONOMICS =
      const LessonItemTypes._internal(TimetableIcons.economics);
  static const MATH = const LessonItemTypes._internal(TimetableIcons.math);
  static const INFORMATION_THEORY =
      const LessonItemTypes._internal(TimetableIcons.informationTheory);
  static const PHILOSOPHY =
      const LessonItemTypes._internal(TimetableIcons.philosophy);
  static const SPEECH_CULTURE =
      const LessonItemTypes._internal(TimetableIcons.speechCulture);
  static const PHYSICS =
      const LessonItemTypes._internal(TimetableIcons.physics);
  static const CHEMISTRY =
      const LessonItemTypes._internal(TimetableIcons.chemistry);
  static const LITERATURE =
      const LessonItemTypes._internal(TimetableIcons.literature);
  static const ENGLISH =
      const LessonItemTypes._internal(TimetableIcons.english);
  static const INFORMATICS =
      const LessonItemTypes._internal(TimetableIcons.informatics);
  static const GEOGRAPHY =
      const LessonItemTypes._internal(TimetableIcons.geography);
  static const HISTORY =
      const LessonItemTypes._internal(TimetableIcons.history);
  static const SOCIAL_STUDIES =
      const LessonItemTypes._internal(TimetableIcons.socialStudies);
  static const BIOLOGY =
      const LessonItemTypes._internal(TimetableIcons.biology);
  static const LIFE_SAFETY =
      const LessonItemTypes._internal(TimetableIcons.lifeSafety);
  static const PHYSICAL_CULTURE =
      const LessonItemTypes._internal(TimetableIcons.physicalCulture);
  static const ETHICS = const LessonItemTypes._internal(TimetableIcons.ethics);
  static const MANAGEMENT =
      const LessonItemTypes._internal(TimetableIcons.management);
  static const SOFTWARE_DEVELOPMENT =
      const LessonItemTypes._internal(TimetableIcons.softwareDevelopment);
  static const COMPUTER_ARCHITECTURE =
      const LessonItemTypes._internal(TimetableIcons.computerArchitecture);
  static const OPERATING_SYSTEMS =
      const LessonItemTypes._internal(TimetableIcons.operatingSystems);
  static const COMPUTER_GRAPHIC =
      const LessonItemTypes._internal(TimetableIcons.computerGraphic);
  static const PROJECT_DEVELOPMENT =
      const LessonItemTypes._internal(TimetableIcons.projectDevelopment);
  static const DATABASES =
      const LessonItemTypes._internal(TimetableIcons.databases);
}

enum TimetableResponseIndexes { Date, TimeStart, TimeFinish, Name, Room, Group }

class TimetableWidget extends StatelessWidget {
  const TimetableWidget({Key key, this.lessons})
      : super(key: key);

  final List<TimelineModel> lessons;

  @override
  Widget build(BuildContext context) {
    print("started build");
    return TimelineComponent(
      timelineList: lessons,
    );
  }
}
