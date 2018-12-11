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
import 'package:json_annotation/json_annotation.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/timetable_icons.dart';

part 'timeline_models.g.dart';

enum TimelineUser { Student, Teacher }

@JsonSerializable(nullable: false)
class TimelineParent {
  final TimelineUser user;
  final DateTime date;

  TimelineParent(this.user, this.date);
}

@JsonSerializable(nullable: false)
class TimelineModel extends TimelineParent {
  final LessonModel lesson;
  final RoomModel room;
  final String group;
  final TeacherModel teacher;

  bool first, last;

  @JsonKey(fromJson: _timeOfDayFromIntList, toJson: _timeOfDayToIntList)
  final TimeOfDay start, finish;

  static TimeOfDay _timeOfDayFromIntList(Map<String, int> map) =>
      TimeOfDay(hour: map["hour"], minute: map["minute"]);

  static Map<String, int> _timeOfDayToIntList(TimeOfDay timeOfDay) =>
      {"hour": timeOfDay.hour, "minute": timeOfDay.minute};

  TimelineModel(
      {@required DateTime date,
      @required this.start,
      @required this.finish,
      @required this.room,
      @required this.group,
      @required this.lesson,
      @required this.teacher,
      @required TimelineUser user,
      this.first = false,
      this.last = false})
      : super(user, date);

  factory TimelineModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);
}

enum RoomLocation { Academy, Hotel, StudyHostel }

@JsonSerializable(nullable: false)
class RoomModel {
  final int number;
  final RoomLocation location;

  const RoomModel(this.number, this.location);

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);

  factory RoomModel.fromString(String str) {
    return RoomModel(
        int.parse(RegExp(r"\d{3}").stringMatch(str).toString()),
        str.startsWith("СО")
            ? RoomLocation.StudyHostel
            : str.startsWith("П8") ? RoomLocation.Hotel : RoomLocation.Academy);
  }
}

enum LessonType { Theory, Practice }

String parseLessonTitle(String str) {
  final openBracketIndex = str.indexOf('('),
      title = str.substring(
          0, openBracketIndex != -1 ? openBracketIndex : str.length - 1);
  return title[0].toUpperCase() + title.substring(1);
}

LessonType parseLessonType(String str) {
  final openBracketIndex = str.indexOf('(');
  assert(openBracketIndex != -1);
  final lowerTitle = str.toLowerCase();

  return lowerTitle.contains("практ", openBracketIndex) ||
          lowerTitle.contains("семин")
      ? LessonType.Practice
      : lowerTitle.contains("лекци", openBracketIndex)
          ? LessonType.Theory
          : null;
}

@JsonSerializable(nullable: false)
class LessonModel {
  final String title;
  final int iconCodePoint;
  LessonType type;

  LessonModel(this.title, this.iconCodePoint, {this.type});

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonModelToJson(this);

  factory LessonModel.fromString(BuildContext context, String str) {
    final types = LessonTypes(context);
    str = str.toLowerCase();

    LessonModel model;

    if (str.contains("математик"))
      model = types.math;
    else if (str.contains("экономик") ||
        (str.contains("экономическ") && str.contains("теори")))
      model = types.economics;
    else if (str.contains("теори") && str.contains("информаци"))
      return types.informationTheory;
    else if (str.contains("философи"))
      model = types.philosophy;
    else if (str.contains("культур") && str.contains("реч"))
      return types.speechCulture;
    else if (str.contains("физик"))
      model = types.physics;
    else if (str.contains("хими"))
      model = types.chemistry;
    else if (str.contains("литератур"))
      model = types.literature;
    else if (str.contains("иностранн") || str.contains("английск"))
      model = types.english;
    else if (str.contains("информатик"))
      model = types.informatics;
    else if (str.contains("географи"))
      model = types.geography;
    else if (str.contains("истори"))
      model = types.history;
    else if (str.contains("обж") ||
        (str.contains("безопасност") && str.contains("жизнедеятельност")))
      return types.lifeSafety;
    else if (str.contains("биологи"))
      model = types.biology;
    else if (str.contains("общество"))
      model = types.socialStudies;
    else if (str.contains("физ") && str.contains("культур"))
      return types.physicalCulture;
    else if (str.contains("этик"))
      model = types.ethics;
    else if (str.contains("менеджмент"))
      model = types.management;
    else if (str.contains("разработ") &&
        ((str.contains("програмн") && str.contains("обеспечени")) ||
            str.contains("ПО")))
      model = types.softwareDevelopment;
    else if (str.contains("архитектур") &&
        (str.contains("эвм") || str.contains("пк")))
      model = types.computerArchitecture;
    else if (str.contains("операционн") && str.contains("систем"))
      model = types.operatingSystems;
    else if (str.contains("компьютерн") && str.contains("график"))
      model = types.computerGraphic;
    else if (str.contains("проектн"))
      model = types.projectDevelopment;
    else if (str.contains("баз") && str.contains("данн"))
      model = types.databases;
    else if (str.contains("обеспеч") &&
        str.contains("управл") &&
        str.contains("документ"))
      model = types.documentManagementSupport;
    else if (str.contains("инвентар"))
      model = types.inventory;
    else if (str.contains("бухучет"))
      model = types.accounting;
    else if (str.contains("планирован") && str.contains("бизнес"))
      model = types.businessPlanning;
    else if (str.contains("налогообложен"))
      model = types.taxation;
    else if (str.contains("расчет") && str.contains("бюдж"))
      model = types.budgetCalculations;
    else
      model = LessonModel(parseLessonTitle(str),
          TimetableIcons.unknownLesson.codePoint); // Use original title

    model.type = parseLessonType(str);

    return model;
  }
}

