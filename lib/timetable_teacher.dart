// ignore: uri_does_not_exist
import 'package:json_annotation/json_annotation.dart';

// ignore: uri_has_not_been_generated
part 'timetable_teacher.g.dart';

// ignore: undefined_annotation
@JsonSerializable(nullable: false)
class Teacher {
  const Teacher(this.name, this.surname, this.patronymic);

  final String name, surname, patronymic;

  factory Teacher.parse(String respName) {
    final words = respName.substring(respName.lastIndexOf('>') + 1).split(" ");
    return Teacher(words[words.length - 2], words[words.length - 3],
        words[words.length - 1]);
  }
}
