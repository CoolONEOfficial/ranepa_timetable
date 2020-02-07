/* Copyright 2018 Rejish Radhakrishnan

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

library timeline;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ranepa_timetable/timeline_element.dart';
import 'package:ranepa_timetable/timeline_models.dart';

class TimelineComponent extends StatelessWidget {
  final List<TimelineModel> timelineList;

  final bool optimizeLessonTitles;

  const TimelineComponent(
    this.timelineList, {
    this.optimizeLessonTitles = true,
    Key key,
    this.onRefresh,
  }) : super(key: key);

  final Future<void> Function() onRefresh;

  Widget itemBuild(ctx, index) => TimelineElement(
        timelineList[index],
        optimizeLessonTitles: optimizeLessonTitles,
      );

  Widget defaultListView() => ListView.builder(
        itemCount: timelineList.length,
        itemBuilder: itemBuild,
      );

  @override
  Widget build(BuildContext ctx) => Container(
        child: onRefresh != null
            ? Platform.isIOS
                ? ListView(
                  children: <Widget>[
                    SizedBox(height: 0,),
                    Container(
                      height: timelineList.length * 85.0,
                      child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      slivers: <Widget>[
                        CupertinoSliverRefreshControl(
                          onRefresh: onRefresh,
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            itemBuild,
                            childCount: timelineList.length,
                          ),
                        ),
                      ],
                  ),
                    ),]
                )
                : RefreshIndicator(
                    onRefresh: onRefresh,
                    child: defaultListView(),
                  )
            : defaultListView(),
      );
}
