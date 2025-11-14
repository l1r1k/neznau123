/// Утилита для форматирования дат на русском языке
class DateFormatter {
  static const List<String> _weekdays = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  static const List<String> _months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  /// Форматирует объект DateTime в читаемую строку на русском языке
  /// Пример: "Понедельник, 1 января"
  static String formatDayWithMonth(DateTime date) {
    final weekday = _weekdays[(date.weekday - 1) % _weekdays.length];
    final month = _months[(date.month - 1) % _months.length];
    return '$weekday, ${date.day} $month';
  }

  /// Получает русское название дня недели по его номеру в DateTime (1-7)
  static String getWeekdayName(int weekdayNumber) {
    return _weekdays[(weekdayNumber - 1) % _weekdays.length];
  }

  /// Получает русское название месяца по его номеру в DateTime (1-12)
  static String getMonthName(int monthNumber) {
    return _months[(monthNumber - 1) % _months.length];
  }
}