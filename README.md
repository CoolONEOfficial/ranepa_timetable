![RANEPA Logo](assets/images/icon.png?raw=true "")

# NRU RANEPA Timetable

Custom open-source NRU RANEPA mobile client written on Flutter.

## Getting Started

For help getting started with Flutter, view our online [documentation](https://flutter.io/).

## References, used in the development

[Localization](https://proandroiddev.com/flutter-localization-step-by-step-30f95d06018d) flutter app

[Icons](https://pub.dartlang.org/packages/flutter_launcher_icons#-installing-tab-) for IOS/Android versions for Flutter app

## Useful commands

### Regenerate .arb translations files
```Shell
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localizations.dart
```

### Regenerate translations classes
```Shell
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/localizations.dart lib/l10n/intl_messages.arb lib/l10n/intl_ru.arb
```

### Regenerate icons
```Shell
flutter pub pub run flutter_launcher_icons:main
```