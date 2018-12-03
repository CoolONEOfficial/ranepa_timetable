// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineModel _$TimelineModelFromJson(Map<String, dynamic> json) {
  return TimelineModel(
      date: DateTime.parse(json['date'] as String),
      start: TimelineModel._timeOfDayFromIntList(
          json['start'] as Map<String, int>),
      finish: TimelineModel._timeOfDayFromIntList(
          json['finish'] as Map<String, int>),
      room: RoomModel.fromJson(json['room'] as Map<String, dynamic>),
      group: json['group'] as String,
      lesson: LessonModel.fromJson(json['lesson'] as Map<String, dynamic>),
      teacher: TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>));
}

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'lesson': instance.lesson,
      'room': instance.room,
      'date': instance.date.toIso8601String(),
      'group': instance.group,
      'teacher': instance.teacher,
      'start': TimelineModel._timeOfDayToIntList(instance.start),
      'finish': TimelineModel._timeOfDayToIntList(instance.finish)
    };
