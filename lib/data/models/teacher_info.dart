/// Модель информации о преподавателе
///
/// Этот класс представляет собой информацию о преподавателе,
/// включая его ФИО
class TeacherInfo {
  /// ФИО Преподавателя
  final String teacherName;

  /// Конструктор информации о преподавателе
  ///
  /// Параметры:
  /// - [teacherName]: ФИО Преподавателя
  TeacherInfo({
    required this.teacherName
  });

  @override
  String toString() {
    return 'TeacherInfo(teacherName: $teacherName)';
  }

  /// Преобразует объект информации о преподавателе в JSON
  ///
  /// Возвращает:
  /// - Map<String, dynamic>: Представление информации о преподавателе в формате JSON
  Map<String, dynamic> toJson() {
    return {
      'teacherName': teacherName,
    };
  }
}
