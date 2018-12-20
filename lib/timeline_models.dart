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
class TimelineModel {
  final TimelineUser user;
  final DateTime date;
  final LessonModel lesson;
  final RoomModel room;
  final String group;
  final TeacherModel teacher;

  bool first, last;
  bool mergeBottom, mergeTop;

  @JsonKey(fromJson: _timeOfDayFromIntList, toJson: _timeOfDayToIntList)
  final TimeOfDay start, finish;

  static TimeOfDay _timeOfDayFromIntList(Map<String, dynamic> map) =>
      TimeOfDay(hour: map["hour"], minute: map["minute"]);

  static Map<String, dynamic> _timeOfDayToIntList(TimeOfDay timeOfDay) =>
      {"hour": timeOfDay.hour, "minute": timeOfDay.minute};

  TimelineModel({
    @required this.date,
    @required this.start,
    @required this.finish,
    @required this.room,
    @required this.group,
    @required this.lesson,
    @required this.teacher,
    @required this.user,
    this.first = false,
    this.last = false,
    this.mergeBottom = false,
    this.mergeTop = false,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);
}

enum RoomLocation { Academy, Hotel, StudyHostel }

class RoomLocationsTitles {
  static RoomLocationsTitles _singleton;

  factory RoomLocationsTitles(BuildContext context) {
    if (_singleton == null) _singleton = RoomLocationsTitles._(context);

    return _singleton;
  }

  RoomLocationsTitles._(this.context)
      : titles = List<String>.generate(
          RoomLocation.values.length,
          (roomLocationIndex) {
            final localizations = AppLocalizations.of(context);
            switch (RoomLocation.values[roomLocationIndex]) {
              case RoomLocation.Academy:
                return localizations.roomLocationAcademy;
              case RoomLocation.Hotel:
                return localizations.roomLocationHotel;
              case RoomLocation.StudyHostel:
                return localizations.roomLocationStudyHostel;
            }
          },
        );

  final List<String> titles;
  final BuildContext context;
}

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

@JsonSerializable(nullable: false)
class LessonAction extends Findable {
  final String title;

  LessonAction copy() => LessonAction(title, words);

  const LessonAction(this.title, [List<List<String>> words]) : super(words);

  factory LessonAction.fromJson(Map<String, dynamic> json) =>
      _$LessonActionFromJson(json);

  Map<String, dynamic> toJson() => _$LessonActionToJson(this);
}

class LessonTypes {
  static LessonTypes _singleton;

  factory LessonTypes(BuildContext context) {
    if (_singleton == null) _singleton = LessonTypes._(context);

    return _singleton;
  }

  final BuildContext context;
  final List<LessonAction> lessonTypes;

  LessonTypes._(this.context)
      : lessonTypes = List<LessonAction>.generate(
          LessonTypeIds.values.length,
          (mLessonTypeIdIndex) {
            final mLessonTypeId = LessonTypeIds.values[mLessonTypeIdIndex];

            switch (mLessonTypeId) {
              case LessonTypeIds.Exam:
                return LessonAction(
                    AppLocalizations.of(context).exam, <List<String>>[
                  <String>["прием", "экзамен"]
                ]);
              case LessonTypeIds.ExamConsultation:
                return LessonAction(
                    AppLocalizations.of(context).examConsultation,
                    <List<String>>[
                      <String>["консульт", "экзамен"]
                    ]);
              case LessonTypeIds.Practice:
                return LessonAction(
                    AppLocalizations.of(context).practice, <List<String>>[
                  <String>["практ"]
                ]);
              case LessonTypeIds.ReceptionExamination:
                return LessonAction(
                    AppLocalizations.of(context).receptionExamination,
                    <List<String>>[
                      <String>["защит", "прием"]
                    ]);
              case LessonTypeIds.Lecture:
                return LessonAction(
                    AppLocalizations.of(context).lecture, <List<String>>[
                  <String>["лекция"]
                ]);
            }
          },
        );
}

enum LessonTypeIds {
  Lecture,
  Practice,
  ReceptionExamination,
  Exam,
  ExamConsultation,
}

String parseLessonTitle(String str) {
  final openBracketIndex = str.indexOf('('),
      title = str.substring(
          0, openBracketIndex != -1 ? openBracketIndex : str.length - 1);
  return title[0].toUpperCase() + title.substring(1);
}

@JsonSerializable(nullable: false)
class LessonModel extends Findable {
  String fullTitle;
  final String title;
  final int iconCodePoint;
  LessonAction action;

  LessonModel(
    this.title,
    this.iconCodePoint,
    this.fullTitle,
    this.action,
  );

  LessonModel._(
    this.title,
    this.iconCodePoint, [
    List<List<String>> words,
  ]) : super(words);

