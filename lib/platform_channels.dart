import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformChannels {
  static const jsonChannel = const BasicMessageChannel(
    'ru.coolone.ranepatimetable/jsonChannel',
    StringCodec(),
  );

  static void updateDb([dynamic args]) async {
    var resp;
    List<String> jsons = [];

    for (var mArg in args) jsons.add(json.encode(mArg));

    try {
      debugPrint("Channel req.. args: ${jsons.toString()}");
      resp = await jsonChannel.send(jsons.toString());
    } on PlatformException catch (e) {
      resp = e.message;
    }

    debugPrint("Get resp: " + resp.toString());
  }

  static const methodChannel =
      const MethodChannel('ru.coolone.ranepatimetable/jsonChannel');

  static void refreshWidget() {
    methodChannel.invokeMethod("refreshWidget");
  }
}
