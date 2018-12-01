// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineModel _$TimelineModelFromJson(Map<String, dynamic> json) {
  return TimelineModel(
      date: DateTime.parse(json['date'] as String),
      start: TimelineModel._timeOfDayFromIntList(json['start'] as List<int>),
      finish: TimelineModel._timeOfDayFromIntList(json['finish'] as List<int>),
      room: json['room'] as String,
      group: json['group'] as String,
      classType: Lesson.fromJson(json['classType'] as Map<String, dynamic>),
      teacher: Teacher.fromJson(json['teacher'] as Map<String, dynamic>));
}

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'classType': instance.classType,
      'room': instance.room,
      'date': instance.date.toIso8601String(),
      'start': TimelineModel._timeOfDayToIntList(instance.start),
      'finish': TimelineModel._timeOfDayToIntList(instance.finish),
      'group': instance.group,
      'teacher': instance.teacher
    };
