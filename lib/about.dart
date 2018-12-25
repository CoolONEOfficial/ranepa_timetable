import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ranepa_timetable/localizations.dart';
import 'package:ranepa_timetable/widget_templates.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  static const ROUTE = "/about";

  Widget _buildGuyIcon(
    BuildContext context,
    String name,
    String description,
    String url,
    String image,
  ) =>
      Expanded(
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
                    color: const Color(0xff7c94b6),
                    image: DecorationImage(
                      image: AssetImage('assets/images/$image.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    border: Border.all(
                      color: Theme.of(context).accentTextTheme.title.color,
                      width: 4.0,
                    ),
                  ),
                ),
              ),
              Container(height: 20),
              RichText(
                text: TextSpan(
                  text: '$name\n',
                  style: Theme.of(context).accentTextTheme.title,
                  children: <TextSpan>[
                    TextSpan(
                      text: '"$url"',
                      style: Theme.of(context).accentTextTheme.body2,
                    ),
                  ],
                ),
              ),
              Container(height: 10),
              Text(
                description,
                style: Theme.of(context).accentTextTheme.subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(AppLocalizations.of(context).about),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: SvgPicture.asset(
                'assets/images/coolone_logo.svg',
                color: Theme.of(context).accentTextTheme.title.color,
              ),
              onPressed: () => openUrl('http://coolone.ru/'),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/images/github.svg',
                color: Theme.of(context).accentTextTheme.title.color,
              ),
              onPressed: () => openUrl(
                  'https://github.com/CoolONEOfficial/ranepa_timetable'),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          color: Theme.of(context).accentColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      WidgetTemplates.buildLogo(Theme.of(context)),
                      Container(height: 60),
                      Text(
                        AppLocalizations.of(context).introWelcomeDescription,
                        style: Theme.of(context).accentTextTheme.title,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildGuyIcon(
                    context,
                    'Вадим',
                    'IOS разработчик',
                    'overveigh',
                    'vadim',
                  ),
                  _buildGuyIcon(
                    context,
                    'Николай',
                    'Android разработчик',
                    'coooneofficial',
                    'coolone',
                  ),
                  _buildGuyIcon(
                    context,
                    'Александр',
                    'Креативный директор',
                    'xr.aleks01',
                    'xr',
                  ),
                ],
              ),
              Container(height: 30),
            ],
          ),
        ),
      );

  void openUrl(String url) async {
    if (await canLaunch(url)) await launch(url);
  }
}
