import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:xml/xml.dart' as xml;

const DEFAULT_API_ID = SiteApiIds.APP_NEW;

enum SiteApiIds {
  APP_OLD,
  APP_NEW,
  SITE,
}

class SiteApi {
  final String title;
  final Uri url;

  const SiteApi(this.title, this.url);
}

enum OldAppApiTimetableIndexes {
  Date,
  TimeStart,
  TimeFinish,
  Name,
  Room,
  Group,
}

enum OldAppApiSearchIndexes {
  Type,
  Id,
  Title,
}

class SiteApis {
  static SiteApis _singleton;

  factory SiteApis(BuildContext ctx) {
    if (_singleton == null) _singleton = SiteApis._internal(ctx);
    return _singleton;
  }

  final List<SiteApi> apis;

  SiteApis._internal(BuildContext ctx)
      : apis = <SiteApi>[
          // APP_OLD
          SiteApi(
            AppLocalizations.of(ctx).siteApiOldApp,
            Uri.http(
              "test.ranhigs-nn.ru",
              "/api/WebService.asmx",
            ),
          ),

          // APP_NEW
          SiteApi(
            AppLocalizations.of(ctx).siteApiNewApp,
            Uri.http(
              "services.niu.ranepa.ru",
              "/wp-content/plugins/rasp/rasp_json_data.php",
            ),
          ),

          // SITE
          SiteApi(
            AppLocalizations.of(ctx).siteApiSite,
            Uri.http(
              "services.niu.ranepa.ru",
              "/API/public/",
            ),
          ),
        ];
}

parseResp(SiteApiIds api, String resp) {
  switch (api) {
    case SiteApiIds.APP_NEW:
      var arr = json.decode(resp);
      return arr is Iterable ? arr : [arr];
    case SiteApiIds.APP_OLD:
      return xml
          .parse(resp)
          .children[1]
          .firstChild
          .firstChild
          .firstChild
          .children;
    case SiteApiIds.SITE:
      final arr = json.decode(resp).entries.first.value.entries;

      var key = arr.first.key;

      return arr.isNotEmpty // TODO: fix this shit..
          ? key == "ItemRaspUID" || key == "RaspItem" ? arr.first.value : arr
          : [];
  }
}
