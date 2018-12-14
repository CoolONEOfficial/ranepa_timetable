import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // App title

  String get title {
    return Intl.message(
      'RANEPA (Timetable)',
      name: 'title',
      desc: 'The application title',
    );
  }

  // No internet connection message

  String get noInternetConnection {
    return Intl.message(
      'No internet connection',
      name: 'noInternetConnection',
    );
  }

  // Free day message

  String get freeDay {
    return Intl.message(
      'Free day',
      name: 'freeDay',
    );
  }

  // Search strings

  String get searchTip {
    return Intl.message(
      'Search',
      name: 'searchTip',
    );
  }

  String get searchResults {
    return Intl.message(
      'Web search results',
      name: 'searchResults',
    );
  }

  // Lessons titles

  String get groupEconomics {
    return Intl.message(
      'Economics',
      name: 'groupEconomics',
    );
  }

  String get groupInformatics {
    return Intl.message(
      'Informatics',
      name: 'groupInformatics',
    );
  }

  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
    );
  }

  String get math {
    return Intl.message(
      'Mathematics',
      name: 'math',
    );
  }

  String get economics {
    return Intl.message(
      'Economics',
      name: 'economics',
    );
  }

  String get informationTheory {
    return Intl.message(
      'Information theory',
      name: 'informationTheory',
    );
  }

  String get philosophy {
    return Intl.message(
      'Philosophy',
      name: 'philosophy',
    );
  }

  String get speechCulture {
    return Intl.message(
      'Culture of Speech',
      name: 'speechCulture',
    );
  }

  String get physics {
    return Intl.message(
      'Physics',
      name: 'physics',
    );
  }

  String get chemistry {
    return Intl.message(
      'Chemistry',
      name: 'chemistry',
    );
  }

  String get literature {
    return Intl.message(
      'Literature',
      name: 'literature',
    );
  }

  String get english {
    return Intl.message(
      'English',
      name: 'english',
    );
  }

  String get informatics {
    return Intl.message(
      'Informatics',
      name: 'informatics',
    );
  }

  String get geography {
    return Intl.message(
      'Geography',
      name: 'geography',
    );
  }

  String get history {
    return Intl.message(
      'History',
      name: 'history',
    );
  }

  String get lifeSafety {
    return Intl.message(
      'Basics of life safety',
      name: 'lifeSafety',
    );
  }

  String get biology {
    return Intl.message(
      'Biology',
      name: 'biology',
    );
  }

  String get socialStudies {
    return Intl.message(
      'Social Studies',
      name: 'socialStudies',
    );
  }

  String get physicalCulture {
    return Intl.message(
      'Physical Culture',
      name: 'physicalCulture',
    );
  }

  String get ethics {
    return Intl.message(
      'Ethics',
      name: 'ethics',
    );
  }

  String get management {
    return Intl.message(
      'Management',
      name: 'management',
    );
  }

  String get softwareDevelopment {
    return Intl.message(
      'Software Development',
      name: 'softwareDevelopment',
    );
  }

  String get computerArchitecture {
    return Intl.message(
      'Сomputer Architecture',
      name: 'computerArchitecture',
    );
  }

  String get operatingSystems {
    return Intl.message(
      'Operating Systems',
      name: 'operatingSystems',
    );
  }

  String get computerGraphic {
    return Intl.message(
      'Computer Graphic',
      name: 'computerGraphic',
    );
  }

  String get projectDevelopment {
    return Intl.message(
      'Project Development',
      name: 'projectDevelopment',
    );
  }

  String get databases {
    return Intl.message(
      'Databases',
      name: 'databases',
    );
  }

  String get documentManagementSupport {
    return Intl.message(
      'Document management support',
      name: 'documentManagementSupport',
    );
  }

  String get accounting {
    return Intl.message(
      'Accounting',
      name: 'accounting',
    );
  }

  String get accountingAnalysis {
    return Intl.message(
      'Accounting analysis',
      name: 'accountingAnalysis',
    );
  }

  String get budgetCalculations {
    return Intl.message(
      'Budget calculations',
      name: 'budgetCalculations',
    );
  }

  String get taxation {
    return Intl.message(
      'Taxation',
      name: 'taxation',
    );
  }

  String get businessPlanning {
    return Intl.message(
      'Business planning',
      name: 'businessPlanning',
    );
  }

  String get inventory {
    return Intl.message(
      'Inventarization',
      name: 'inventory',
    );
  }

  // Days of week

  String get monday {
    return Intl.message(
      'Mo',
      name: 'monday',
    );
  }

  String get tuesday {
    return Intl.message(
      'Tu',
      name: 'tuesday',
    );
  }

  String get wednesday {
    return Intl.message(
      'We',
      name: 'wednesday',
    );
  }

  String get thursday {
    return Intl.message(
      'Th',
      name: 'thursday',
    );
  }

  String get friday {
    return Intl.message(
      'Fr',
      name: 'friday',
    );
  }

  String get saturday {
    return Intl.message(
      'Sa',
      name: 'saturday',
    );
  }

  // Drawer titles

  String get timetable {
    return Intl.message(
      'Timetable',
      name: 'timetable',
    );
  }

  String get prefs {
    return Intl.message(
      'Preferences',
      name: 'prefs',
    );
  }

  String get close {
    return Intl.message(
      'Close',
      name: 'close',
    );
  }

  // Drawer preferences buttons

  String get themeTitle {
    return Intl.message(
      'Theme',
      name: 'themeTitle',
    );
  }

  String get themeDescription {
    return Intl.message(
      'Color scheme of the application and widget',
      name: 'themeDescription',
    );
  }

  String get groupTitle {
    return Intl.message(
      'Change group/teacher',
      name: 'groupTitle',
    );
  }

  String get groupDescription {
    return Intl.message(
      'Change the default timetable for the group/teacher',
      name: 'groupDescription',
    );
  }

  String get widgetTranslucentTitle {
    return Intl.message(
      'Widget translucency',
      name: 'widgetTranslucentTitle',
    );
  }

  String get widgetTranslucentDescription {
    return Intl.message(
      'Translucency android widget on home screen',
      name: 'widgetTranslucentDescription',
    );
  }

  // Themes titles

  String get themeDark {
    return Intl.message(
      'Dark',
      name: 'themeDark',
    );
  }

  String get themeDarkRed {
    return Intl.message(
      'Dark Red',
      name: 'themeDarkRed',
    );
  }

  String get themeBlack {
    return Intl.message(
      'Black',
      name: 'themeBlack',
    );
  }

  String get themeBlackRed {
    return Intl.message(
      'Black Red',
      name: 'themeBlackRed',
    );
  }

  String get themeLight {
    return Intl.message(
      'Light',
      name: 'themeLight',
    );
  }

  String get themeLightRed {
    return Intl.message(
      'Light Red',
      name: 'themeLightRed',
    );
  }

  // Intro strings

  String get introGroupTitle {
    return Intl.message(
      'Group or teacher by default',
      name: 'introGroupTitle',
    );
  }

  String get introGroupDescription {
    return Intl.message(
      'For this group or teacher, the schedule will be loaded at startup.',
      name: 'introGroupDescription',
    );
  }

  String get introThemeTitle {
    return Intl.message(
      'Color scheme',
      name: 'introThemeTitle',
    );
  }

  String get introThemeDescription {
    return Intl.message(
      'The selected theme will be used when drawing the schedule and everything else. The theme can be changed in the settings.',
      name: 'introThemeDescription',
    );
  }

  String get introWelcomeTitle {
    return Intl.message(
      'Welcome',
      name: 'introWelcomeTitle',
    );
  }

  String get introWelcomeDescription {
    return Intl.message(
      'This application is an unofficial client of the site of the Nizhny Novgorod RANEPA and has no relation to its administration.',
      name: 'introWelcomeDescription',
    );
  }

  String get introTimetableTitle {
    return Intl.message(
      'Shedule example',
      name: 'introTimetableTitle',
    );
  }

  String get introTimetableDescription {
    return Intl.message(
      'So the schedule will look. If necessary, you can go back and change the theme.',
      name: 'introTimetableDescription',
    );
  }

  // Room location titles

  String get roomLocationAcademy {
    return Intl.message(
      'Academy',
      name: 'roomLocationAcademy',
    );
  }

  String get roomLocationStudyHostel {
    return Intl.message(
      'Study hostel',
      name: 'roomLocationStudyHostel',
    );
  }

  String get roomLocationHotel {
    return Intl.message(
      'Hotel (St. Pushkin, 8)',
      name: 'roomLocationHotel',
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
