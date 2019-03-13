![RANEPA Logo](assets/images/icon.png?raw=true "")

[![Build Status](https://travis-ci.org/CoolONEOfficial/ranepa_timetable.svg?branch=master)](https://travis-ci.org/CoolONEOfficial/ranepa_timetable)

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png">](https://play.google.com/store/apps/details?id=ru.coolone.ranepatimetable)

[![AppStore][appstore-image =250x]][appstore-url]
[![PlayStore][playstore-image =250x]][playstore-url]


# NRU RANEPA Timetable

Custom open-source NRU RANEPA mobile client written on Flutter.

## Getting Started

For help getting started with Flutter, view our online [documentation](https://flutter.io/).

## Project setup

### Android:

1. Create key.properties to /android with:

```
storePassword=# STORE PASSWORD #
keyPassword=# KEY PASSWORD #
keyAlias=# KEY ALIAS #
storeFile=/path/to/keystore/# FILENAME #.keystore
```

### iOS:

1. Open Podfile.lock

1.1. Uncomment "platform :ios, '9.0''

1.2. Add `use_frameworks!` after `platform`

1.3. add `config.build_settings['SWIFT_VERSION'] = '4.0'` after `ENABLE_BITCODE`.

4. Create "File.swift" to /ios with:
```
import Foundation
```

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

### Regenerate all json serialized .g.dart files
```Shell
flutter packages pub run build_runner build --delete-conflicting-outputs
```

[appstore-image]: https://developer.apple.com/app-store/marketing/guidelines/images/badge-example-preferred.png
[playstore-image]: https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png

[appstore-url]: https://itunes.apple.com/ru/app//id1454700217
[playstore-url]: https://play.google.com/store/apps/details?id=ru.coolone.ranepatimetable