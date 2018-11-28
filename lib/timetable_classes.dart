import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/timetable_icons.dart';

class ClassType {
  final String _title;
  final IconData _icon;

  const ClassType(this._title, this._icon);

  static ClassType fromString(ClassTypes types, String str) {
    str.toLowerCase();

    if(str.contains("математик")) return types.math;
    if(str.contains("экономик")) return types.economics;
    if(str.contains("теори") && str.contains("информаци")) return types.informationTheory;
    if(str.contains("философи")) return types.philosophy;
    if(str.contains("культур") && str.contains("реч")) return types.speechCulture;
    if(str.contains("физик")) return types.physics;
    if(str.contains("хими")) return types.chemistry;
    if(str.contains("литератур")) return types.literature;
    if(str.contains("английск")) return types.english;
    if(str.contains("информатик")) return types.informatics;
    if(str.contains("географи")) return types.geography;
    if(str.contains("истори")) return types.history;
    if(str.contains("обж") || (str.contains("безопасност") && str.contains("жизнедеятельност"))) return types.lifeSafety;
    if(str.contains("биологи")) return types.biology;
    if(str.contains("общество")) return types.socialStudies;
    if(str.contains("физ") && str.contains("культур")) return types.physicalCulture;
    if(str.contains("этик")) return types.ethics;
    if(str.contains("менеджмент")) return types.management;
    if(str.contains("разработ") && ((str.contains("програмн") && str.contains("обеспечени")) || str.contains("ПО"))) return types.softwareDevelopment;
    if(str.contains("архитектур") && (str.contains("эвм") || str.contains("пк"))) return types.computerArchitecture;
    if(str.contains("операционн") && str.contains("систем")) return types.operatingSystems;
    if(str.contains("компьютерн") && str.contains("график")) return types.computerGraphic;
    if(str.contains("проектн")) return types.projectDevelopment;
    if(str.contains("баз") && str.contains("данн")) return types.databases;

    return null;
  }
}

class ClassTypes {
  static ClassTypes _singleton;

  factory ClassTypes(BuildContext context) {
    if (_singleton == null) _singleton = ClassTypes(context);

    return _singleton;
  }

  ClassTypes._internal(this.context)
      : math =
            ClassType(AppLocalizations.of(context).math, TimetableIcons.math),
        economics = ClassType(
            AppLocalizations.of(context).economics, TimetableIcons.economics),
        informationTheory = ClassType(
            AppLocalizations.of(context).informationTheory,
            TimetableIcons.informationTheory),
        philosophy = ClassType(
            AppLocalizations.of(context).philosophy, TimetableIcons.philosophy),
        speechCulture = ClassType(AppLocalizations.of(context).speechCulture,
            TimetableIcons.speechCulture),
        physics = ClassType(
            AppLocalizations.of(context).physics, TimetableIcons.physics),
        chemistry = ClassType(
            AppLocalizations.of(context).chemistry, TimetableIcons.chemistry),
        literature = ClassType(
            AppLocalizations.of(context).literature, TimetableIcons.literature),
        english = ClassType(
            AppLocalizations.of(context).english, TimetableIcons.english),
        informatics = ClassType(AppLocalizations.of(context).informatics,
            TimetableIcons.informatics),
        geography = ClassType(
            AppLocalizations.of(context).geography, TimetableIcons.geography),
        history = ClassType(
            AppLocalizations.of(context).history, TimetableIcons.history),
        lifeSafety = ClassType(
            AppLocalizations.of(context).lifeSafety, TimetableIcons.lifeSafety),
        biology = ClassType(
            AppLocalizations.of(context).biology, TimetableIcons.biology),
        socialStudies = ClassType(AppLocalizations.of(context).socialStudies,
            TimetableIcons.socialStudies),
        physicalCulture = ClassType(
            AppLocalizations.of(context).physicalCulture,
            TimetableIcons.physicalCulture),
        ethics = ClassType(
            AppLocalizations.of(context).ethics, TimetableIcons.ethics),
        management = ClassType(
            AppLocalizations.of(context).management, TimetableIcons.management),
        softwareDevelopment = ClassType(
            AppLocalizations.of(context).softwareDevelopment,
            TimetableIcons.softwareDevelopment),
        computerArchitecture = ClassType(
            AppLocalizations.of(context).computerArchitecture,
            TimetableIcons.computerArchitecture),
        operatingSystems = ClassType(
            AppLocalizations.of(context).operatingSystems,
            TimetableIcons.operatingSystems),
        computerGraphic = ClassType(
            AppLocalizations.of(context).computerGraphic,
            TimetableIcons.computerGraphic),
        projectDevelopment = ClassType(
            AppLocalizations.of(context).projectDevelopment,
            TimetableIcons.projectDevelopment),
        databases = ClassType(
            AppLocalizations.of(context).databases, TimetableIcons.databases);

  final BuildContext context;

  final unknown = ClassType(null, Icons.book),
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
      databases;
}
