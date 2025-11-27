/// Сущность, представляющая преподавателя
///
/// Этот класс представляет собой преподавателя
/// и его ФИО
class Teacher {
  /// ФИО Преподавателя
  final String teacherName;

  /// Конструктор преподавателя
  ///
  /// Параметры:
  /// - [teacherName]: ФИО Преподавателя (обязательный)
  Teacher({required this.teacherName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Teacher && runtimeType == other.runtimeType && teacherName == other.teacherName;

  @override
  int get hashCode => teacherName.hashCode;

  @override
  String toString() {
    return 'Teacher{teacherName: $teacherName}';
  }
}