  LessonModel._copy(
    this.title,
    this.iconCodePoint,
    this.fullTitle, [
    List<List<String>> words,
  ]) : super(words);

  LessonModel copy() =>
      LessonModel._copy(title, iconCodePoint, fullTitle, words);

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonModelToJson(this);

  factory LessonModel.fromString(BuildContext context, String str) {
    final lowerStr = str.toLowerCase();

    LessonModel model;

    for (final mLesson in Lessons(context).lessons) {
      if (mLesson.find(lowerStr)) {
        model = mLesson.copy();
        break;
      }
    }

    if (model == null)
      model = LessonModel._(
          parseLessonTitle(lowerStr), TimetableIcons.unknownLesson.codePoint);

    model.fullTitle =
        str.substring(0, str.indexOf(')')).replaceFirst('(', '\n');
    for (final mType in LessonTypes(context).lessonTypes) {
      if (mType.find(lowerStr)) {
        model.action = mType;
        break;
      }
    }

    debugPrint("model type: ${model.action.title}");

    return model;
  }
}

enum LessonIds {
  math,
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
  inventory
}

abstract class Findable {
  @JsonKey(ignore: true)
  final List<List<String>> words;

  const Findable([this.words]);

  bool find(String findStr) {
    for (final mStrList in words) {
      bool strFound = true;
      for (final mStr in mStrList) {
        if (!findStr.contains(mStr)) {
          strFound = false;
          break;
        }
      }
      if (strFound) return true;
    }
    return false;
  }
}

class Lessons {
  static Lessons _singleton;

  factory Lessons(BuildContext context) {
    if (_singleton == null) _singleton = Lessons._(context);

    return _singleton;
  }

