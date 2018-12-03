// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomModel _$RoomModelFromJson(Map<String, dynamic> json) {
  return RoomModel(
      json['room'] as int, _$enumDecode(_$LocationEnumMap, json['location']));
}

Map<String, dynamic> _$RoomModelToJson(RoomModel instance) => <String, dynamic>{
      'room': instance.number,
      'location': _$LocationEnumMap[instance.location]
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

const _$LocationEnumMap = <Location, dynamic>{
  Location.Academy: 'Academy',
  Location.Hostel: 'Hostel'
};
