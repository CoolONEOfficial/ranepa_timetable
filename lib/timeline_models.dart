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

  static TimeOfDay _timeOfDayFromIntList(Map<String, dynamic> map) =>
      TimeOfDay(hour: map["hour"], minute: map["minute"]);

  static Map<String, dynamic> _timeOfDayToIntList(TimeOfDay timeOfDay) =>
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
  final String number;
  final RoomLocation location;

  const RoomModel(this.number, this.location);

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);

  factory RoomModel.fromString(String str) {
    return RoomModel(
        RegExp(r"(\d{3}[А-я]?)").stringMatch(str),
        str.startsWith("СО")
            ? RoomLocation.StudyHostel
            : str.startsWith("П8") ? RoomLocation.Hotel : RoomLocation.Academy);
  }
}

enum LessonType { None, Theory, Practice }

String parseLessonTitle(String str) {
  final openBracketIndex = str.indexOf('('),
      title = str.substring(
          0, openBracketIndex != -1 ? openBracketIndex : str.length - 1);
  return title[0].toUpperCase() + title.substring(1);
}

LessonType parseLessonType(String str) {
  var openBracketIndex = str.indexOf('(');
  if (openBracketIndex == -1) openBracketIndex = 0;
  final lowerTitle = str.substring(openBracketIndex).toLowerCase();
  debugPrint("m lower title: $lowerTitle");

  return (lowerTitle.contains("практ") || lowerTitle.contains("семин"))
      ? LessonType.Practice
      : (lowerTitle.contains("лекци") ? LessonType.Theory : LessonType.None);
}

@JsonSerializable(nullable: false)
class LessonModel {
  final String title;
  final int iconCodePoint;
  LessonType lessonType;

  LessonModel(this.title, this.iconCodePoint,
      {this.lessonType = LessonType.None});

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonModelToJson(this);

  factory LessonModel.fromString(BuildContext context, String str) {
    final types = LessonTypes(context);
    final lowerStr = str.toLowerCase();

    LessonModel model;

    if (lowerStr.contains("математик"))
      model = types.math;
    else if (lowerStr.contains("общество"))
      model = types.socialStudies;
    else if (lowerStr.contains("экономик") ||
        (lowerStr.contains("экономическ") && lowerStr.contains("теори")))
      model = types.economics;
    else if (lowerStr.contains("теори") && lowerStr.contains("информаци"))
      return types.informationTheory;
    else if (lowerStr.contains("философи"))
      model = types.philosophy;
    else if (lowerStr.contains("культур") && lowerStr.contains("реч"))
      return types.speechCulture;
    else if (lowerStr.contains("физик"))
      model = types.physics;
    else if (lowerStr.contains("хими"))
      model = types.chemistry;
    else if (lowerStr.contains("литератур"))
      model = types.literature;
    else if (lowerStr.contains("иностранн") || lowerStr.contains("английск"))
      model = types.english;
    else if (lowerStr.contains("информатик"))
      model = types.informatics;
    else if (lowerStr.contains("географи"))
      model = types.geography;
    else if (lowerStr.contains("истори"))
      model = types.history;
    else if (lowerStr.contains("обж") ||
        (lowerStr.contains("безопасност") &&
            lowerStr.contains("жизнедеятельност")))
      return types.lifeSafety;
    else if (lowerStr.contains("биологи"))
      model = types.biology;
    else if (lowerStr.contains("физ") && lowerStr.contains("культур"))
      return types.physicalCulture;
    else if (lowerStr.contains("этик"))
      model = types.ethics;
    else if (lowerStr.contains("менеджмент"))
      model = types.management;
    else if (lowerStr.contains("разработ") &&
        ((lowerStr.contains("програмн") && lowerStr.contains("обеспечени")) ||
            lowerStr.contains("ПО")))
      model = types.softwareDevelopment;
    else if (lowerStr.contains("архитектур") &&
        (lowerStr.contains("эвм") || lowerStr.contains("пк")))
      model = types.computerArchitecture;
    else if (lowerStr.contains("операционн") && lowerStr.contains("систем"))
      model = types.operatingSystems;
    else if (lowerStr.contains("компьютерн") && lowerStr.contains("график"))
      model = types.computerGraphic;
    else if (lowerStr.contains("проектн"))
      model = types.projectDevelopment;
    else if (lowerStr.contains("баз") && lowerStr.contains("данн"))
      model = types.databases;
    else if (lowerStr.contains("обеспеч") &&
        lowerStr.contains("управл") &&
        lowerStr.contains("документ"))
      model = types.documentManagementSupport;
    else if (lowerStr.contains("инвентар"))
      model = types.inventory;
    else if (lowerStr.contains("бухучет"))
      model = types.accounting;
    else if (lowerStr.contains("планирован") && lowerStr.contains("бизнес"))
      model = types.businessPlanning;
    else if (lowerStr.contains("налогообложен"))
      model = types.taxation;
    else if (lowerStr.contains("расчет") && lowerStr.contains("бюдж"))
      model = types.budgetCalculations;
    else if(lowerStr.contains("анализ") && lowerStr.contains("бухгалтер"))
      model = types.accountingAnalysis;
    else
      model = LessonModel(parseLessonTitle(lowerStr),
          TimetableIcons.unknownLesson.codePoint); // Use original title

    model.lessonType = parseLessonType(str);

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
        accountingAnalysis = LessonModel(AppLocalizations.of(context).accountingAnalysis,
            TimetableIcons.accountingAnalysis.codePoint),
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
      accountingAnalysis,
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
