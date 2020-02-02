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
import 'package:ranepa_timetable/apis.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/main.dart';
import 'package:ranepa_timetable/timetable_icons.dart';
import 'package:tuple/tuple.dart';

part 'timeline_models.g.dart';

abstract class FindableModel {
  const FindableModel();
}

mixin ToAlias {}

class FindTree = Tuple2<FindableModel, Map<List<dynamic>, dynamic>>
    with ToAlias;

enum User {
  Student,
  Teacher,
}

@JsonSerializable(nullable: false)
class TimelineModel {
  @JsonKey(fromJson: _numToDate, toJson: _dateToNum)
  final DateTime date;

  final LessonModel lesson;
  final RoomModel room;
  final String group;
  final TeacherModel teacher;

  @JsonKey(fromJson: _intToBool, toJson: _boolToInt)
  bool first, last;
  @JsonKey(fromJson: _intToBool, toJson: _boolToInt)
  bool mergeBottom, mergeTop;

  @JsonKey(fromJson: _timeOfDayFromIntList, toJson: _timeOfDayToIntList)
  final TimeOfDay start, finish;

  static TimeOfDay _timeOfDayFromIntList(Map<String, dynamic> map) =>
      TimeOfDay(hour: map["hour"], minute: map["minute"]);

  static Map<String, dynamic> _timeOfDayToIntList(TimeOfDay timeOfDay) =>
      {"hour": timeOfDay.hour, "minute": timeOfDay.minute};

  static bool _intToBool(int i) => i == 1;

  static int _boolToInt(bool b) => b ? 1 : 0;

  static int _dateToNum(DateTime dt) => dt.millisecondsSinceEpoch;

  static DateTime _numToDate(int n) => DateTime.fromMicrosecondsSinceEpoch(n);


  TimelineModel({
    @required this.date,
    @required this.start,
    @required this.finish,
    @required this.room,
    @required this.group,
    @required this.lesson,
    @required this.teacher,
    this.first = false,
    this.last = false,
    this.mergeBottom = false,
    this.mergeTop = false,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);
}

enum RoomLocationStyle { Text, Icon }

enum DayStyle { Weekday, Date }

enum RoomLocation { Academy, Hotel, StudyHostel }

class RoomLocationsTitles {
  static RoomLocationsTitles _singleton;

  factory RoomLocationsTitles(BuildContext ctx) {
    if (_singleton == null) _singleton = RoomLocationsTitles._(ctx);

    return _singleton;
  }

  RoomLocationsTitles._(this.ctx)
      : titles = List<String>.generate(
          RoomLocation.values.length,
          (roomLocationIndex) {
            final localizations = AppLocalizations.of(ctx);
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
  final BuildContext ctx;
}

@JsonSerializable(nullable: false)
class RoomModel extends FindableModel {
  final String number;
  final RoomLocation location;

  const RoomModel(this.number, this.location);

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);

  factory RoomModel.fromString(String str) => RoomModel(
      RegExp(r"(\d{3}[А-я]?)").stringMatch(str),
      str.startsWith("СО")
          ? RoomLocation.StudyHostel
          : str.startsWith("П8") ? RoomLocation.Hotel : RoomLocation.Academy);
}

@JsonSerializable(nullable: false)
class LessonAction extends FindableModel {
  final String title;

  LessonAction copy() => LessonAction(title);

  const LessonAction(this.title);

  factory LessonAction.fromJson(Map<String, dynamic> json) =>
      _$LessonActionFromJson(json);

  Map<String, dynamic> toJson() => _$LessonActionToJson(this);
}

class LessonActions {
  static LessonActions _singleton;

  factory LessonActions(BuildContext ctx, SiteApiIds api) {
    if (_singleton == null) _singleton = LessonActions._(ctx, api);

    return _singleton;
  }

  final SiteApiIds api;

  get findTree {
    switch (api) {
      case SiteApiIds.SITE:
      case SiteApiIds.APP_OLD:
        return _oldApiFindTree;
      case SiteApiIds.APP_NEW:
        return _newApiFindTree;
      default:
        throw Exception("Api is null wtf");
    }
  }

  final BuildContext ctx;

  final FindTree _oldApiFindTree, _newApiFindTree;

  LessonActions._(this.ctx, this.api)
      : _oldApiFindTree = FindTree(null, {
          ["прием", "зачет"]: LessonAction(AppLocalizations.of(ctx).credit),
          ["прием", "экзамен"]: LessonAction(AppLocalizations.of(ctx).exam),
          ["консульт", "экзамен"]:
              LessonAction(AppLocalizations.of(ctx).examConsultation),
          ["практ"]: LessonAction(AppLocalizations.of(ctx).practice),
          ["прием", "защит"]:
              LessonAction(AppLocalizations.of(ctx).receptionExamination),
          ["лекция"]: LessonAction(AppLocalizations.of(ctx).lecture),
        }),
        _newApiFindTree = FindTree(null, {
          // TODO: new api actions findTree
//          ["прием", "зачет"]: LessonAction(AppLocalizations.of(ctx).credit),
//          ["прием", "экзамен"]: LessonAction(AppLocalizations.of(ctx).exam),
//          ["консульт", "экзамен"]:
//              LessonAction(AppLocalizations.of(ctx).examConsultation),
          ["прак"]: LessonAction(AppLocalizations.of(ctx).practice),
//          ["прием", "защит"]:
//              LessonAction(AppLocalizations.of(ctx).receptionExamination),
          ["лек"]: LessonAction(AppLocalizations.of(ctx).lecture),
        });
}

@JsonSerializable(nullable: false)
class LessonModel extends FindableModel {
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