  Lessons._(this.context)
      : lessons =
            List<LessonModel>.generate(LessonIds.values.length, (lessonIndex) {
          switch (LessonIds.values[lessonIndex]) {
            case LessonIds.math:
              return LessonModel._(
                AppLocalizations.of(context).math,
                TimetableIcons.math.codePoint,
                <List<String>>[
                  <String>["математик"]
                ],
              );
            case LessonIds.economics:
              return LessonModel._(
                AppLocalizations.of(context).economics,
                TimetableIcons.economics.codePoint,
                <List<String>>[
                  <String>["экономик"],
                  <String>["экономическ", "теори"]
                ],
              );
            case LessonIds.informationTheory:
              return LessonModel._(
                AppLocalizations.of(context).informationTheory,
                TimetableIcons.informationTheory.codePoint,
                <List<String>>[
                  <String>["теори", "информаци"]
                ],
              );
            case LessonIds.philosophy:
              return LessonModel._(
                AppLocalizations.of(context).philosophy,
                TimetableIcons.philosophy.codePoint,
                <List<String>>[
                  <String>["философи"]
                ],
              );
            case LessonIds.speechCulture:
              return LessonModel._(
                AppLocalizations.of(context).speechCulture,
                TimetableIcons.speechCulture.codePoint,
                <List<String>>[
                  <String>["культур", "реч"]
                ],
              );
            case LessonIds.physics:
              return LessonModel._(
                AppLocalizations.of(context).physics,
                TimetableIcons.physics.codePoint,
                <List<String>>[
                  <String>["физик"]
                ],
              );
            case LessonIds.chemistry:
              return LessonModel._(
                AppLocalizations.of(context).chemistry,
                TimetableIcons.chemistry.codePoint,
                <List<String>>[
                  <String>["хими"]
                ],
              );
            case LessonIds.literature:
              return LessonModel._(
                AppLocalizations.of(context).literature,
                TimetableIcons.literature.codePoint,
                <List<String>>[
                  <String>["литератур"]
                ],
              );
            case LessonIds.english:
              return LessonModel._(
                AppLocalizations.of(context).english,
                TimetableIcons.english.codePoint,
                <List<String>>[
                  <String>["иностранн"],
                  <String>["английск"]
                ],
              );
            case LessonIds.informatics:
              return LessonModel._(
                AppLocalizations.of(context).informatics,
                TimetableIcons.informatics.codePoint,
                <List<String>>[
                  <String>["информатик"]
                ],
              );
            case LessonIds.geography:
              return LessonModel._(
                AppLocalizations.of(context).geography,
                TimetableIcons.geography.codePoint,
                <List<String>>[
                  <String>["географи"]
                ],
              );
            case LessonIds.history:
              return LessonModel._(
                AppLocalizations.of(context).history,
                TimetableIcons.history.codePoint,
                <List<String>>[
                  <String>["истори"]
                ],
              );
            case LessonIds.lifeSafety:
              return LessonModel._(
                AppLocalizations.of(context).lifeSafety,
                TimetableIcons.lifeSafety.codePoint,
                <List<String>>[
                  <String>["биологи"]
                ],
              );
            case LessonIds.biology:
              return LessonModel._(
                AppLocalizations.of(context).biology,
                TimetableIcons.biology.codePoint,
                <List<String>>[
                  <String>["биологи"]
                ],
              );
            case LessonIds.socialStudies:
              return LessonModel._(
                AppLocalizations.of(context).socialStudies,
                TimetableIcons.socialStudies.codePoint,
                <List<String>>[
                  <String>["общество"]
                ],
              );
            case LessonIds.physicalCulture:
              return LessonModel._(
                AppLocalizations.of(context).physicalCulture,
                TimetableIcons.physicalCulture.codePoint,
                <List<String>>[
                  <String>["физ", "культур"]
                ],
              );
            case LessonIds.ethics:
              return LessonModel._(
                AppLocalizations.of(context).ethics,
                TimetableIcons.ethics.codePoint,
                <List<String>>[
                  <String>["этик"]
                ],
              );
            case LessonIds.management:
              return LessonModel._(
                AppLocalizations.of(context).management,
                TimetableIcons.management.codePoint,
                <List<String>>[
                  <String>["менеджмент"]
                ],
              );
            case LessonIds.softwareDevelopment:
              return LessonModel._(
                AppLocalizations.of(context).softwareDevelopment,
                TimetableIcons.softwareDevelopment.codePoint,
                <List<String>>[
                  <String>["разработ", "програмн", "обеспечени"],
                  <String>["разработ", "по"]
                ],
              );
            case LessonIds.computerArchitecture:
              return LessonModel._(
                AppLocalizations.of(context).computerArchitecture,
                TimetableIcons.computerArchitecture.codePoint,
                <List<String>>[
                  <String>["архитектур", "эвм"],
                  <String>["архитектур", "пк"]
                ],
              );
            case LessonIds.operatingSystems:
              return LessonModel._(
                AppLocalizations.of(context).operatingSystems,
                TimetableIcons.operatingSystems.codePoint,
                <List<String>>[
                  <String>["операционн", "систем"]
                ],
              );
            case LessonIds.computerGraphic:
              return LessonModel._(
                AppLocalizations.of(context).computerGraphic,
                TimetableIcons.computerGraphic.codePoint,
                <List<String>>[
                  <String>["компьютерн", "график"]
                ],
              );
            case LessonIds.projectDevelopment:
              return LessonModel._(
                AppLocalizations.of(context).projectDevelopment,
                TimetableIcons.projectDevelopment.codePoint,
                <List<String>>[
                  <String>["проектн"]
                ],
              );
            case LessonIds.databases:
              return LessonModel._(
                AppLocalizations.of(context).databases,
                TimetableIcons.databases.codePoint,
                <List<String>>[
                  <String>["баз", "данн"]
                ],
              );
            case LessonIds.documentManagementSupport:
              return LessonModel._(
                AppLocalizations.of(context).documentManagementSupport,
                TimetableIcons.documentManagementSupport.codePoint,
                <List<String>>[
                  <String>["обеспеч", "управл", "документ"]
                ],
              );
            case LessonIds.accounting:
              return LessonModel._(
                AppLocalizations.of(context).accounting,
                TimetableIcons.accounting.codePoint,
                <List<String>>[
                  <String>["бухучет"]
                ],
              );
            case LessonIds.accountingAnalysis:
              return LessonModel._(
                AppLocalizations.of(context).accountingAnalysis,
                TimetableIcons.accountingAnalysis.codePoint,
                <List<String>>[
                  <String>["анализ", "бухгалтер"]
                ],
              );
            case LessonIds.budgetCalculations:
              return LessonModel._(
                AppLocalizations.of(context).budgetCalculations,
                TimetableIcons.budgetCalculations.codePoint,
                <List<String>>[
                  <String>["расчет", "бюдж"]
                ],
              );
            case LessonIds.taxation:
              return LessonModel._(
                AppLocalizations.of(context).taxation,
                TimetableIcons.taxation.codePoint,
                <List<String>>[
                  <String>["налогообложен"]
                ],
              );
            case LessonIds.businessPlanning:
              return LessonModel._(
                AppLocalizations.of(context).businessPlanning,
                TimetableIcons.businessPlanning.codePoint,
                <List<String>>[
                  <String>["планирован", "бизнес"]
                ],
              );
            case LessonIds.inventory:
              return LessonModel._(
                AppLocalizations.of(context).inventory,
                TimetableIcons.inventory.codePoint,
                <List<String>>[
                  <String>["инвентар"]
                ],
              );
          }
        });

  final BuildContext context;

  final List<LessonModel> lessons;
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
