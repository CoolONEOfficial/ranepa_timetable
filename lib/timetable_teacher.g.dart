// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map<String, dynamic> json) {
  return Teacher(json['name'] as String, json['surname'] as String,
      json['patronymic'] as String);
}

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
      'name': instance.name,
      'surname': instance.surname,
      'patronymic': instance.patronymic
    };
