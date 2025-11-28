/// Модель изменения в расписании
///
/// Этот класс представляет собой изменение в расписании,
/// например, замену одного предмета на другой
class ScheduleChange {
  final String lessonNumber;
  final String? group;       // например "П50-5-22"
  final String replaceFrom; // текст колонки "Что заменяют"
  final String replaceTo;   // текст колонки "На что заменяют"
  final String updatedAt;   // дата/время из колонки updated-at
  final String changeDate;  // заголовок дня (например "Замены на 27.11.2025")
  final String? role;        // 'from' | 'to' | 'both' — роль искомого преподавателя

  ScheduleChange({
    required this.lessonNumber,
    this.group,
    required this.replaceFrom,
    required this.replaceTo,
    required this.updatedAt,
    required this.changeDate,
    this.role,
  });

  @override
  String toString() {
    return 'ScheduleChange(lessonNumber: $lessonNumber, replaceFrom: $replaceFrom, replaceTo: $replaceTo, updatedAt: $updatedAt, changeDate: $changeDate)';
  }

  /// Преобразует объект изменения в JSON
  ///
  /// Возвращает:
  /// - Map<String, dynamic>: Представление изменения в формате JSON
  Map<String, dynamic> toJson() {
    return {
      'lessonNumber': lessonNumber,
      'replaceFrom': replaceFrom,
      'replaceTo': replaceTo,
      'updatedAt': updatedAt,
      'changeDate': changeDate,
    };
  }
}
