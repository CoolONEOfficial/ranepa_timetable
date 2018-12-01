// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return Lesson(json['title'] as String, json['iconCodePoint'] as int);
}

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
      'title': instance.title,
      'iconCodePoint': instance.iconCodePoint
    };
