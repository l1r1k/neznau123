/// Вспомогательная структура данных для деталей занятия
class LessonDetails {
  /// Название предмета
  final String subject;

  /// Имя преподавателя
  final String teacher;

  const LessonDetails({required this.subject, required this.teacher});

  /// Проверяет, есть ли данные для отображения
  bool get hasData => subject.isNotEmpty || teacher.isNotEmpty;
}

/// Парсит строку с информацией о занятии в детали предмета и преподавателя
LessonDetails parseLessonDetails(String raw) {
  final sanitized = raw.replaceAll('\u00A0', ' ').replaceAll('\r', '').trim();
  if (sanitized.isEmpty) {
    return const LessonDetails(subject: '', teacher: '');
  }

  var working = sanitized;
  final trailingNoteMatch = RegExp(r'\s*\(([^()]+)\)\s*$').firstMatch(working);
  if (trailingNoteMatch != null) {
    working = working.substring(0, trailingNoteMatch.start).trimRight();
  }

  final newlineParts = working
      .split(RegExp(r'[\n]+'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (newlineParts.length >= 2) {
    return LessonDetails(
      subject: newlineParts.first,
      teacher: newlineParts.sublist(1).join(' '),
    );
  }

  final multipleSpaceParts = working
      .split(RegExp(r'\s{2,}'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (multipleSpaceParts.length >= 2) {
    return LessonDetails(
      subject: multipleSpaceParts.first,
      teacher: multipleSpaceParts.sublist(1).join(' '),
    );
  }

  final dashParts = working.split(RegExp(r'\s[-–—]\s'));
  if (dashParts.length == 2) {
    return LessonDetails(
      subject: dashParts.first.trim(),
      teacher: dashParts.last.trim(),
    );
  }

  final parenthesisRegExp = RegExp(r'(.+?)\s*\(([^)]+)\)$');
  final parenthesisMatch = parenthesisRegExp.firstMatch(working);
  if (parenthesisMatch != null) {
    return LessonDetails(
      subject: parenthesisMatch.group(1)!.trim(),
      teacher: parenthesisMatch.group(2)!.trim(),
    );
  }

  final initialsPattern = RegExp(
    r'^(.+?)\s([A-Za-zА-Яа-яЁё]\.[A-Za-zА-Яа-яЁё]\.\s*[A-Za-zА-Яа-яЁё-]+)$',
  );
  final initialsMatch = initialsPattern.firstMatch(working);
  if (initialsMatch != null) {
    return LessonDetails(
      subject: initialsMatch.group(1)!.trim(),
      teacher: initialsMatch.group(2)!.trim(),
    );
  }

  return LessonDetails(subject: working, teacher: '');
}
