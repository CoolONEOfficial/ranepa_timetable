import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/timetable_icons.dart';

part 'timetable_lesson.g.dart';

enum LessonType { Theory, Practice }

String parseLessonTitle(String str) {
  final openBracketIndex = str.indexOf('(');
  assert(openBracketIndex != -1);

  final closeBracketIndex = str.indexOf(')');
  assert(closeBracketIndex != -1);

  return str.substring(openBracketIndex + 1, closeBracketIndex);
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
    else if (str.contains("экономик"))
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
      return types.computerArchitecture;
    else if (str.contains("операционн") && str.contains("систем"))
      return types.operatingSystems;
    else if (str.contains("компьютерн") && str.contains("график"))
      return types.computerGraphic;
    else if (str.contains("проектн"))
      model = types.projectDevelopment;
    else if (str.contains("баз") && str.contains("данн"))
      return types.databases;
    else
      model = LessonModel(
          parseLessonTitle(str), Icons.book.codePoint); // Use original title

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
