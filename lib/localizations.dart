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

  String get title {
    return Intl.message('NRU RANEPA (Timetable)',
        name: 'title', desc: 'The application title');
  }

  String get searchTip {
    return Intl.message('Search',
        name: 'searchTip');
  }

  String get searchResults {
    return Intl.message('Web search results',
        name: 'searchResults');
  }

  String get groupEconomics{
    return Intl.message('Economics',
        name: 'groupEconomics');
  }

  String get groupInformatics{
    return Intl.message('Informatics',
        name: 'groupInformatics');
  }

  String get loading{
    return Intl.message('Loading',
        name: 'loading');
  }

  String get math{
    return Intl.message('Mathematics',
        name: 'math');
  }

  String get economics{
    return Intl.message('Economics',
        name: 'economics');
  }

  String get informationTheory{
    return Intl.message('Information theory',
        name: 'informationTheory');
  }

  String get philosophy{
    return Intl.message('Philosophy',
        name: 'philosophy');
  }

  String get speechCulture{
    return Intl.message('Culture of Speech',
        name: 'speechCulture');
  }

  String get physics{
    return Intl.message('Physics',
        name: 'physics');
  }

  String get chemistry{
    return Intl.message('Chemistry',
        name: 'chemistry');
  }

  String get literature{
    return Intl.message('Literature',
        name: 'literature');
  }

  String get english{
    return Intl.message('English',
        name: 'english');
  }

  String get informatics{
    return Intl.message('Informatics',
        name: 'informatics');
  }

  String get geography{
    return Intl.message('Geography',
        name: 'geography');
  }

  String get history{
    return Intl.message('History',
        name: 'history');
  }

  String get lifeSafety{
    return Intl.message('Basics of life safety',
        name: 'lifeSafety');
  }

  String get biology{
    return Intl.message('Biology',
        name: 'biology');
  }

  String get socialStudies{
    return Intl.message('Social Studies',
        name: 'socialStudies');
  }

  String get physicalCulture{
    return Intl.message('Physical Culture',
        name: 'physicalCulture');
  }

  String get ethics{
    return Intl.message('Ethics',
        name: 'ethics');
  }

  String get management{
    return Intl.message('Management',
        name: 'management');
  }

  String get softwareDevelopment{
    return Intl.message('Software Development',
        name: 'softwareDevelopment');
  }

  String get computerArchitecture{
    return Intl.message('Сomputer Architecture',
        name: 'computerArchitecture');
  }

  String get operatingSystems{
    return Intl.message('Operating Systems',
        name: 'operatingSystems');
  }

  String get computerGraphic{
    return Intl.message('Computer Graphic',
        name: 'computerGraphic');
  }

  String get projectDevelopment{
    return Intl.message('Project Development',
        name: 'projectDevelopment');
  }

  String get databases{
    return Intl.message('Databases',
        name: 'databases');
  }

  String get monday{
    return Intl.message('Mo',
        name: 'monday');
  }

  String get tuesday{
    return Intl.message('Tu',
        name: 'tuesday');
  }

  String get wednesday{
    return Intl.message('We',
        name: 'wednesday');
  }

  String get thursday{
    return Intl.message('Th',
        name: 'thursday');
  }

  String get friday{
    return Intl.message('Fr',
        name: 'friday');
  }

  String get saturday{
    return Intl.message('Sa',
        name: 'saturday');
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