  LessonModel._(this.title, this.iconCodePoint);

  LessonModel._copy(this.title, this.iconCodePoint, this.fullTitle);

  LessonModel copy() => LessonModel._copy(title, iconCodePoint, fullTitle);

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonModelToJson(this);

  factory LessonModel.build(
    BuildContext ctx,
    String subject,
    String type,
    SiteApiIds api,
  ) {
    final lowerSubject = subject.toLowerCase();

    final LessonModel model =
        _findInTree(lowerSubject, Lessons(ctx).findTree) ??
            LessonModel._(subject, TimetableIcons.unknownLesson.codePoint);

    model.action =
        _findInTree(type.toLowerCase(), LessonActions(ctx, api).findTree) ??
            LessonAction(type);
    model.fullTitle = subject;

    debugPrint("model type: ${model.action?.title}");

    return model;
  }
}

class Lessons {
  static Lessons _singleton;

  factory Lessons(BuildContext ctx) {
    if (_singleton == null) _singleton = Lessons._(ctx);

    return _singleton;
  }

  Lessons._(this.ctx)
      : findTree = FindTree(
          null,
          {
            ["математик"]: FindTree(
              LessonModel._(
                AppLocalizations.of(ctx).math,
                TimetableIcons.math.codePoint,
              ),
              {
                ["дискрет"]: LessonModel._(
                  AppLocalizations.of(ctx).discMath,
                  TimetableIcons.math.codePoint,
                ),
                ["статисти"]: LessonModel._(
                  AppLocalizations.of(ctx).statMath,
                  TimetableIcons.math.codePoint,
                ),
              },
            ),
            ["экономическ", "теори"]: LessonModel._(
              AppLocalizations.of(ctx).economics,
              TimetableIcons.economics.codePoint,
            ),
            ["теори", "информаци"]: LessonModel._(
              AppLocalizations.of(ctx).informationTheory,
              TimetableIcons.informationTheory.codePoint,
            ),
            ["философи"]: LessonModel._(
              AppLocalizations.of(ctx).philosophy,
              TimetableIcons.philosophy.codePoint,
            ),
            ["культур", "реч"]: LessonModel._(
              AppLocalizations.of(ctx).speechCulture,
              TimetableIcons.speechCulture.codePoint,
            ),
            ["физик"]: LessonModel._(
              AppLocalizations.of(ctx).physics,
              TimetableIcons.physics.codePoint,
            ),
            ["хими"]: LessonModel._(
              AppLocalizations.of(ctx).chemistry,
              TimetableIcons.chemistry.codePoint,
            ),
            ["литератур"]: LessonModel._(
              AppLocalizations.of(ctx).literature,
              TimetableIcons.literature.codePoint,
            ),
            [
              ["иностранн", "английск"],
              'язык',
            ]: LessonModel._(
              AppLocalizations.of(ctx).english,
              TimetableIcons.english.codePoint,
            ),
            ["информатик"]: LessonModel._(
              AppLocalizations.of(ctx).informatics,
              TimetableIcons.informatics.codePoint,
            ),
            ["географи"]: LessonModel._(
              AppLocalizations.of(ctx).geography,
              TimetableIcons.geography.codePoint,
            ),
            ["истори"]: LessonModel._(
              AppLocalizations.of(ctx).history,
              TimetableIcons.history.codePoint,
            ),
            ["безопасность"]: LessonModel._(
              AppLocalizations.of(ctx).lifeSafety,
              TimetableIcons.lifeSafety.codePoint,
            ),
            ["биологи"]: LessonModel._(
              AppLocalizations.of(ctx).biology,
              TimetableIcons.biology.codePoint,
            ),
            ["общество"]: LessonModel._(
              AppLocalizations.of(ctx).socialStudies,
              TimetableIcons.socialStudies.codePoint,
            ),
            ["физ", "культур"]: LessonModel._(
              AppLocalizations.of(ctx).physicalCulture,
              TimetableIcons.physicalCulture.codePoint,
            ),
            ["право", "обеспеч"]: LessonModel._(
              AppLocalizations.of(ctx).legalSupport,
              TimetableIcons.ethics.codePoint,
            ),
            ["этик"]: LessonModel._(
              AppLocalizations.of(ctx).ethics,
              TimetableIcons.ethics.codePoint,
            ),
            ["менеджмент"]: LessonModel._(
              AppLocalizations.of(ctx).management,
              TimetableIcons.management.codePoint,
            ),
            [
              "разработ",
              [
                "по",
                ["програмн", "обеспечени"],
              ],
            ]: LessonModel._(
              AppLocalizations.of(ctx).softwareDevelopment,
              TimetableIcons.softwareDevelopment.codePoint,
            ),
            [
              "архитектур",
              ["пк", "эвм"],
            ]: LessonModel._(
              AppLocalizations.of(ctx).computerArchitecture,
              TimetableIcons.computerArchitecture.codePoint,
            ),
            ["операционн", "систем"]: LessonModel._(
              AppLocalizations.of(ctx).operatingSystems,
              TimetableIcons.operatingSystems.codePoint,
            ),
            ["компьютерн", "график"]: LessonModel._(
              AppLocalizations.of(ctx).computerGraphic,
              TimetableIcons.computerGraphic.codePoint,
            ),
            ["проектн", "разработк"]: LessonModel._(
              AppLocalizations.of(ctx).projectDevelopment,
              TimetableIcons.projectDevelopment.codePoint,
            ),
            ["баз", "данн"]: LessonModel._(
              AppLocalizations.of(ctx).databases,
              TimetableIcons.databases.codePoint,
            ),
            ["обеспеч", "управл", "документ"]: LessonModel._(
              AppLocalizations.of(ctx).documentManagementSupport,
              TimetableIcons.documentManagementSupport.codePoint,
            ),
            ["бухучет"]: LessonModel._(
              AppLocalizations.of(ctx).accounting,
              TimetableIcons.accounting.codePoint,
            ),
            ["анализ", "бухгалтер"]: LessonModel._(
              AppLocalizations.of(ctx).accountingAnalysis,
              TimetableIcons.accountingAnalysis.codePoint,
            ),
            ["расчет", "бюдж"]: LessonModel._(
              AppLocalizations.of(ctx).budgetCalculations,
              TimetableIcons.budgetCalculations.codePoint,
            ),
            ["налогообложен"]: LessonModel._(
              AppLocalizations.of(ctx).taxation,
              TimetableIcons.taxation.codePoint,
            ),
            ["планирован", "бизнес"]: LessonModel._(
              AppLocalizations.of(ctx).businessPlanning,
              TimetableIcons.businessPlanning.codePoint,
            ),
            <String>["инвентар"]: LessonModel._(
              AppLocalizations.of(ctx).inventory,
              TimetableIcons.inventory.codePoint,
            ),
          },
        );

