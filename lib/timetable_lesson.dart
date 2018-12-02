import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/timetable_icons.dart';
import 'package:tuple/tuple.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timetable_lesson.g.dart';

enum LessonType { Theory, Practice }

Tuple2<String, LessonType> parseLesson(String str) {
  final bracketIndex = str.indexOf('(');
  assert(bracketIndex != -1);
  final lowerTitle = str.toLowerCase();

  return Tuple2<String, LessonType>(
      str.substring(0, bracketIndex),
      (lowerTitle.contains("практ", bracketIndex) ||
          lowerTitle.contains("семин"))
          ? LessonType.Practice
          : lowerTitle.contains("лекци", bracketIndex)
          ? LessonType.Theory
          : null);
}

// ignore: undefined_annotation
@JsonSerializable(nullable: false)
class LessonModel {
  final String title;
  final int iconCodePoint;

  const LessonModel(this.title, this.iconCodePoint);

  factory LessonModel.fromJson(Map<String, dynamic> json) => _$LessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonModelToJson(this);

  static LessonModel fromString(BuildContext context, String str) {
    final types = LessonTypes(context);
    str = str.toLowerCase();

    if (str.contains("математик")) return types.math;
    if (str.contains("экономик")) return types.economics;
    if (str.contains("теори") && str.contains("информаци"))
      return types.informationTheory;
    if (str.contains("философи")) return types.philosophy;
    if (str.contains("культур") && str.contains("реч"))
      return types.speechCulture;
    if (str.contains("физик")) return types.physics;
    if (str.contains("хими")) return types.chemistry;
    if (str.contains("литератур")) return types.literature;
    if (str.contains("английск")) return types.english;
    if (str.contains("информатик")) return types.informatics;
    if (str.contains("географи")) return types.geography;
    if (str.contains("истори")) return types.history;
    if (str.contains("обж") ||
        (str.contains("безопасност") && str.contains("жизнедеятельност")))
      return types.lifeSafety;
    if (str.contains("биологи")) return types.biology;
    if (str.contains("общество")) return types.socialStudies;
    if (str.contains("физ") && str.contains("культур"))
      return types.physicalCulture;
    if (str.contains("этик")) return types.ethics;
    if (str.contains("менеджмент")) return types.management;
    if (str.contains("разработ") &&
        ((str.contains("програмн") && str.contains("обеспечени")) ||
            str.contains("ПО"))) return types.softwareDevelopment;
    if (str.contains("архитектур") &&
        (str.contains("эвм") || str.contains("пк")))
      return types.computerArchitecture;
    if (str.contains("операционн") && str.contains("систем"))
      return types.operatingSystems;
    if (str.contains("компьютерн") && str.contains("график"))
      return types.computerGraphic;
    if (str.contains("проектн")) return types.projectDevelopment;
    if (str.contains("баз") && str.contains("данн")) return types.databases;
    return LessonModel(
        parseLesson(str).item1, Icons.book.codePoint); // Use original title
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
        physicalCulture = LessonModel(AppLocalizations.of(context).physicalCulture,
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
        operatingSystems = LessonModel(AppLocalizations.of(context).operatingSystems,
            TimetableIcons.operatingSystems.codePoint),
        computerGraphic = LessonModel(AppLocalizations.of(context).computerGraphic,
            TimetableIcons.computerGraphic.codePoint),
        projectDevelopment = LessonModel(
            AppLocalizations.of(context).projectDevelopment,
            TimetableIcons.projectDevelopment.codePoint),
        databases = LessonModel(AppLocalizations.of(context).databases,
            TimetableIcons.databases.codePoint);

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
      databases;
}
