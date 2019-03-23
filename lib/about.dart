import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ranepa_timetable/intro.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ranepa_timetable/CustomShapeClipper.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

void main() => runApp(MaterialApp(
      title: 'TITLE',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ));

Color firstColor = HexColor("000000");
Color secondColor = HexColor("000000");

class HomeScreen extends StatelessWidget {
  BuildContext ctx;
  static const ROUTE = "/about";

  Widget _buildGuyIconContent(
    BuildContext ctx,
    TextTheme textTheme,
    String name,
    String url,
    String image, {
    String descriptionLeft,
    String descriptionRight,
    String singleStr,
  }) =>
      Container(
        height: 220,
        child: GestureDetector(
          onTap: () => openUrl("https://vk.com/$url"),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Center(
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: textTheme.title.color,
                    image: DecorationImage(
                      image: AssetImage('assets/images/$image.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    border: Border.all(
                      color: textTheme.title.color,
                      width: 4.0,
                    ),
                  ),
                ),
              ),
              Container(height: 20),
              RichText(
                text: TextSpan(
                  text: '$name\n',
                  style: textTheme.title,
                  children: <TextSpan>[
                    TextSpan(
                      text: '"$url"',
                      style: textTheme.body2,
                    ),
                  ],
                ),
              ),
              Container(height: 10),
              Expanded(
                child: Center(
                  child: singleStr != null
                      ? AutoSizeText(
                          singleStr,
                          style: textTheme.subtitle,
                          textAlign: TextAlign.center,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget>[
                            Flexible(
                              child: AutoSizeText(
                                descriptionLeft,
                                style: textTheme.subtitle,
                                textAlign: TextAlign.right,
                                minFontSize: 2,
                                maxLines: descriptionLeft.split('\n').length,
                                softWrap: false,
                              ),
                            ),
                            Container(width: 4),
                            Flexible(
                              child: AutoSizeText(
                                descriptionRight,
                                style: textTheme.subtitle,
                                textAlign: TextAlign.left,
                                maxLines: descriptionRight.split('\n').length,
                                minFontSize: 2,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildGuyIcon(
    BuildContext ctx,
    TextTheme textTheme,
    String name,
    String url,
    String image,
    Orientation orientation, {
    String descriptionLeft,
    String descriptionRight,
    String singleStr,
  }) =>
      orientation == Orientation.portrait
          ? Flexible(
              child: _buildGuyIconContent(
              ctx,
              textTheme,
              name,
              url,
              image,
              descriptionRight: descriptionRight,
              descriptionLeft: descriptionLeft,
              singleStr: singleStr,
            ))
          : Container(
              width: 130,
              child: _buildGuyIconContent(
                ctx,
                textTheme,
                name,
                url,
                image,
                descriptionRight: descriptionRight,
                descriptionLeft: descriptionLeft,
                singleStr: singleStr,
              ));

  List<Widget> _buildGuys(
    BuildContext ctx,
    TextTheme textTheme,
    Orientation orientation,
  ) =>
      <Widget>[
        _buildGuyIcon(
          ctx,
          textTheme,
          'Вадим',
          'overveigh',
          'vadim',
          orientation,
          descriptionLeft: 'IOS',
          descriptionRight: 'разработчик\nтeстировщик',
        ),
        _buildGuyIcon(
          ctx,
          textTheme,
          'Николай',
          'cooloneofficial',
          'coolone',
          orientation,
          descriptionLeft: 'Flutter\nAndroid',
          descriptionRight: 'разработчик',
        ),
        _buildGuyIcon(
          ctx,
          textTheme,
          'Александр',
          'xr.aleks01',
          'xr',
          orientation,
          singleStr: 'Креативный\nдиректор',
        ),
      ];

  Widget _buildLogoTextColumn(
    BuildContext ctx,
    TextTheme textTheme,
  ) =>
      Container(
        height: ScreenUtil().setHeight(300),
        child: Intro.buildWelcomeTextList(
          AppLocalizations.of(ctx),
          Theme.of(ctx).accentTextTheme,
          autoSize: false,
        ),
      );

  List<Widget> _buildLogoText(
    BuildContext ctx,
    TextTheme textTheme,
    Orientation orientation,
  ) =>
      <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: WidgetTemplates.buildLogo(
            Theme.of(ctx),
            color: textTheme.title.color,
          ),
        ),
        orientation == Orientation.landscape
            ? Container(
                width: 200,
                child: _buildLogoTextColumn(ctx, textTheme),
              )
            : _buildLogoTextColumn(ctx, textTheme),
      ];

  @override
  Widget build(BuildContext ctx) {
    final currentTheme = Theme.of(ctx);
    final textTheme = (currentTheme.brightness == Brightness.dark
        ? Theme.of(ctx).accentTextTheme
        : Theme.of(ctx).primaryTextTheme);

    return Scaffold(
      body: OrientationBuilder(
        builder: (ctx, orientation) => Stack(
              children: <Widget>[
                ClipPath(
                  clipper: CustomShapeClipper(),
                  child: Container(
                    height: 400.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [firstColor, secondColor],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Theme.of(ctx).primaryColor,
                  child: orientation == Orientation.portrait
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: _buildLogoText(
                                        ctx, textTheme, orientation),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: _buildGuys(ctx, textTheme, orientation),
                            ),
                          ],
                        )
                      : Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: _buildLogoText(
                                ctx, textTheme, orientation)
                              ..addAll(_buildGuys(ctx, textTheme, orientation)),
                          ),
                        ),
                ),
              ],
            ),
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(ctx).about),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  static openUrl(String url) async {
    if (await canLaunch(url)) await launch(url);
  }
}
