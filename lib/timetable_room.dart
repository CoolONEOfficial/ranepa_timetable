import 'package:json_annotation/json_annotation.dart';

part 'timetable_room.g.dart';

enum Location { Academy, Hotel, StudyHostel }

@JsonSerializable(nullable: false)
class RoomModel {
  final int number;
  final Location location;

  const RoomModel(this.number, this.location);

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);

  factory RoomModel.fromString(String str) {
    return RoomModel(
        int.parse(new RegExp(r"\d{3}").stringMatch(str).toString()),
        str.startsWith("СО")
            ? Location.StudyHostel
            : str.startsWith("П8") ? Location.Hotel : Location.Academy);
  }
}
