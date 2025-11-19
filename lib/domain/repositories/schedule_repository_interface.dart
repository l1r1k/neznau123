import 'package:my_mpt/domain/entities/schedule.dart';

/// Интерфейс репозитория для работы с расписанием
abstract class ScheduleRepositoryInterface {
  /// Получить расписание на неделю
  Future<Map<String, List<Schedule>>> getWeeklySchedule();

  /// Получить расписание на сегодня
  Future<List<Schedule>> getTodaySchedule();

  /// Получить расписание на завтра
  Future<List<Schedule>> getTomorrowSchedule(); 
}