// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineModel _$TimelineModelFromJson(Map<String, dynamic> json) {
  return TimelineModel(
      date: DateTime.parse(json['date'] as String),
      start: TimelineModel._timeOfDayFromIntList(
          json['start'] as Map<String, dynamic>),
      finish: TimelineModel._timeOfDayFromIntList(
          json['finish'] as Map<String, dynamic>),
      room: RoomModel.fromJson(json['room'] as Map<String, dynamic>),
      group: json['group'] as String,
      lesson: LessonModel.fromJson(json['lesson'] as Map<String, dynamic>),
      teacher: TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>),
      user: _$enumDecode(_$TimelineUserEnumMap, json['user']),
      first: json['first'] as bool,
      last: json['last'] as bool,
      mergeBottom: json['mergeBottom'] as bool,
      mergeTop: json['mergeTop'] as bool);
}

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'user': _$TimelineUserEnumMap[instance.user],
      'date': instance.date.toIso8601String(),
      'lesson': instance.lesson,
      'room': instance.room,
      'group': instance.group,
      'teacher': instance.teacher,
      'first': instance.first,
      'last': instance.last,
      'mergeBottom': instance.mergeBottom,
      'mergeTop': instance.mergeTop,
      'start': TimelineModel._timeOfDayToIntList(instance.start),
      'finish': TimelineModel._timeOfDayToIntList(instance.finish)
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

const _$TimelineUserEnumMap = <TimelineUser, dynamic>{
  TimelineUser.Student: 'Student',
  TimelineUser.Teacher: 'Teacher'
};

RoomModel _$RoomModelFromJson(Map<String, dynamic> json) {
  return RoomModel(json['number'] as String,
      _$enumDecode(_$RoomLocationEnumMap, json['location']));
}

Map<String, dynamic> _$RoomModelToJson(RoomModel instance) => <String, dynamic>{
      'number': instance.number,
      'location': _$RoomLocationEnumMap[instance.location]
    };

const _$RoomLocationEnumMap = <RoomLocation, dynamic>{
  RoomLocation.Academy: 'Academy',
  RoomLocation.Hotel: 'Hotel',
  RoomLocation.StudyHostel: 'StudyHostel'
};

LessonAction _$LessonActionFromJson(Map<String, dynamic> json) {
  return LessonAction(json['title'] as String);
}

Map<String, dynamic> _$LessonActionToJson(LessonAction instance) =>
    <String, dynamic>{'title': instance.title};

LessonModel _$LessonModelFromJson(Map<String, dynamic> json) {
  return LessonModel(
      json['title'] as String,
      json['iconCodePoint'] as int,
      json['fullTitle'] as String,
      LessonAction.fromJson(json['action'] as Map<String, dynamic>));
}

Map<String, dynamic> _$LessonModelToJson(LessonModel instance) =>
    <String, dynamic>{
      'fullTitle': instance.fullTitle,
      'title': instance.title,
      'iconCodePoint': instance.iconCodePoint,
      'action': instance.action
    };

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