class LessonTypes {
  static LessonTypes _singleton;

  factory LessonTypes(BuildContext context) {
    if (_singleton == null) _singleton = LessonTypes._internal(context);

    return _singleton;
  }

  LessonTypes._internal(this.context)
      : math = LessonModel(
            AppLocalizations.of(context).math, TimetableIcons.math.codePoint),
        economics = LessonModel(AppLocalizations.of(context).economics,
            TimetableIcons.economics.codePoint),
        informationTheory = LessonModel(
            AppLocalizations.of(context).informationTheory,
            TimetableIcons.informationTheory.codePoint),
        philosophy = LessonModel(AppLocalizations.of(context).philosophy,
            TimetableIcons.philosophy.codePoint),
        speechCulture = LessonModel(AppLocalizations.of(context).speechCulture,
            TimetableIcons.speechCulture.codePoint),
        physics = LessonModel(AppLocalizations.of(context).physics,
            TimetableIcons.physics.codePoint),
        chemistry = LessonModel(AppLocalizations.of(context).chemistry,
            TimetableIcons.chemistry.codePoint),
        literature = LessonModel(AppLocalizations.of(context).literature,
            TimetableIcons.literature.codePoint),
        english = LessonModel(AppLocalizations.of(context).english,
            TimetableIcons.english.codePoint),
        informatics = LessonModel(AppLocalizations.of(context).informatics,
            TimetableIcons.informatics.codePoint),
        geography = LessonModel(AppLocalizations.of(context).geography,
            TimetableIcons.geography.codePoint),
        history = LessonModel(AppLocalizations.of(context).history,
            TimetableIcons.history.codePoint),
        lifeSafety = LessonModel(AppLocalizations.of(context).lifeSafety,
            TimetableIcons.lifeSafety.codePoint),
        biology = LessonModel(AppLocalizations.of(context).biology,
            TimetableIcons.biology.codePoint),
        socialStudies = LessonModel(AppLocalizations.of(context).socialStudies,
            TimetableIcons.socialStudies.codePoint),
        physicalCulture = LessonModel(
            AppLocalizations.of(context).physicalCulture,
            TimetableIcons.physicalCulture.codePoint),
        ethics = LessonModel(AppLocalizations.of(context).ethics,
            TimetableIcons.ethics.codePoint),
        management = LessonModel(AppLocalizations.of(context).management,
            TimetableIcons.management.codePoint),
        softwareDevelopment = LessonModel(
            AppLocalizations.of(context).softwareDevelopment,
            TimetableIcons.softwareDevelopment.codePoint),
        computerArchitecture = LessonModel(
            AppLocalizations.of(context).computerArchitecture,
            TimetableIcons.computerArchitecture.codePoint),
        operatingSystems = LessonModel(
            AppLocalizations.of(context).operatingSystems,
            TimetableIcons.operatingSystems.codePoint),
        computerGraphic = LessonModel(
            AppLocalizations.of(context).computerGraphic,
            TimetableIcons.computerGraphic.codePoint),
        projectDevelopment = LessonModel(
            AppLocalizations.of(context).projectDevelopment,
            TimetableIcons.projectDevelopment.codePoint),
        databases = LessonModel(AppLocalizations.of(context).databases,
            TimetableIcons.databases.codePoint),
        documentManagementSupport = LessonModel(
            AppLocalizations.of(context).documentManagementSupport,
            TimetableIcons.documentManagementSupport.codePoint),
        accounting = LessonModel(AppLocalizations.of(context).accounting,
            TimetableIcons.accounting.codePoint),
        budgetCalculations = LessonModel(
            AppLocalizations.of(context).budgetCalculations,
            TimetableIcons.budgetCalculations.codePoint),
        taxation = LessonModel(AppLocalizations.of(context).taxation,
            TimetableIcons.taxation.codePoint),
        businessPlanning = LessonModel(
            AppLocalizations.of(context).businessPlanning,
            TimetableIcons.businessPlanning.codePoint),
        inventory = LessonModel(AppLocalizations.of(context).inventory,
            TimetableIcons.inventory.codePoint);

  final BuildContext context;

  final LessonModel math,
      economics,
      informationTheory,
      philosophy,
      speechCulture,
      physics,
      chemistry,
      literature,
      english,
      informatics,
      geography,
      history,
      lifeSafety,
      biology,
      socialStudies,
      physicalCulture,
      ethics,
      management,
      softwareDevelopment,
      computerArchitecture,
      operatingSystems,
      computerGraphic,
      projectDevelopment,
      databases,
      documentManagementSupport,
      accounting,
      budgetCalculations,
      taxation,
      businessPlanning,
      inventory;
}

@JsonSerializable(nullable: false)
class TeacherModel {
  const TeacherModel(this.name, this.surname, this.patronymic);

  final String name, surname, patronymic;

  factory TeacherModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherModelToJson(this);

  factory TeacherModel.fromString(String respName) {
    final words = respName
        .substring(respName.lastIndexOf('>') + 1)
        .split(new RegExp(r"\s+"));
    return TeacherModel(words[words.length - 2], words[words.length - 3],
        words[words.length - 1]);
  }

  @override
  String toString() => "$surname $name $patronymic";

  String initials() => "$surname ${name[0]}. ${patronymic[0]}.";
}
