// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherModel _$TeacherModelFromJson(Map<String, dynamic> json) {
  return TeacherModel(json['name'] as String, json['surname'] as String,
      json['patronymic'] as String);
}

Map<String, dynamic> _$TeacherModelToJson(TeacherModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'surname': instance.surname,
      'patronymic': instance.patronymic
    };
