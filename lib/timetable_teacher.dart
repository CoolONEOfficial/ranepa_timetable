class Teacher {
  const Teacher(this.name, this.surname, this.patronymic);

  final String name, surname, patronymic;

  factory Teacher.parse(String respName) {
    final words = respName.substring(respName.lastIndexOf('>') + 1).split(" ");
    return Teacher(words[words.length - 2], words[words.length - 3],
        words[words.length - 1]);
  }
}
