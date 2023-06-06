// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineModel _$TimelineModelFromJson(Map<String, dynamic> json) =>
    TimelineModel(
      date: TimelineModel._numToDate(json['date'] as int),
      start: TimelineModel._timeOfDayFromIntList(
          json['start'] as Map<String, dynamic>),
      finish: TimelineModel._timeOfDayFromIntList(
          json['finish'] as Map<String, dynamic>),
      room: RoomModel.fromJson(json['room'] as Map<String, dynamic>),
      group: json['group'] as String,
      lesson: LessonModel.fromJson(json['lesson'] as Map<String, dynamic>),
      teacher: TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>),
      first: json['first'] == null
          ? false
          : TimelineModel._intToBool(json['first'] as int),
      last: json['last'] == null
          ? false
          : TimelineModel._intToBool(json['last'] as int),
      mergeBottom: json['mergeBottom'] == null
          ? false
          : TimelineModel._intToBool(json['mergeBottom'] as int),
      mergeTop: json['mergeTop'] == null
          ? false
          : TimelineModel._intToBool(json['mergeTop'] as int),
    );

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'date': TimelineModel._dateToNum(instance.date),
      'lesson': instance.lesson,
      'room': instance.room,
      'group': instance.group,
      'teacher': instance.teacher,
      'first': TimelineModel._boolToInt(instance.first),
      'last': TimelineModel._boolToInt(instance.last),
      'mergeBottom': TimelineModel._boolToInt(instance.mergeBottom),
      'mergeTop': TimelineModel._boolToInt(instance.mergeTop),
      'start': TimelineModel._timeOfDayToIntList(instance.start),
      'finish': TimelineModel._timeOfDayToIntList(instance.finish),
    };

RoomModel _$RoomModelFromJson(Map<String, dynamic> json) => RoomModel(
      json['number'] as String,
      $enumDecode(_$RoomLocationEnumMap, json['location']),
    );

Map<String, dynamic> _$RoomModelToJson(RoomModel instance) => <String, dynamic>{
      'number': instance.number,
      'location': _$RoomLocationEnumMap[instance.location]!,
    };

const _$RoomLocationEnumMap = {
  RoomLocation.Academy: 'Academy',
  RoomLocation.Hotel: 'Hotel',
  RoomLocation.StudyHostel: 'StudyHostel',
};

LessonAction _$LessonActionFromJson(Map<String, dynamic> json) => LessonAction(
      json['title'] as String,
    );

Map<String, dynamic> _$LessonActionToJson(LessonAction instance) =>
    <String, dynamic>{
      'title': instance.title,
    };

LessonModel _$LessonModelFromJson(Map<String, dynamic> json) => LessonModel(
      json['title'] as String,
      json['iconCodePoint'] as int,
      json['fullTitle'] as String?,
      json['action'] == null
          ? null
          : LessonAction.fromJson(json['action'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LessonModelToJson(LessonModel instance) =>
    <String, dynamic>{
      'fullTitle': instance.fullTitle,
      'title': instance.title,
      'iconCodePoint': instance.iconCodePoint,
      'action': instance.action,
    };

TeacherModel _$TeacherModelFromJson(Map<String, dynamic> json) => TeacherModel(
      json['name'] as String,
      json['surname'] as String,
      json['patronymic'] as String,
    );

Map<String, dynamic> _$TeacherModelToJson(TeacherModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'surname': instance.surname,
      'patronymic': instance.patronymic,
    };