  final BuildContext ctx;

  final FindTree findTree;
}

LessonModel generateRandomLesson(BuildContext ctx) =>
    (getRandomTreeModel(Lessons(ctx).findTree) as LessonModel)
      ..action = getRandomTreeModel(
        LessonActions(
          ctx,
          SiteApiIds.values[random.nextInt(SiteApiIds.values.length)],
        ).findTree,
      ) as LessonAction;

enum CheckWordsMode {
  All,
  One,
}

bool _containsWordsTree(
  String str,
  List words, [
  CheckWordsMode checkMode = CheckWordsMode.All,
]) {
  for (var mWord in words) {
    if (mWord is String) {
      switch (checkMode) {
        case CheckWordsMode.All:
          if (!str.contains(mWord)) return false;
          break;
        case CheckWordsMode.One:
          if (str.contains(mWord)) return true;
          break;
        default:
          throw Exception("findTree check words mode structure is fucked up");
      }
    } else if (mWord is List) {
      return _containsWordsTree(
        str,
        mWord,
        checkMode == CheckWordsMode.All // inverse
            ? CheckWordsMode.One
            : CheckWordsMode.All,
      );
    } else
      throw Exception("findTree words structure is fucked up");
  }
  return checkMode != CheckWordsMode.One;
}

int getTreeModelsCount(FindTree tree) {
  int count = 0;
  tree.item2.forEach((key, val) {
    switch (val.runtimeType) {
      case FindableModel:
        count++;
        break;
      case FindTree:
        count += getTreeModelsCount(val);
        break;
      default:
        throw Exception("findTree structure fucked up");
    }
  });
  return count;
}

FindableModel getRandomTreeModel(FindTree tree) {
  var randVal =
      tree.item2.values.elementAt(random.nextInt(tree.item2.values.length));

  if (randVal is FindableModel)
    return randVal;
  else if (randVal is FindTree)
    return getRandomTreeModel(randVal);
  else
    throw Exception("findTree structure fucked up");
}

dynamic _findInTree(
  String lesson,
  FindTree tree,
) {
  var result = tree.item1;
  tree.item2.forEach(
    (key, val) {
      if (!_containsWordsTree(lesson, key)) return;
      if (val is FindableModel)
        result = val;
      else if (val is FindTree)
        result = _findInTree(lesson, val);
      else
        throw Exception("findTree structure fucked up");
    },
  );
  return result;
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
