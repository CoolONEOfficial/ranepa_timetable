import 'package:flutter/widgets.dart';
import 'package:ranepa_timetable/localizations.dart';

class SiteApi {
  final String title;
  final Uri url;

  const SiteApi(this.title, this.url);
}

enum SiteApiIds {
  APP_OLD,
  APP_NEW,
  SITE,
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
