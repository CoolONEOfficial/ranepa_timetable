![RANEPA Logo](assets/images/icon.png?raw=true "")

[![Build Status](https://travis-ci.org/CoolONEOfficial/ranepa_timetable.svg?branch=master)](https://travis-ci.org/CoolONEOfficial/ranepa_timetable)

[![AppStore][appstore-image]][appstore-url]
[![PlayStore][playstore-image]][playstore-url]


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

[appstore-image]: https://itsallwidgets.com/images/apple.png
[playstore-image]: https://itsallwidgets.com/images/google.png

[appstore-url]: https://apps.apple.com/ru/app/niu-ranepa/id1489094504
[playstore-url]: https://play.google.com/store/apps/details?id=ru.coolone.ranepatimetable